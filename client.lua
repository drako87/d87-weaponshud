local isWeaponEquipped = false
local currentWeaponData = nil
local isBike = false
local isSpecialWeapon = false
local lastClipCount = -1
local isAiming = false

local SpecialWeapons = {
    [`WEAPON_STUNGUN`] = true,
    [`WEAPON_STUNGUN_MP`] = true,
    [`WEAPON_RAYPISTOL`] = true,
    [`WEAPON_RAYCARBINE`] = true,
    [`WEAPON_RAYMINIGUN`] = true,
}

CreateThread(function()
    print('^2[D87 Weapons HUD]^7 Inicializado con éxito.')
end)

RegisterNetEvent('ox_inventory:currentWeapon', function(weaponData)
    currentWeaponData = weaponData
    if not weaponData then
        if isWeaponEquipped then
            isWeaponEquipped = false
            lastClipCount = -1
            isAiming = false
            SendNUIMessage({ action = "hide" })
        end
    end
end)

CreateThread(function()
    while true do
        local sleep = 500
        local ped = PlayerPedId()
        
        local isPauseOpen = IsPauseMenuActive()
        local isInvOpen = LocalPlayer.state.invOpen or false

        if currentWeaponData and not isPauseOpen and not isInvOpen then
            sleep = 50 -- Aceleramos a 50ms para que la detección de apuntado sea instantánea al pulsar el clic
            
            local weaponHash = currentWeaponData.hash
            local weaponGroup = GetWeapontypeGroup(weaponHash)
            isSpecialWeapon = SpecialWeapons[weaponHash] or (weaponGroup == `GROUP_MELEE`) or false

            -- DETECCION DE APUNTADO ACTIVO (Mando o Ratón)
            local isCurrentlyAiming = false
            if not isSpecialWeapon or weaponHash == `WEAPON_STUNGUN` or weaponHash == `WEAPON_RAYPISTOL` then
                -- Desactivamos la retícula nativa fea de GTA V en cada frame si está apuntando
                HideHudComponentThisFrame(14) 
                
                -- Detectamos si está apuntando de verdad
                if IsPlayerFreeAiming(PlayerId()) or IsControlPressed(0, 25) then
                    isCurrentlyAiming = true
                end
            end

            -- Si cambia el estado de apuntado, avisamos a la pantalla
            if isCurrentlyAiming ~= isAiming then
                isAiming = isCurrentlyAiming
                SendNUIMessage({ action = "toggle_crosshair", status = isAiming })
            end

            -- 1. Munición en cargador y estado de recarga
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
                isAiming = false
                SendNUIMessage({ action = "hide" })
                if isPauseOpen or isInvOpen then
                    sleep = 250
                end
            end
        end
        Wait(sleep)
    end
end)
