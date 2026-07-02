local isWeaponEquipped = false
local currentWeaponData = nil -- solo se llena vía evento ox_inventory:currentWeapon
local isSpecialWeapon = false
local lastClipCount = -1
local isAiming = false
local hideTimer = nil

local Framework = 'none'

-- Cache de munición de reserva para frameworks que necesitan preguntarle al
-- servidor (qb/esx). Se refresca cada Config.ReserveAmmoPollInterval ms en
-- vez de en cada tick, para no saturar el servidor de callbacks.
local reserveAmmoCache = 0
local lastReserveFetch = 0
local reserveFetchInFlight = false

local SpecialWeapons = {
    [`WEAPON_STUNGUN`] = true,
    [`WEAPON_STUNGUN_MP`] = true,
    [`WEAPON_RAYPISTOL`] = true,
    [`WEAPON_RAYCARBINE`] = true,
    [`WEAPON_RAYMINIGUN`] = true,
}

-- ============================================================================
-- Detección de framework (cliente). ox_lib ya está garantizado como
-- dependencia por el fxmanifest, así que se puede usar en cualquier caso.
-- ============================================================================
CreateThread(function()
    if Config.Framework ~= 'auto' then
        Framework = Config.Framework
    elseif GetResourceState('ox_inventory') == 'started' then
        Framework = 'ox'
    elseif GetResourceState('qb-inventory') == 'started' then
        Framework = 'qb'
    elseif GetResourceState('es_extended') == 'started' then
        Framework = 'esx'
    else
        Framework = 'none'
    end

    print(('^2[D87 Weapons HUD]^7 Inicializado con éxito. Framework: ^3%s^7'):format(Framework))
end)

-- ============================================================================
-- Munición de reserva - ox_inventory: consulta directa y síncrona en cliente.
-- ============================================================================
local function GetReserveAmmoOx(ammoType)
    if not ammoType then return 0 end
    if GetResourceState('ox_inventory') ~= 'started' then return 0 end

    local ok, count = pcall(function()
        return exports.ox_inventory:Search('count', ammoType)
    end)

    return (ok and count) or 0
end

-- ============================================================================
-- Munición de reserva - qb/esx: requiere ir al servidor, así que se cachea
-- y se refresca solo cada Config.ReserveAmmoPollInterval ms.
-- ============================================================================
local function GetReserveAmmoRemote(ammoType)
    if not ammoType then return 0 end

    local now = GetGameTimer()
    if reserveFetchInFlight or (now - lastReserveFetch) < (Config.ReserveAmmoPollInterval or 1000) then
        return reserveAmmoCache
    end

    lastReserveFetch = now
    reserveFetchInFlight = true

    lib.callback('d87-weaponshud:getReserveAmmo', false, function(count)
        reserveAmmoCache = count or 0
        reserveFetchInFlight = false
    end, ammoType)

    return reserveAmmoCache
end

local function ResolveAmmoType(weaponHash, weaponData)
    if Framework == 'ox' and weaponData then
        local ammoType = weaponData.ammo
        if not ammoType and weaponData.metadata then
            ammoType = weaponData.metadata.ammo
        end
        return ammoType
    end

    return Config.AmmoTypeMap and Config.AmmoTypeMap[weaponHash]
end

local function GetReserveAmmo(weaponHash, weaponData)
    local ammoType = ResolveAmmoType(weaponHash, weaponData)

    if Framework == 'ox' then
        return GetReserveAmmoOx(ammoType)
    end

    return GetReserveAmmoRemote(ammoType)
end

-- ============================================================================
-- Construye los datos del arma equipada cuando NO estamos en ox_inventory,
-- usando el nativo GetSelectedPedWeapon (funciona con cualquier framework).
-- Durabilidad por defecto 100: sin un estándar común entre frameworks para
-- leer la durabilidad del item equipado sin acoplarse a su UI de inventario,
-- se deja fija salvo que el usuario la conecte a su propio sistema.
-- ============================================================================
local function GetNativeWeaponData(ped)
    local weaponHash = GetSelectedPedWeapon(ped)
    if weaponHash == `WEAPON_UNARMED` then return nil end

    return {
        hash = weaponHash,
        label = (Config.WeaponLabels and Config.WeaponLabels[weaponHash]) or "ARMA",
        durability = 100,
    }
