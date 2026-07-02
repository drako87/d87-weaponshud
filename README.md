# ⚔️ D87 Weapons HUD

**D87 Weapons HUD** es una interfaz táctica flotante de armamento de diseño minimalista para servidores de rol en FiveM, con soporte multi-framework (**ox_inventory**, **qb-inventory**, **ESX Legacy**).

---

## 📁 Estructura del proyecto

```
d87-weaponshud/
├── client/
│   └── main.lua        -- Lógica principal del HUD (cliente)
├── server/
│   └── main.lua        -- Callback framework-agnóstico de munición de reserva
├── html/
│   ├── ui.html
│   ├── ui.css
│   └── ui.js
├── config.lua
├── fxmanifest.lua
└── README.md
```

---

## 🌟 Características

*   **Estética Flotante Moderna**, sin fondos oscuros pesados.
*   **Multi-framework:** auto-detecta `ox_inventory`, `qb-inventory` o `es_extended` (`Config.Framework = 'auto'`), o puedes fijarlo manualmente.
*   **Contador de Balas de Reserva Real**, leído desde el inventario correspondiente.
*   **Barra de Durabilidad Reactiva** (0%–100%, semáforo verde/amarillo/rojo).
*   **Desvanecimiento con retardo configurable** (`Config.FadeTimeout`) al guardar el arma.

---

## ⚙️ Cómo funciona la detección multi-framework

| Framework | Detección de arma equipada | Munición de reserva | Durabilidad |
|---|---|---|---|
| **ox_inventory** | Evento `ox_inventory:currentWeapon` (metadata completa) | Consulta directa en cliente (`exports.ox_inventory:Search`) | Metadata del item (`metadata.durability`) |
| **qb-inventory** | Nativo `GetSelectedPedWeapon` | Callback al servidor (`exports['qb-inventory']:GetItemCount`), cacheado cada `Config.ReserveAmmoPollInterval` ms | Fija en 100% (ver nota) |
| **ESX Legacy** | Nativo `GetSelectedPedWeapon` | Callback al servidor (`xPlayer.getInventoryItem`), cacheado igual que arriba | Fija en 100% (ver nota) |

**⚠️ Nota importante sobre qb-inventory y ESX:** a diferencia de ox_inventory, no existe un estándar común entre frameworks para leer la durabilidad del arma equipada ni para saber qué item de munición corresponde a qué arma. Por eso:

- `Config.AmmoTypeMap` mapea cada arma al nombre del item de munición de **tu** servidor. Ya trae valores típicos de QBCore de ejemplo — revísalos y ajústalos a los nombres reales de tus items.
- `Config.WeaponLabels` da el nombre legible del arma cuando no hay label de ox_inventory disponible.
- La durabilidad queda fija en 100% en qb/ESX salvo que integres tu propio sistema de durabilidad de armas.

Si usas **ox_inventory**, nada de esto aplica: todo funciona automáticamente igual que antes.

---

## ⚙️ Configuración (`config.lua`)

```lua
Config.Framework = 'auto'   -- 'auto' | 'ox' | 'qb' | 'esx'

Config.Size = 1.0
Config.BottomMargin = 40

Config.HideWhenUnarmed = true
Config.FadeTimeout = 3000

Config.ReserveAmmoPollInterval = 1000  -- ms entre consultas al servidor (solo qb/esx)
Config.AmmoTypeMap = { [`WEAPON_PISTOL`] = 'pistol_ammo', ... }
Config.WeaponLabels = { [`WEAPON_PISTOL`] = 'Pistola', ... }
```

---

## 📥 Instalación

1.  Mueve la carpeta del recurso a tu directorio de recursos y renómbrala `d87-weaponshud`.
2.  Asegúrate de tener **ox_lib** instalado (dependencia obligatoria, se usa para el callback cliente-servidor).
3.  En `server.cfg`, inicia el recurso **debajo** de tu framework y de tu inventario:
    ```cfg
    ensure ox_lib
    ensure d87-weaponshud
    ```
4.  Si usas qb-inventory o ESX, revisa y ajusta `Config.AmmoTypeMap` con los nombres reales de tus items de munición.
5.  Reinicia el servidor o ejecuta `/start d87-weaponshud`.

---

## 🛠️ Changelog

**v1.1.0**
- Soporte multi-framework real: `ox_inventory`, `qb-inventory`, `ESX Legacy`, con auto-detección.
- Nuevo `server/main.lua` con callback `d87-weaponshud:getReserveAmmo` (vía ox_lib), necesario porque `GetItemCount` (qb) y `getInventoryItem` (ESX) son funciones de servidor.
- Detección de arma equipada framework-agnóstica vía `GetSelectedPedWeapon` cuando no se usa ox_inventory.
- Cacheo de munición de reserva (`Config.ReserveAmmoPollInterval`) para no saturar el servidor con callbacks en cada tick.
- Nuevas opciones `Config.AmmoTypeMap` y `Config.WeaponLabels`.

**v1.0.1**
- Corregido: `?.` (sintaxis inválida en Lua) en el cálculo del tipo de munición de reserva.
- `Config.HideWhenUnarmed` y `Config.FadeTimeout` ahora se usan realmente.
- Llamadas a `ox_inventory` protegidas con `pcall`.
- `ui.js` cachea las referencias del DOM en vez de re-consultarlas en cada actualización.
- Reorganización de archivos: `client.lua` → `client/main.lua`.

---

## 👤 Autoría

*   **Recurso:** D87 Weapons HUD
*   **Autor Oficial:** `Drako87/Dracatt`
