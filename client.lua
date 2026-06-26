local CurrentFramework = nil
local isWeaponEquipped = false

-- Tabla de hashes de armas especiales de fuego que no usan munición convencional
local SpecialWeapons = {
    [`WEAPON_STUNGUN`] = true,       -- Taser clásico
    [`WEAPON_STUNGUN_MP`] = true,    -- Taser multijugador avanzado
    [`WEAPON_RAYPISTOL`] = true,     -- Up-n-Atomizer
    [`WEAPON_RAYCARBINE`] = true,    -- Unholy Hellbringer
    [`WEAPON_RAYMINIGUN`] = true,    -- Widowmaker
}

-- Función interna para detectar de forma automática el Framework activo
local function DetectFramework()
    if Config.Framework ~= 'auto' then
        CurrentFramework = Config.Framework
        return
    end

    if GetResourceState('qbx_core') == 'started' then
        CurrentFramework = 'qbox'
    elseif GetResourceState('qb-core') == 'started' then
        CurrentFramework = 'qb-core'
    elseif GetResourceState('es_extended') == 'started' then
        CurrentFramework = 'esx'
    else
        CurrentFramework = 'standalone'
    end
end

-- Inicialización al cargar el recurso
CreateThread(function()
    DetectFramework()
    print('^4==================================================================^7')
    print('^2[D87 Weapons HUD]^7 Inicializado con éxito.')
    print(('^2[D87 Weapons HUD]^7 Framework activo detectado: ^5%s^7'):format(CurrentFramework))
    print('^4==================================================================^7')
end)

-- Hilo principal de monitorización táctica universal
CreateThread(function()
    while true do
        local sleep = 500 
        local ped = PlayerPedId()
        local _, weaponHash = GetCurrentPedWeapon(ped, true)

        -- Verificamos si el jugador tiene un arma válida equipada
        if weaponHash ~= `WEAPON_UNARMED` and weaponHash ~= 0 then
            sleep = 120 

            local weaponGroup = GetWeapontypeGroup(weaponHash)
            local isSpecialWeapon = SpecialWeapons[weaponHash] or (weaponGroup == `GROUP_MELEE`) or false

            -- 1. Obtener munición actual del cargador (Nativa de GTA V)
            local ammoInClip = 0
            if not isSpecialWeapon then
                _, ammoInClip = GetAmmoInClip(ped, weaponHash)
            end

            -- 2. Variables base de extracción
            local weaponName = "ARMA"
            local durabilityPct = 100
            local ammoInReserve = 0

            -- MÓDULO 1: Extracción para entornos basados en Qbox / Ox
            if CurrentFramework == 'qbox' or GetResourceState('ox_inventory') == 'started' then
                local currentWeaponData = exports.ox_inventory:getCurrentWeapon()
                if currentWeaponData then
                    weaponName = currentWeaponData.label or "ARMA"
                    if currentWeaponData.metadata and currentWeaponData.metadata.durability then
                        durabilityPct = math.floor(currentWeaponData.metadata.durability)
                    else
                        durabilityPct = math.floor(currentWeaponData.durability or 100)
                    end
                    if not isSpecialWeapon then
                        local ammoType = currentWeaponData.ammo or currentWeaponData.metadata?.ammo
                        if ammoType then
                            ammoInReserve = exports.ox_inventory:Search('count', ammoType) or 0
                        end
                    end
                end

            -- MÓDULO 2: Extracción para entornos basados en QBCore nativo
            elseif CurrentFramework == 'qb-core' and GetResourceState('qb-core') == 'started' then
                local QBCore = exports['qb-core']:GetCoreObject()
                local playerData = QBCore.Functions.GetPlayerData()
                if playerData and playerData.items then
                    -- Buscamos el arma equipada en las ranuras del jugador
                    for _, item in pairs(playerData.items) do
                        if item and item.info and item.info.quality and item.hash == weaponHash then
                            weaponName = item.label or "ARMA"
                            durabilityPct = math.floor(item.info.quality or 100)
                            break
                        end
                    end
                end
                if not isSpecialWeapon then
                    -- Fallback de munición nativa para QBCore si no usa items de balas específicos
                    local totalAmmo = GetAmmoInPedWeapon(ped, weaponHash)
                    ammoInReserve = totalAmmo - ammoInClip
                end

            -- MÓDULO 3: Extracción para entornos basados en ESX
            elseif CurrentFramework == 'esx' then
                -- En ESX básico las armas no tienen durabilidad nativa, por lo que hereda 100%
                weaponName = GetLabelText(GetWeapontypeLabel(weaponHash)) or "ARMA"
                durabilityPct = 100
                if not isSpecialWeapon then
                    local totalAmmo = GetAmmoInPedWeapon(ped, weaponHash)
                    ammoInReserve = totalAmmo - ammoInClip
                end

            -- MÓDULO 4: Modo Standalone (Sin Framework)
            else
                weaponName = "ARMA EQUIPADA"
                durabilityPct = 100
                if not isSpecialWeapon then
                    local totalAmmo = GetAmmoInPedWeapon(ped, weaponHash)
                    ammoInReserve = totalAmmo - ammoInClip
                end
            end

            -- Evitar valores negativos en la reserva
            if ammoInReserve < 0 then ammoInReserve = 0 end

            if not isWeaponEquipped then
                isWeaponEquipped = true
                SendNUIMessage({
                    action = "show",
                    size = Config.Size,
                    bottom = Config.BottomMargin
                })
            end

            -- Enviamos los datos procesados a la interfaz
            SendNUIMessage({
                action = "update",
                weapon = weaponName,
                clip = ammoInClip,
                reserve = ammoInReserve,
                durability = durabilityPct,
                isSpecial = isSpecialWeapon
            })
        else
            if isWeaponEquipped then
                isWeaponEquipped = false
                SendNUIMessage({ action = "hide" })
            end
        end
        Wait(sleep)
    end
end)
