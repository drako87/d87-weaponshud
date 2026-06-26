local isWeaponEquipped = false
local currentWeaponData = nil
local isBike = false
local isSpecialWeapon = false
local lastClipCount = -1

-- Tabla de hashes de armas especiales
local SpecialWeapons = {
    [`WEAPON_STUNGUN`] = true,
    [`WEAPON_STUNGUN_MP`] = true,
    [`WEAPON_RAYPISTOL`] = true,
    [`WEAPON_RAYCARBINE`] = true,
    [`WEAPON_RAYMINIGUN`] = true,
}

-- Inicialización
CreateThread(function()
    print('^4==================================================================^7')
    print('^2[D87 Weapons HUD]^7 Inicializado con éxito.')
    print('^4==================================================================^7')
end)

-- OPTIMIZACIÓN 1: Evento reactivo de ox_inventory (Adiós al bucle de escaneo de item)
RegisterNetEvent('ox_inventory:currentWeapon', function(weaponData)
    currentWeaponData = weaponData
    if not weaponData then
        if isWeaponEquipped then
            isWeaponEquipped = false
            lastClipCount = -1
            SendNUIMessage({ action = "hide" })
        end
    end
end)

-- Hilo Principal Avanzado de Telemetría (0.00ms en reposo)
CreateThread(function()
    while true do
        local sleep = 500
        local ped = PlayerPedId()
        
        -- OPTIMIZACIÓN 4: Ocultar en pausa o con inventario abierto
        local isPauseOpen = IsPauseMenuActive()
        local isInvOpen = false
        if GetResourceState('ox_inventory') == 'started' then
            isInvOpen = exports.ox_inventory:isInventoryOpen()
        end

        if currentWeaponData and not isPauseOpen and not isInvOpen then
            sleep = 100 -- Se activa solo cuando tienes un arma en las manos
            
            local weaponHash = currentWeaponData.hash
            local weaponGroup = GetWeapontypeGroup(weaponHash)
            isSpecialWeapon = SpecialWeapons[weaponHash] or (weaponGroup == `GROUP_MELEE`) or false

            -- 1. Munición en cargador y estado de recarga
            local ammoInClip = 0
            local isReloading = false
            
            if not isSpecialWeapon then
                _, ammoInClip = GetAmmoInClip(ped, weaponHash)
                isReloading = IsPedReloading(ped) -- OPTIMIZACIÓN 2: Detectar recarga
                
                -- OPTIMIZACIÓN 5: Sonido metálico al quedarse sin balas
                if ammoInClip == 0 and lastClipCount > 0 then
                    PlaySoundFrontend(-1, "FACTION_TEAM_MENU_SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                end
                lastClipCount = ammoInClip
            end

            -- 2. Durabilidad y Reserva
            local durabilityPct = 100
            local ammoInReserve = 0

            if currentWeaponData.metadata and currentWeaponData.metadata.durability then
                durabilityPct = math.floor(currentWeaponData.metadata.durability)
            else
                durabilityPct = math.floor(currentWeaponData.durability or 100)
            end
            
            if not isSpecialWeapon then
                local ammoType = currentWeaponData.ammo or currentWeaponData.metadata?.ammo
                if ammoType and GetResourceState('ox_inventory') == 'started' then
                    ammoInReserve = exports.ox_inventory:Search('count', ammoType) or 0
                end
            end

            if not isWeaponEquipped then
                isWeaponEquipped = true
                local veh = GetVehiclePedIsIn(ped, false)
                if veh ~= 0 then
                    local vehClass = GetVehicleClass(veh)
                    isBike = (vehClass == 8 or vehClass == 13 or vehClass == 3 or vehClass == 11)
                else
                    isBike = false
                end

                SendNUIMessage({
                    action = "show",
                    size = Config.Size,
                    bottom = Config.BottomMargin
                })
            end

            SendNUIMessage({
                action = "update",
                weapon = currentWeaponData.label or "ARMA",
                clip = ammoInClip,
                reserve = ammoInReserve,
                durability = durabilityPct,
                isSpecial = isSpecialWeapon,
                reloading = isReloading
            })
        else
            if isWeaponEquipped or isPauseOpen or isInvOpen then
                isWeaponEquipped = false
                lastClipCount = -1
                SendNUIMessage({ action = "hide" })
                if isPauseOpen or isInvOpen then
                    sleep = 200 -- Relajamos el hilo si el usuario está en menús
                end
            end
        end
        Wait(sleep)
    end
end)
