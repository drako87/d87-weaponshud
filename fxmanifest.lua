fx_version 'cerulean'
game 'gta5'

author 'Drako87/Dracatt'
description 'D87 Weapons HUD - Interfaz táctica de armamento minimalista premium'
version '1.1.0'

-- Inicialización de ox_lib para soporte nativo (usado también por el
-- callback framework-agnóstico de munición de reserva)
shared_script '@ox_lib/init.lua'

shared_script 'config.lua'
client_script 'client/main.lua'
server_script 'server/main.lua'

ui_page 'html/ui.html'

files {
    'html/ui.html',
    'html/ui.css',
    'html/ui.js'
}
