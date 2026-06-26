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
