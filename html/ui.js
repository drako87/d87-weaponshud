// Variables globales internas para almacenar los límites recibidos del Config
let currentFuelLimit = 20;
let currentEngineLimit = 30;
let storedVehicleName = "Cargando...";

window.addEventListener('message', function(event) {
    let data = event.data;

    if (data.action === "show") {
        let container = document.getElementById('d87-weapon');
        container.style.display = 'flex';
        
        if (data.bottom) container.style.bottom = `${data.bottom}px`;
        
        let scale = data.size ? data.size : 1.0;
        container.style.transform = `translateX(-50%) scale(${scale})`;
    } 
    
    else if (data.action === "hide") {
        document.getElementById('d87-weapon').style.display = 'none';
    } 
    
    else if (data.action === "update") {
        // 1. Actualizar el nombre real del arma
        if (data.weapon) {
            document.getElementById('weapon-name').innerText = data.weapon;
        }

        // ADAPTACIÓN DE MUNICIÓN INTELIGENTE (NUEVO)
        let ammoContainer = document.querySelector('.ammo-container');
        if (data.isSpecial) {
            // Si es un arma especial (Taser/Up-n-Atomizer), escondemos los números por completo
            ammoContainer.style.display = 'none';
        } else {
            // Si es un arma normal, nos aseguramos de que el contenedor de balas sea visible
            ammoContainer.style.display = 'flex';

            // Dar formato al contador de munición habitual
            let clipStr = data.clip.toString().padStart(2, '0');
            let reserveStr = data.reserve.toString().padStart(3, '0');

            let clipEl = document.getElementById('ammo-clip');
            clipEl.innerText = clipStr;
            document.getElementById('ammo-reserve').innerText = reserveStr;

            // Alerta si quedan pocas balas en el cargador actual
            if (data.clip <= 5) {
                clipEl.classList.add('ammo-critical');
            } else {
                clipEl.classList.remove('ammo-critical');
            }
        }

        // 3. Control y color de la barra de Durabilidad del Item (ox_inventory)
        let dBar = document.getElementById('durability-bar');
        if (dBar && data.durability !== undefined) {
            dBar.style.width = data.durability + "%";

            if (data.durability > 60) {
                dBar.style.backgroundColor = "#4ade80"; 
                dBar.classList.remove('blink-critical');
            } else if (data.durability > 25) {
                dBar.style.backgroundColor = "#facc15"; 
                dBar.classList.remove('blink-critical');
            } else {
                dBar.style.backgroundColor = "#ef4444"; 
                dBar.classList.add('blink-critical');
            }
        }
    }
});
