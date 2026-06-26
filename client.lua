local isWeaponEquipped = false

-- Tabla de hashes de armas especiales de fuego que no usan munición convencional
local SpecialWeapons = {
    [`WEAPON_STUNGUN`] = true,       -- Taser clásico
    [`WEAPON_STUNGUN_MP`] = true,    -- Taser multijugador avanzado
    [`WEAPON_RAYPISTOL`] = true,     -- Up-n-Atomizer
    [`WEAPON_RAYCARBINE`] = true,    -- Unholy Hellbringer
    [`WEAPON_RAYMINIGUN`] = true,    -- Widowmaker
}

-- Inicialización en consola
CreateThread(function()
    print('^4==================================================================^7')
    print('^2[D87 Weapons HUD]^7 Inicializado con éxito.')
    print('^4==================================================================^7')
end)

-- Hilo principal de monitorización táctica y escaneo adaptativo multifunción
CreateThread(function()
    while true do
        local sleep = 500 
        local ped = PlayerPedId()
        local _, weaponHash = GetCurrentPedWeapon(ped, true)

        -- Verificamos si el jugador tiene un arma válida equipada (evitando los puños limpios)
        if weaponHash ~= `WEAPON_UNARMED` and weaponHash ~= 0 then
            sleep = 120 

            -- DETECCIÓN DE ARMAS SIN MUNICIÓN (Especiales + Cuerpo a cuerpo)
            -- Obtenemos el tipo de grupo nativo al que pertenece el objeto
            local weaponGroup = GetWeapontypeGroup(weaponHash)
            -- Comprobamos si es un arma cuerpo a cuerpo (Melee) o está en la lista de armas especiales
            local isSpecialWeapon = SpecialWeapons[weaponHash] or (weaponGroup == `GROUP_MELEE`) or false

            -- 1. Obtener munición actual del cargador (Solo si no es especial/cuerpo a cuerpo)
            local ammoInClip = 0
            if not isSpecialWeapon then
                _, ammoInClip = GetAmmoInClip(ped, weaponHash)
            end

            -- 2. Conexión avanzada con ox_inventory para Nombre, Durabilidad y Reserva Real
            local weaponName = "ARMA"
            local durabilityPct = 100
            local ammoInReserve = 0

            if GetResourceState('ox_inventory') == 'started' then
                local currentWeaponData = exports.ox_inventory:getCurrentWeapon()
                
                if currentWeaponData then
                    weaponName = currentWeaponData.label or "ARMA"
                    
                    -- Corrección de la durabilidad (Metadatos de Ox para Qbox)
                    if currentWeaponData.metadata and currentWeaponData.metadata.durability then
                        durabilityPct = math.floor(currentWeaponData.metadata.durability)
                    else
                        durabilityPct = math.floor(currentWeaponData.durability or 100)
                    end
                    
                    -- Buscamos las balas de reserva solo si NO es de cuerpo a cuerpo / especial
                    if not isSpecialWeapon then
                        local ammoType = currentWeaponData.ammo or currentWeaponData.metadata?.ammo
                        if ammoType then
                            local count = exports.ox_inventory:Search('count', ammoType)
                            ammoInReserve = count or 0
                        end
                    end
                end
            else
                if not isSpecialWeapon then
                    local totalAmmo = GetAmmoInPedWeapon(ped, weaponHash)
                    ammoInReserve = totalAmmo - ammoInClip
                    if ammoInReserve < 0 then ammoInReserve = 0 end
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

            -- Enviamos los datos reales sincronizados al JavaScript
            SendNUIMessage({
                action = "update",
                weapon = weaponName,
                clip = ammoInClip,
                reserve = ammoInReserve,
                durability = durabilityPct,
                isSpecial = isSpecialWeapon -- Avisamos al JS para ocultar las balas en especiales y cuerpo a cuerpo
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
