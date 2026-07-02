Config = {}

-- SELECCIÓN DE FRAMEWORK
Config.Framework = 'auto'    -- Opciones: 'auto' (detecta solo), 'qbox', 'qb-core', 'esx'

-- URL de tu repositorio en GitHub para el futuro comprobador de versiones
Config.GitHubRepo = 'https://github.com/drako87/d87-weaponshud'

-- CONFIGURACIÓN DE POSICIÓN Y TAMAÑO VISUAL (ABAJO EN MEDIO)
Config.Size = 1.0            -- Escala general del HUD (1.0 = Original, 0.8 = Más pequeño)
Config.BottomMargin = 40     -- Distancia desde el borde INFERIOR de la pantalla (en píxeles)

-- AJUSTES DE COMPORTAMIENTO
Config.HideWhenUnarmed = true -- Ocultar por completo el HUD si el jugador no lleva armas en la mano
Config.FadeTimeout = 3000     -- Tiempo en milisegundos que tarda en ocultarse tras guardar el arma

-- ============================================================================
-- SOLO SE USA CUANDO EL FRAMEWORK DETECTADO/CONFIGURADO NO ES 'ox'
-- (ox_inventory ya trae esta información en los metadatos del arma)
-- ============================================================================

-- Cada cuánto (ms) se le pregunta al servidor por la munición de reserva
-- en qb-inventory/ESX. No lo bajes demasiado: es una petición al servidor.
Config.ReserveAmmoPollInterval = 1000

-- Mapeo hash de arma -> nombre del item de munición en tu inventario.
-- Ajusta estos nombres a los que uses realmente en qb-inventory / ESX.
Config.AmmoTypeMap = {
    [`WEAPON_PISTOL`]        = 'pistol_ammo',
    [`WEAPON_COMBATPISTOL`]  = 'pistol_ammo',
    [`WEAPON_APPISTOL`]      = 'pistol_ammo',
    [`WEAPON_PISTOL50`]      = 'pistol_ammo',
    [`WEAPON_SMG`]           = 'smg_ammo',
    [`WEAPON_MICROSMG`]      = 'smg_ammo',
    [`WEAPON_ASSAULTRIFLE`]  = 'rifle_ammo',
    [`WEAPON_CARBINERIFLE`]  = 'rifle_ammo',
    [`WEAPON_SPECIALCARBINE`]= 'rifle_ammo',
    [`WEAPON_PUMPSHOTGUN`]   = 'shotgun_ammo',
    [`WEAPON_SAWNOFFSHOTGUN`]= 'shotgun_ammo',
    [`WEAPON_SNIPERRIFLE`]   = 'rifle_ammo',
}

-- Etiquetas legibles para cuando NO estás en ox_inventory
-- (ox_inventory ya trae el label en currentWeaponData.label)
Config.WeaponLabels = {
    [`WEAPON_PISTOL`]        = 'Pistola',
    [`WEAPON_COMBATPISTOL`]  = 'Pistola de Combate',
    [`WEAPON_APPISTOL`]      = 'Pistola AP',
    [`WEAPON_PISTOL50`]      = 'Pistola .50',
    [`WEAPON_SMG`]           = 'Subfusil',
    [`WEAPON_MICROSMG`]      = 'Micro Subfusil',
    [`WEAPON_ASSAULTRIFLE`]  = 'Rifle de Asalto',
    [`WEAPON_CARBINERIFLE`]  = 'Carabina',
    [`WEAPON_SPECIALCARBINE`]= 'Carabina Especial',
    [`WEAPON_PUMPSHOTGUN`]   = 'Escopeta de Bombeo',
    [`WEAPON_SAWNOFFSHOTGUN`]= 'Escopeta Recortada',
    [`WEAPON_SNIPERRIFLE`]   = 'Rifle de Francotirador',
    [`WEAPON_KNIFE`]         = 'Cuchillo',
    [`WEAPON_BAT`]           = 'Bate',
}

