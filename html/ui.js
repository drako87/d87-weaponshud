let lastClipValue = -1;

window.addEventListener('message', function(event) {
    let data = event.data;

    if (data.action === "show") {
        let container = document.getElementById('d87-weapon');
        container.style.display = 'flex';
        
        if (data.bottom) container.style.bottom = `${data.bottom}px`;
        
        let scale = data.size ? data.size : 1.0;
        container.style.transform = `translateX(-50%) scale(${scale})`;
        lastClipValue = -1; 
    } 
    
    else if (data.action === "hide") {
        document.getElementById('d87-weapon').style.display = 'none';
        document.getElementById('d87-crosshair').style.display = 'none'; // Escondemos puntero al guardar
        lastClipValue = -1;
    } 

    // NUEVO: Control de visibilidad del puntero táctico al apuntar
    else if (data.action === "toggle_crosshair") {
        let crosshair = document.getElementById('d87-crosshair');
        if (data.status) {
            crosshair.style.display = 'flex';
        } else {
            crosshair.style.display = 'none';
        }
    }
    
    else if (data.action === "update") {
        let container = document.getElementById('d87-weapon');
        let clipEl = document.getElementById('ammo-clip');
        let reserveEl = document.getElementById('ammo-reserve');
        let dividerEl = document.querySelector('.ammo-divider');
        let ammoContainer = document.querySelector('.ammo-container');
        let crosshairDot = document.querySelector('.crosshair-dot');

        if (data.weapon) {
            document.getElementById('weapon-name').innerText = data.weapon;
        }

        if (data.isSpecial) {
            ammoContainer.style.display = 'none';
            if (crosshairDot) crosshairDot.classList.remove('crosshair-critical');
        } else {
            ammoContainer.style.display = 'flex';

            if (data.reloading) {
                clipEl.innerText = "RECARGANDO...";
                clipEl.className = "reloading-text blink-reload";
                reserveEl.style.display = 'none';
                dividerEl.style.display = 'none';
                if (crosshairDot) crosshairDot.classList.add('crosshair-critical');
            } else {
                reserveEl.style.display = 'inline';
                dividerEl.style.display = 'inline';
                
                let clipStr = data.clip.toString().padStart(2, '0');
                let reserveStr = data.reserve.toString().padStart(3, '0');

                clipEl.innerText = clipStr;
                reserveEl.innerText = reserveStr;

                if (lastClipValue !== -1 && data.clip < lastClipValue) {
                    container.classList.remove('recoil-animation');
                    void container.offsetWidth; 
                    container.classList.add('recoil-animation');
                }
                lastClipValue = data.clip;

                // Control del color de alerta del cargador y del puntero en sintonía
                if (data.clip <= 5) {
                    clipEl.className = "ammo-critical";
                    if (crosshairDot) crosshairDot.classList.add('crosshair-critical'); // Puntero Rojo si quedan pocas balas
                } else {
                    clipEl.className = "";
                    if (crosshairDot) crosshairDot.classList.remove('crosshair-critical'); // Puntero Azul normal
                }
            }
        }

        // 3. Durabilidad
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
