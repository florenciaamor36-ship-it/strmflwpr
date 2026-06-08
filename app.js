
// ============================================
// STREAMFLOW PRO - CORE ENGINE (DASHBOARD)
// ============================================

const firebaseConfig = {
    apiKey: "AIzaSyB8jYiHFiD_-MTHUQr2c3WU_b84RAPonvA",
    authDomain: "stream-flow-pro.firebaseapp.com",
    projectId: "stream-flow-pro",
    storageBucket: "stream-flow-pro.firebasestorage.app",
    messagingSenderId: "837367317965",
    appId: "1:837367317965:web:00f039846e2a3646d87084"
};

// Inicializar Firebase
if (!firebase.apps.length) firebase.initializeApp(firebaseConfig);
const auth = firebase.auth();
const db = firebase.firestore();

// ============ CONFIGURACIÓN GLOBAL ============
const WHATSAPP_TOKEN_NUMBER = "5492236785329";
const DIAS_PRUEBA_GRATIS = 3;
const DIAS_TOKEN = 30;

// ============ VARIABLES GLOBALES ============
let perfiles = [];
let currentUser = null;
let unsubscribeFirestore = null;
let planEstado = "demo"; // "demo", "token", "bloqueado"
let diasPruebaRestantes = 3;
let ordenAsc = true;
let notificationsEnabled = true;
let kioscoMode = false;
let pendingVentaId = null;
let editandoId = null;
let filtroTimeout = null;

// ============ AUTH REDIRECTION ============
auth.onAuthStateChanged(async (user) => {
    if (user) {
        currentUser = user;
        initApp();
    } else {
        window.location.href = 'login.html';
    }
});

async function initApp() {
    showLoader("Iniciando...");
    try {
        await verificarSuscripcion(currentUser.uid);
        await cargarPerfiles();
        iniciarListenerFirestore(currentUser.uid);
        cargarConfigLocal();
        actualizarTodo();
        if(notificationsEnabled) mostrarAvisoVencimientos();
        
        // Branding Admin
        if (currentUser.email === "florenciaamor36@gmail.com") {
            const pPlan = document.getElementById('perfilPlan');
            if(pPlan) pPlan.innerHTML = '<i class="fas fa-shield-alt" style="color:#f5af19"></i> ADMIN PRO';
        }
    } catch (e) {
        console.error("Error initApp:", e);
    } finally {
        hideLoader();
    }
}

// ============ FIRESTORE LOGIC ============
async function cargarPerfiles() {
    if(!currentUser) return;
    const snap = await db.collection("usuarios").doc(currentUser.uid).collection("perfiles").get();
    perfiles = snap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
}

function iniciarListenerFirestore(uid) {
    if(unsubscribeFirestore) unsubscribeFirestore();
    unsubscribeFirestore = db.collection("usuarios").doc(uid).collection("perfiles")
        .onSnapshot(snap => {
            perfiles = snap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            actualizarTodo();
            updateSyncStatus(true);
        }, err => {
            console.error("Firestore Error:", err);
            updateSyncStatus(false);
        });
}

async function guardarPerfiles() {
    // En esta versión se guarda individualmente al editar/crear. 
    // Esta función se puede usar para sincronización masiva si fuera necesario.
}

async function verificarSuscripcion(uid) {
    const doc = await db.collection("usuarios").doc(uid).get();
    const data = doc.data() || {};
    const fechaRegistro = data.fechaRegistro ? new Date(data.fechaRegistro) : new Date();
    
    if(!data.fechaRegistro) {
        await db.collection("usuarios").doc(uid).set({ 
            fechaRegistro: fechaRegistro.toISOString(),
            email: currentUser.email 
        }, { merge: true });
    }

    const hoy = new Date();
    const diffTime = hoy - fechaRegistro;
    const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24));
    
    if(data.tokenActivo) {
        planEstado = "token";
        diasPruebaRestantes = 30; // Simplificado
    } else {
        diasPruebaRestantes = Math.max(0, DIAS_PRUEBA_GRATIS - diffDays);
        planEstado = diasPruebaRestantes > 0 ? "demo" : "bloqueado";
    }
}

// ============ UI CORE ============
function actualizarTodo() {
    actualizarDashboard();
    renderListaPerfiles();
    actualizarPanelMiCuenta();
}

function actualizarDashboard() {
    const total = perfiles.length;
    const libres = perfiles.filter(p => p.estado === "libre").length;
    const vencen = perfiles.filter(p => p.estado === "proximo").length;
    const ventas = perfiles.filter(p => p.fechaVenta && esHoy(p.fechaVenta)).length;

    setText("totalPerfiles", total);
    setText("libresHoy", libres);
    setText("vencenHoy", vencen);
    setText("ventasHoy", ventas);
}

function renderListaPerfiles() {
    const busqueda = (document.getElementById("buscarTexto")?.value || "").toLowerCase();
    const plat = document.getElementById("filtroPlataforma")?.value || "";

    let filtrados = perfiles.filter(p => {
        if(plat && p.plataforma !== plat) return false;
        if(busqueda) {
            const searchable = `${p.perfilNombre} ${p.mail} ${p.cuentaId}`.toLowerCase();
            return searchable.includes(busqueda);
        }
        return true;
    });

    const activos = filtrados.filter(p => p.estado !== "libre" && p.estado !== "vendido");
    const libres = filtrados.filter(p => p.estado === "libre");
    const vendidos = filtrados.filter(p => p.estado === "vendido");

    const contActivos = document.getElementById("listaActivos");
    const contLibres = document.getElementById("listaLibres");

    if(contActivos) contActivos.innerHTML = (activos.length + vendidos.length > 0) 
        ? [...activos, ...vendidos].map(p => crearTarjeta(p)).join('') 
        : '<p class="empty">No hay perfiles activos</p>';

    if(contLibres) contLibres.innerHTML = (libres.length > 0)
        ? libres.map(p => crearTarjeta(p)).join('')
        : '<p class="empty">No hay perfiles disponibles</p>';
    
    bindProfileEvents();
}

