# ⚔️ D87 Weapons HUD

**D87 Weapons HUD** es una interfaz táctica flotante de armamento de diseño minimalista y calidad premium para servidores de rol en la plataforma FiveM. Diseñada con un enfoque compacto y limpio, se integra perfectamente en la pantalla de los jugadores ofreciendo información esencial de combate en tiempo real sin saturar la vista.

Desarrollado para ofrecer el máximo rendimiento e interoperabilidad, el script cuenta con un motor adaptativo inteligente que ajusta sus componentes dinámicamente según la naturaleza de cada equipamiento.

---

## 🌟 Características Destacadas

*   **Estética Flotante Moderna:** Diseño minimalista sin fondos oscuros pesados o marcos pixelados. Cuenta con fuentes sans-serif nítidas y sombreados de relieve de alta legibilidad sobre cualquier entorno gráfico.
*   **Conectividad Avanzada con ox_inventory:** Sincronización nativa y directa con el inventario de Qbox. Extrae las etiquetas comerciales legibles de los items (Ej: `Pistola de combate`, `Cuchillo de caza`) de forma automática.
*   **Contador de Balas de Reserva Real:** Soluciona el problema tradicional de FiveM mapeando la munición almacenada como items físicos dentro de la mochila, mostrando la reserva exacta que el jugador posee.
*   **Barra de Durabilidad Reactiva:** Indicador horizontal integrado que monitoriza la vida útil restante del objeto (0% a 100%). Cambia automáticamente de color bajo una escala semáforo (Verde -> Amarillo -> Rojo Crítico) e incluye un parpadeo intermitente si el arma está próxima a romperse.

---

## 🛠️ Interfaz Adaptativa Inteligente

El script cuenta con un algoritmo de filtrado por grupos y hashes nativos de GTA V que reestructura el HUD en tiempo real:
*   **Armas de Fuego Convencionales:** Muestra el nombre, el cargador activo, la reserva total de la mochila y la barra de durabilidad.
*   **Armamento Especial (Taser, Up-n-Atomizer):** Oculta automáticamente los campos de munición física para adaptarse a sistemas de recarga por batería, manteniendo a la vista solo el nombre y su estado de conservación.
*   **Armas Cuerpo a Cuerpo (Cuchillos, Bates, Porras):** Detecta la clase *Melee* de forma nativa escondiendo los paneles numéricos de proyectiles y enfocándose en la durabilidad del objeto por impacto.
*   **Desvanecimiento Inteligente (Fade Out):** El HUD permanece completamente oculto si el jugador se encuentra desarmado o con las manos vacías para maximizar la inmersión de rol.

---

## ⚡ Ventajas Técnicas

*   **Rendimiento Optimizado:** Diseñado con hilos de ejecución dinámicos. El bucle se relaja cuando el jugador está desarmado y se acelera solo al desenfundar, manteniendo un consumo imperceptible de **0.00 ms a 0.01 ms**.
*   **Compatibilidad Multi-Resolución:** Posicionado en la parte inferior central mediante físicas absolutas de CSS (`transform`), garantizando un centrado perfecto tanto en pantallas tradicionales de 1080p como en monitores UltraWide, 2K y 4K.
*   **Independencia de Red:** Carga local de assets estructurados, evitando peticiones a CDNs externas que puedan generar bloqueos por políticas estrictas de seguridad (MIME Type errors).

---

## ⚙️ Configuración Ajustable (`config.lua`)

Permite calibrar la interfaz de forma externa y rápida a través de variables sencillas:

```lua
Config = {}

-- URL de tu repositorio público en GitHub para el control de versiones
Config.GitHubRepo = 'https://github.com/drako87/d87-weaponshud'

-- CONFIGURACIÓN DE POSICIÓN Y TAMAÑO VISUAL
Config.Size = 1.0            -- Escala general del HUD (0.8 = Más chico, 1.2 = Más grande)
Config.BottomMargin = 40     -- Distancia en píxeles desde el borde inferior de la pantalla

-- AJUSTES DE COMPORTAMIENTO
Config.HideWhenUnarmed = true -- Ocultar HUD si el jugador no lleva armas
Config.FadeTimeout = 3000     -- Tiempo en milisegundos antes de desvanecer la interfaz
```

---

## 📥 Instalación

1.  Mueve la carpeta del recurso a tu directorio de servidores y asegúrate de renombrarla exactamente como `d87-weaponshud`.
2.  Abre tu archivo de configuración general `server.cfg`.
3.  Asegúrate de inicializar el recurso **debajo** de tu framework y del script `ox_inventory` añadiendo la siguiente línea:
    ```cfg
    ensure d87-weaponshud
    ```
4.  Guarda los cambios, reinicia el servidor o ejecuta `/start d87-weaponshud` desde tu consola.

---

## 👤 Autoría y Créditos

*   **Recurso:** D87 Weapons HUD
*   **Autor Oficial:** `Drako87/Dracatt`
*   **Framework Base:** Qbox Ecosystem & Ox Resources.
