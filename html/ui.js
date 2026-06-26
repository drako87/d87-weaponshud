let lastClipValue = -1;

window.addEventListener('message', function(event) {
    let data = event.data;

    if (data.action === "show") {
        let container = document.getElementById('d87-weapon');
        container.style.display = 'flex';
        
        if (data.bottom) container.style.bottom = `${data.bottom}px`;
        
        let scale = data.size ? data.size : 1.0;
        container.style.transform = `translateX(-50%) scale(${scale})`;
        lastClipValue = -1; // Resetear contador al desenfundar
    } 
    
    else if (data.action === "hide") {
        document.getElementById('d87-weapon').style.display = 'none';
        lastClipValue = -1;
    } 
    
    else if (data.action === "update") {
        let container = document.getElementById('d87-weapon');
        let clipEl = document.getElementById('ammo-clip');
        let reserveEl = document.getElementById('ammo-reserve');
        let dividerEl = document.querySelector('.ammo-divider');
        let ammoContainer = document.querySelector('.ammo-container');

        if (data.weapon) {
            document.getElementById('weapon-name').innerText = data.weapon;
        }

        if (data.isSpecial) {
            ammoContainer.style.display = 'none';
        } else {
            ammoContainer.style.display = 'flex';

            // OPTIMIZACIÓN 2: Lógica visual reactiva de recarga (RELOAD)
            if (data.reloading) {
                clipEl.innerText = "RECARGANDO...";
                clipEl.className = "reloading-text blink-reload";
                reserveEl.style.display = 'none';
                dividerEl.style.display = 'none';
            } else {
                // Estado de disparo normal
                reserveEl.style.display = 'inline';
                dividerEl.style.display = 'inline';
                
                let clipStr = data.clip.toString().padStart(2, '0');
                let reserveStr = data.reserve.toString().padStart(3, '0');

                clipEl.innerText = clipStr;
                reserveEl.innerText = reserveStr;

                // OPTIMIZACIÓN 3: Disparar la animación de retroceso (Recoil) si bajan las balas
                if (lastClipValue !== -1 && data.clip < lastClipValue) {
                    container.classList.remove('recoil-animation');
                    void container.offsetWidth; // Truco de JS para resetear y forzar el renderizado de la animación
                    container.classList.add('recoil-animation');
                }
                lastClipValue = data.clip;

                if (data.clip <= 5) {
                    clipEl.className = "ammo-critical";
                } else {
                    clipEl.className = "";
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
