let lastClipValue = -1;

// ============================================================================
// Referencias del DOM cacheadas una única vez al cargar, en lugar de
// re-consultarlas en cada mensaje "update" (que puede llegar cada 50ms).
// ============================================================================
const els = {};

window.addEventListener('DOMContentLoaded', function () {
    els.crosshair = document.getElementById('d87-crosshair');
    els.crosshairDot = document.querySelector('.crosshair-dot');
    els.container = document.getElementById('d87-weapon');
    els.weaponName = document.getElementById('weapon-name');
    els.clip = document.getElementById('ammo-clip');
    els.reserve = document.getElementById('ammo-reserve');
    els.divider = document.querySelector('.ammo-divider');
    els.ammoContainer = document.querySelector('.ammo-container');
    els.durabilityBar = document.getElementById('durability-bar');
});

window.addEventListener('message', function (event) {
    const data = event.data;

    switch (data.action) {
        case 'show':
            handleShow(data);
            break;
        case 'hide':
            handleHide();
            break;
        case 'toggle_crosshair':
            handleToggleCrosshair(data);
            break;
        case 'update':
            handleUpdate(data);
            break;
    }
});

function handleShow(data) {
    els.container.style.display = 'flex';

    if (data.bottom) els.container.style.bottom = `${data.bottom}px`;

    const scale = data.size ? data.size : 1.0;
    els.container.style.transform = `translateX(-50%) scale(${scale})`;
    lastClipValue = -1;
}

function handleHide() {
    els.container.style.display = 'none';
    els.crosshair.style.display = 'none'; // Escondemos puntero al guardar
    lastClipValue = -1;
}

function handleToggleCrosshair(data) {
    els.crosshair.style.display = data.status ? 'flex' : 'none';
}

function handleUpdate(data) {
    if (data.weapon) {
        els.weaponName.innerText = data.weapon;
    }

    if (data.isSpecial) {
        els.ammoContainer.style.display = 'none';
        if (els.crosshairDot) els.crosshairDot.classList.remove('crosshair-critical');
    } else {
        els.ammoContainer.style.display = 'flex';

        if (data.reloading) {
            updateReloadingState();
            if (els.crosshairDot) els.crosshairDot.classList.add('crosshair-critical');
        } else {
            updateAmmoState(data);
        }
    }

    updateDurability(data.durability);
}

function updateReloadingState() {
    els.clip.innerText = "RECARGANDO...";
    els.clip.className = "reloading-text blink-reload";
    els.reserve.style.display = 'none';
    els.divider.style.display = 'none';
}

function updateAmmoState(data) {
    els.reserve.style.display = 'inline';
    els.divider.style.display = 'inline';

    const clipStr = data.clip.toString().padStart(2, '0');
    const reserveStr = data.reserve.toString().padStart(3, '0');

    els.clip.innerText = clipStr;
    els.reserve.innerText = reserveStr;

    if (lastClipValue !== -1 && data.clip < lastClipValue) {
        els.container.classList.remove('recoil-animation');
        void els.container.offsetWidth;
        els.container.classList.add('recoil-animation');
    }
    lastClipValue = data.clip;

    // Control del color de alerta del cargador y del puntero en sintonía
    if (data.clip <= 5) {
        els.clip.className = "ammo-critical";
        if (els.crosshairDot) els.crosshairDot.classList.add('crosshair-critical');
    } else {
        els.clip.className = "";
        if (els.crosshairDot) els.crosshairDot.classList.remove('crosshair-critical');
    }
}

function updateDurability(durability) {
    if (!els.durabilityBar || durability === undefined) return;

    els.durabilityBar.style.width = durability + "%";

    if (durability > 60) {
        els.durabilityBar.style.backgroundColor = "#4ade80";
        els.durabilityBar.classList.remove('blink-critical');
    } else if (durability > 25) {
        els.durabilityBar.style.backgroundColor = "#facc15";
        els.durabilityBar.classList.remove('blink-critical');
    } else {
        els.durabilityBar.style.backgroundColor = "#ef4444";
        els.durabilityBar.classList.add('blink-critical');
    }
}