end

local function CancelPendingHide()
    if hideTimer then
        hideTimer = false
    end
end

local function HideHud()
    if not isWeaponEquipped then return end

    isWeaponEquipped = false
    lastClipCount = -1
    isAiming = false

    if not Config.HideWhenUnarmed then
        SendNUIMessage({ action = "hide" })
        return
    end

    local myTimer = {}
    hideTimer = myTimer

    SetTimeout(Config.FadeTimeout or 0, function()
        if hideTimer == myTimer then
            SendNUIMessage({ action = "hide" })
            hideTimer = nil
        end
    end)
end

-- Solo se dispara si ox_inventory está corriendo
RegisterNetEvent('ox_inventory:currentWeapon', function(weaponData)
    currentWeaponData = weaponData
    if not weaponData then
        HideHud()
    end
end)

CreateThread(function()
    while true do
        local sleep = 500
        local ped = PlayerPedId()

        local isPauseOpen = IsPauseMenuActive()
        local isInvOpen = LocalPlayer.state.invOpen or false

        -- En ox usamos el evento (trae metadata rica); en el resto, el nativo.
        local weaponData = nil
        local weaponHash = nil

        if Framework == 'ox' then
            weaponData = currentWeaponData
            weaponHash = weaponData and weaponData.hash
        else
            weaponData = GetNativeWeaponData(ped)
            weaponHash = weaponData and weaponData.hash
        end

        if weaponData and not isPauseOpen and not isInvOpen then
            sleep = 50 -- Aceleramos para que la detección de apuntado sea instantánea

            local weaponGroup = GetWeapontypeGroup(weaponHash)
            isSpecialWeapon = SpecialWeapons[weaponHash] or (weaponGroup == `GROUP_MELEE`) or false

            -- DETECCION DE APUNTADO ACTIVO (Mando o Ratón)
            local isCurrentlyAiming = false
            if not isSpecialWeapon or weaponHash == `WEAPON_STUNGUN` or weaponHash == `WEAPON_RAYPISTOL` then
                HideHudComponentThisFrame(14)

                if IsPlayerFreeAiming(PlayerId()) or IsControlPressed(0, 25) then
                    isCurrentlyAiming = true
                end
            end

            if isCurrentlyAiming ~= isAiming then
                isAiming = isCurrentlyAiming
                SendNUIMessage({ action = "toggle_crosshair", status = isAiming })
            end

            -- 1. Munición en cargador y estado de recarga (siempre nativo, framework-agnóstico)
            local ammoInClip = 0
            local isReloading = false

            if not isSpecialWeapon then
                _, ammoInClip = GetAmmoInClip(ped, weaponHash)
                isReloading = IsPedReloading(ped)

                if ammoInClip == 0 and lastClipCount > 0 then
                    PlaySoundFrontend(-1, "FACTION_TEAM_MENU_SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                end
                lastClipCount = ammoInClip
            end

            -- 2. Durabilidad
            local durabilityPct = 100
            if Framework == 'ox' and weaponData then
                if weaponData.metadata and weaponData.metadata.durability then
                    durabilityPct = math.floor(weaponData.metadata.durability)
                else
                    durabilityPct = math.floor(weaponData.durability or 100)
                end
            else
                durabilityPct = math.floor(weaponData.durability or 100)
            end

            -- 3. Reserva
            local ammoInReserve = 0
            if not isSpecialWeapon then
                ammoInReserve = GetReserveAmmo(weaponHash, weaponData)
            end

            if not isWeaponEquipped then
                isWeaponEquipped = true
                CancelPendingHide()
                SendNUIMessage({
                    action = "show",
                    size = Config.Size,
                    bottom = Config.BottomMargin
                })
            end

            SendNUIMessage({
                action = "update",
                weapon = weaponData.label or "ARMA",
                clip = ammoInClip,
                reserve = ammoInReserve,
                durability = durabilityPct,
                isSpecial = isSpecialWeapon,
                reloading = isReloading
            })
        else
            if isWeaponEquipped then
                HideHud()
            end
            if isPauseOpen or isInvOpen then
                sleep = 250
            end
        end
        Wait(sleep)
    end
end)