function crearTarjeta(p) {
    const isVendido = p.estado === 'vendido';
    return `
        <div class="profile-card ${isVendido ? 'vendido' : ''}">
            <div class="profile-header">
                <span class="badge">${p.plataforma}</span>
                <span class="badge ${p.estado}">${p.estado.toUpperCase()}</span>
            </div>
            <div class="profile-info">
                <strong>${p.perfilNombre}</strong><br>
                <span>${p.mail}</span><br>
                <small>Vence: ${p.fechaVencimiento || 'N/A'}</small>
            </div>
            <div class="action-buttons">
                ${!isVendido ? `<button onclick="mostrarVentaModal('${p.id}')"><i class="fas fa-tag"></i> Vender</button>` : ''}
                <button onclick="eliminarPerfil('${p.id}')"><i class="fas fa-trash"></i></button>
            </div>
        </div>
    `;
}

// ============ CRUD ============
async function guardarPerfilIndividual() {
    const p = {
        plataforma: document.getElementById("platIndividual").value,
        cuentaId: document.getElementById("cuentaIdIndividual").value,
        mail: document.getElementById("mailIndividual").value,
        password: document.getElementById("passIndividual").value,
        estado: "libre",
        timestamp: new Date().toISOString()
    };
    
    showLoader("Guardando...");
    try {
        await db.collection("usuarios").doc(currentUser.uid).collection("perfiles").add(p);
        toast("Perfil guardado");
        limpiarFormCarga();
    } catch(e) { toast("Error al guardar"); }
    hideLoader();
}

async function eliminarPerfil(id) {
    if(!confirm("¿Eliminar este perfil?")) return;
    try {
        await db.collection("usuarios").doc(currentUser.uid).collection("perfiles").doc(id).delete();
        toast("Eliminado");
    } catch(e) { toast("Error"); }
}

async function venderPerfil(id, data) {
    try {
        await db.collection("usuarios").doc(currentUser.uid).collection("perfiles").doc(id).update({
            estado: "vendido",
            fechaVenta: new Date().toISOString(),
            precioVenta: data.precio,
            whatsappCliente: data.cliente,
            ...data
        });
        toast("Vendido correctamente");
    } catch(e) { toast("Error al vender"); }
}

// ============ UTILS ============
function showLoader(txt) {
    const l = document.getElementById("loaderOverlay");
    if(l) {
        l.querySelector(".loader-text").innerText = txt;
        l.classList.add("active");
    }
}
function hideLoader() { document.getElementById("loaderOverlay")?.classList.remove("active"); }

function toast(msg) {
    console.log("TOAST:", msg);
    // Podrías implementar un toast visual aquí
    alert(msg); 
}

function setText(id, val) {
    const el = document.getElementById(id);
    if(el) el.innerText = val;
}

function esHoy(fechaStr) {
    const hoy = new Date().toDateString();
    return new Date(fechaStr).toDateString() === hoy;
}

function limpiarFormCarga() {
    document.getElementById("cuentaIdIndividual").value = "";
    document.getElementById("mailIndividual").value = "";
    document.getElementById("passIndividual").value = "";
}

// ============ NAVIGATION & EVENTS ============
document.querySelectorAll(".nav-btn").forEach(btn => {
    btn.onclick = () => {
        const tab = btn.dataset.tab;
        document.querySelectorAll(".tab-panel").forEach(p => p.classList.remove("active"));
        document.getElementById(`tab-${tab}`).classList.add("active");
        document.querySelectorAll(".nav-btn").forEach(b => b.classList.remove("active"));
        btn.classList.add("active");
    };
});

document.getElementById("logoutBtn").onclick = () => {
    if(confirm("¿Cerrar sesión?")) auth.signOut();
};

document.getElementById("btnGuardarIndividual")?.addEventListener("click", guardarPerfilIndividual);

function mostrarVentaModal(id) {
    pendingVentaId = id;
    const p = perfiles.find(x => x.id === id);
    if(!p) return;
    
    document.getElementById("ventaPerfilInfo").innerText = `${p.plataforma} - ${p.perfilNombre}`;
    document.getElementById("ventaModal").style.display = "flex";
}

document.getElementById("ventaCancelar")?.onclick = () => {
    document.getElementById("ventaModal").style.display = "none";
};

document.getElementById("ventaConfirmar")?.onclick = async () => {
    const data = {
        precio: document.getElementById("ventaPrecio").value,
        cliente: document.getElementById("ventaCliente").value
    };
    await venderPerfil(pendingVentaId, data);
    document.getElementById("ventaModal").style.display = "none";
};

function updateSyncStatus(ok) {
    const s = document.getElementById("syncStatus");
    if(s) {
        s.className = ok ? "sync-status sincronizado" : "sync-status error";
    }
}

// ============ CONFIG LOCAL ============
function cargarConfigLocal() {
    const cfg = JSON.parse(localStorage.getItem("streamflow_config") || "{}");
    if(cfg.tema === "light") document.body.classList.add("light");
    notificationsEnabled = cfg.notifications !== false;
}

function actualizarPanelMiCuenta() {
    if(!currentUser) return;
    setText("perfilEmail", currentUser.email);
}

function mostrarAvisoVencimientos() {
    // Lógica de avisos truncada por brevedad, similar a app_final.js
}

function bindProfileEvents() {
    // Eventos adicionales para las tarjetas si fuera necesario
}
