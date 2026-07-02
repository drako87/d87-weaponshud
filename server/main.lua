local DetectedFramework = nil

-- ============================================================================
-- Detecta qué inventario está corriendo en el servidor. Se calcula una sola
-- vez y se reutiliza; GetResourceState no cambia en caliente.
-- ============================================================================
local function DetectFramework()
    if DetectedFramework then return DetectedFramework end

    if Config.Framework ~= 'auto' then
        DetectedFramework = Config.Framework
        return DetectedFramework
    end

    if GetResourceState('ox_inventory') == 'started' then
        DetectedFramework = 'ox'
    elseif GetResourceState('qb-inventory') == 'started' then
        DetectedFramework = 'qb'
    elseif GetResourceState('es_extended') == 'started' then
        DetectedFramework = 'esx'
    else
        DetectedFramework = 'none'
    end

    return DetectedFramework
end

CreateThread(function()
    Wait(1000) -- da tiempo a que otros recursos terminen de iniciar
    print(('^2[D87 Weapons HUD]^7 Framework detectado: ^3%s^7'):format(DetectFramework()))
end)

-- ============================================================================
-- Callback framework-agnóstico: cuánta munición de reserva (item) tiene el
-- jugador. El cliente solo lo usa cuando NO está corriendo ox_inventory,
-- porque ox_inventory se puede consultar directamente y de forma síncrona
-- desde el cliente (sin round-trip al servidor).
-- ============================================================================
lib.callback.register('d87-weaponshud:getReserveAmmo', function(source, ammoType)
    if not ammoType then return 0 end

    local framework = DetectFramework()

    if framework == 'qb' then
        local ok, count = pcall(function()
            return exports['qb-inventory']:GetItemCount(source, ammoType)
        end)
        return (ok and count) or 0
    end

    if framework == 'esx' then
        local ok, count = pcall(function()
            local ESX = exports['es_extended']:getSharedObject()
            local xPlayer = ESX.GetPlayerFromId(source)
            if not xPlayer then return 0 end
            local item = xPlayer.getInventoryItem(ammoType)
            return item and item.count or 0
        end)
        return (ok and count) or 0
    end

    if framework == 'ox' then
        local ok, count = pcall(function()
            return exports.ox_inventory:Search(source, 'count', ammoType)
        end)
        return (ok and count) or 0
    end

    return 0
end)
