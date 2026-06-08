// ============================================
// STREAMFLOW PRO - VERSIÓN LIMPIA
// Firebase Compat
// ============================================

const firebaseConfig = {
    apiKey: "AIzaSyB8jYiHFiD_-MTHUQr2c3WU_b84RAPonvA",
    authDomain: "stream-flow-pro.firebaseapp.com",
    projectId: "stream-flow-pro",
    storageBucket: "stream-flow-pro.firebasestorage.app",
    messagingSenderId: "837367317965",
    appId: "1:837367317965:web:00f039846e2a3646d87084"
};

if (!firebase.apps.length) {
    firebase.initializeApp(firebaseConfig);
}
const auth = firebase.auth();
const db = firebase.firestore();

// ============ CONFIGURACIÓN GLOBAL ============
const WHATSAPP_TOKEN_NUMBER = "5492236785329";
const DIAS_PRUEBA_GRATIS = 3;
const DIAS_TOKEN = 30;

// ============ VARIABLES GLOBALES ============
let perfiles = [];
let DIAS_PROXIMO = 3;
let notificationsEnabled = true;
let ordenAsc = true;
let currentUser = null;
let editandoId = null;
let pendingVentaId = null;
let unsubscribeFirestore = null;
let appDesbloqueada = true;
let diasPruebaRestantes = DIAS_PRUEBA_GRATIS;
let planEstado = "demo";
let autoSyncEnabled = true;

// ============ FUNCIONES UTILITARIAS ============
function showLoader(texto = "Cargando...") {
  const overlay = document.getElementById("loaderOverlay");
  if(overlay) {
    const textEl = overlay.querySelector(".loader-text");
    if(textEl) textEl.innerText = texto;
    overlay.classList.add("active");
  }
}

function hideLoader() {
  const overlay = document.getElementById("loaderOverlay");
  if(overlay) overlay.classList.remove("active");
}

function toast(msg) {
  let t = document.querySelector(".toast");
  if(t) t.remove();
  t = document.createElement("div");
  t.className = "toast";
  t.innerHTML = '<i class="fas fa-info-circle"></i> ' + msg;
  document.body.appendChild(t);
  setTimeout(() => t.remove(), 2500);
}

function escapeHtml(str) {
  if(!str) return "";
  return str.replace(/[&<>]/g, m => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;' }[m]));
}

function generarIdUnico() {
  return Date.now() + '-' + Math.random().toString(36).substr(2, 9);
}

function parseFecha(str) {
  if(!str) return null;
  const d = new Date(str);
  return isNaN(d) ? null : d.toISOString().split('T')[0];
}

// ============ PERSISTENCIA Y CONFIG ============
function cargarConfigLocal() {
  const t = localStorage.getItem("theme");
  if(t === "light") document.body.classList.add("light");
  const n = localStorage.getItem("notif");
  notificationsEnabled = (n !== "false");
  const s = localStorage.getItem("sync");
  autoSyncEnabled = (s !== "false");
}

// ============ LÓGICA DE NEGOCIO ============
async function verificarSuscripcion(uid) {
  try {
    const doc = await db.collection("usuarios").doc(uid).get();
    if(doc.exists) {
      const data = doc.data();
      planEstado = data.plan || "demo";
      diasPruebaRestantes = data.diasRestantes !== undefined ? data.diasRestantes : DIAS_PRUEBA_GRATIS;
      actualizarUIPlan();
    } else {
      await db.collection("usuarios").doc(uid).set({
        plan: "demo",
        diasRestantes: DIAS_PRUEBA_GRATIS,
        fechaRegistro: firebase.firestore.FieldValue.serverTimestamp()
      });
      planEstado = "demo";
      diasPruebaRestantes = DIAS_PRUEBA_GRATIS;
      actualizarUIPlan();
    }
  } catch(e) { console.error("Error suscripcion:", e); }
}

function actualizarUIPlan() {
  const badge = document.getElementById("planBadge");
  if(!badge) return;
  if(planEstado === "pro") {
    badge.className = "plan-badge pro";
    badge.innerHTML = '<i class="fas fa-crown"></i> PRO';
  } else {
    badge.className = "plan-badge demo";
    badge.innerHTML = `<i class="fas fa-gift"></i> DEMO ${diasPruebaRestantes}d`;
  }
}

// ============ GESTIÓN DE PERFILES ============
async function cargarPerfiles() {
  if(!currentUser) return;
  showLoader("Cargando perfiles...");
  try {
    const snapshot = await db.collection("usuarios").doc(currentUser.uid).collection("perfiles").get();
    perfiles = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    renderizarTodo();
  } catch(e) { toast("Error al cargar: " + e.message); }
  finally { hideLoader(); }
}

function iniciarListenerFirestore(uid) {
  if(unsubscribeFirestore) unsubscribeFirestore();
  unsubscribeFirestore = db.collection("usuarios").doc(uid).collection("perfiles")
    .onSnapshot(snapshot => {
      perfiles = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
      renderizarTodo();
      const indicator = document.getElementById("syncIndicator");
      if(indicator) {
        indicator.style.display = "inline-flex";
        setTimeout(() => indicator.style.display = "none", 2000);
      }
    });
}

function renderizarTodo() {
  actualizarStats();
  renderizarLista("listaActivos", perfiles.filter(p => p.estado !== 'libre' && p.estado !== 'vendido'));
  renderizarLista("listaLibres", perfiles.filter(p => p.estado === 'libre'));
  renderizarHistorial();
}

function actualizarStats() {
  const total = perfiles.length;
  const libres = perfiles.filter(p => p.estado === 'libre').length;
  const hoy = new Date().toISOString().split('T')[0];
  const vencen = perfiles.filter(p => p.fechaVencimiento === hoy).length;
  const ventas = perfiles.filter(p => p.estado === 'vendido' && p.fechaVenta === hoy).length;

  document.getElementById("totalPerfiles").innerText = total;
  document.getElementById("libresHoy").innerText = libres;
  document.getElementById("vencenHoy").innerText = vencen;
  document.getElementById("ventasHoy").innerText = ventas;
}

function renderizarLista(elementId, lista) {
  const container = document.getElementById(elementId);
  if(!container) return;
  container.innerHTML = "";
  if(lista.length === 0) {
    container.innerHTML = '<p style="text-align:center; opacity:0.5; padding:1rem;">No hay perfiles.</p>';
    return;
  }

  lista.forEach(p => {
    const div = document.createElement("div");
    div.className = `profile-item ${p.estado}`;
    div.innerHTML = `
      <div class="profile-info">
        <div class="profile-main"><strong>${p.plataforma}</strong> - ${p.perfilNombre || 'S/N'}</div>
        <div class="profile-sub">${p.mail} | Vence: ${p.fechaVencimiento || 'S/D'}</div>
      </div>
      <div class="profile-actions">
        <button onclick="venderPerfil('${p.id}')" title="Vender"><i class="fas fa-shopping-cart"></i></button>
        <button onclick="editarPerfil('${p.id}')" title="Editar"><i class="fas fa-edit"></i></button>
        <button onclick="borrarPerfil('${p.id}')" title="Borrar"><i class="fas fa-trash"></i></button>
      </div>
    `;
    container.appendChild(div);
  });
}

function renderizarHistorial() {
  const container = document.getElementById("historialLista");
  if(!container) return;
  const vendidos = perfiles.filter(p => p.estado === 'vendido');
  container.innerHTML = "";
  vendidos.forEach(p => {
    const div = document.createElement("div");
    div.className = "profile-item vendido";
    div.innerHTML = `
      <div class="profile-info">
        <div><strong>${p.plataforma}</strong> - ${p.clienteNombre || 'Cliente'}</div>
        <div style="font-size:0.6rem; opacity:0.7;">Vendido el: ${p.fechaVenta} | Precio: $${p.precioVenta}</div>
      </div>
    `;
    container.appendChild(div);
  });
}

// ============ ACCIONES ============
window.venderPerfil = (id) => {
  const p = perfiles.find(x => x.id === id);
  if(!p) return;
  pendingVentaId = id;
  const modal = document.getElementById("ventaModal");
  document.getElementById("ventaPlataforma").value = p.plataforma;
  document.getElementById("ventaCuentaId").value = p.cuentaId || "";
  document.getElementById("ventaPerfilNombre").value = p.perfilNombre || "";
  document.getElementById("ventaMail").value = p.mail || "";
  document.getElementById("ventaPassword").value = p.password || "";
  document.getElementById("ventaPin").value = p.pin || "";
  document.getElementById("ventaFechaVencimiento").value = p.fechaVencimiento || "";
  document.getElementById("ventaPrecio").value = p.precio || "";
  document.getElementById("ventaProveedor").value = p.proveedor || "";
  modal.style.display = "flex";
};

document.getElementById("ventaConfirmar").onclick = async () => {
  if(!pendingVentaId) return;
  const p = perfiles.find(x => x.id === pendingVentaId);
  const ventaData = {
    estado: 'vendido',
    fechaVenta: new Date().toISOString().split('T')[0],
    clienteNombre: document.getElementById("ventaCliente").value,
    precioVenta: document.getElementById("ventaPrecio").value,
    whatsappCliente: document.getElementById("ventaCliente").value
  };

  try {
    await db.collection("usuarios").doc(currentUser.uid).collection("perfiles").doc(pendingVentaId).update(ventaData);
    toast("Venta registrada");
    document.getElementById("ventaModal").style.display = "none";
    
    // Generar link de WhatsApp
    const msg = `¡Hola! Aquí tienes tus datos de acceso para ${p.plataforma}:\n\n📧 Correo: ${p.mail}\n🔑 Clave: ${p.password}\n🎭 Perfil: ${p.perfilNombre}\n📌 PIN: ${p.pin || 'Sin PIN'}\n📅 Vence: ${p.fechaVencimiento}\n\n¡Gracias por tu compra!`;
    const url = `https://wa.me/${ventaData.whatsappCliente.replace(/\D/g,'')}?text=${encodeURIComponent(msg)}`;
    window.open(url, '_blank');
  } catch(e) { toast("Error: " + e.message); }
};

document.getElementById("ventaCancelar").onclick = () => {
  document.getElementById("ventaModal").style.display = "none";
};

window.editarPerfil = (id) => {
  const p = perfiles.find(x => x.id === id);
  if(!p) return;
  editandoId = id;
  // Llenar campos de modo individual
  document.getElementById("platIndividual").value = p.plataforma;
  document.getElementById("cuentaIdIndividual").value = p.cuentaId || "";
  document.getElementById("nombrePerfilIndividual").value = p.perfilNombre || "";
  document.getElementById("mailIndividual").value = p.mail || "";
  document.getElementById("passIndividual").value = p.password || "";
  document.getElementById("fechaIndividual").value = p.fechaVencimiento || "";
  document.getElementById("pinIndividual").value = p.pin || "";
  document.getElementById("precioIndividual").value = p.precio || "";
  document.getElementById("proveedorIndividual").value = p.proveedor || "";
  document.getElementById("whatsappIndividual").value = p.whatsappProveedor || "";
  document.getElementById("obsIndividual").value = p.observaciones || "";
  
  // Cambiar a pestaña de carga
  document.querySelector('[data-nav="carga"]').click();
  document.querySelector('[data-mod="individual"]').click();
  document.getElementById("btnCancelarEdicion").style.display = "block";
};

window.borrarPerfil = async (id) => {
  if(!confirm("¿Borrar este perfil?")) return;
  try {
    await db.collection("usuarios").doc(currentUser.uid).collection("perfiles").doc(id).delete();
    toast("Perfil borrado");
  } catch(e) { toast("Error: " + e.message); }
};

// ============ UI EVENTS ============
document.querySelectorAll(".nav-btn").forEach(btn => {
  btn.onclick = () => {
    const target = btn.dataset.nav;
    document.querySelectorAll(".nav-btn").forEach(b => b.classList.remove("active"));
    btn.classList.add("active");
    document.querySelectorAll(".tab-panel").forEach(p => p.classList.remove("active"));
    document.getElementById("tab-" + target).classList.add("active");
  };
});

document.querySelectorAll(".carga-tab").forEach(tab => {
  tab.onclick = () => {
    const mod = tab.dataset.mod;
    document.querySelectorAll(".carga-tab").forEach(t => t.classList.remove("active"));
    tab.classList.add("active");
    document.getElementById("modo-completa").style.display = mod === "completa" ? "block" : "none";
    document.getElementById("modo-individual").style.display = mod === "individual" ? "block" : "none";
    document.getElementById("modo-masiva").style.display = mod === "masiva" ? "block" : "none";
  };
});

document.getElementById("btnGuardarIndividual").onclick = async () => {
  const data = {
    plataforma: document.getElementById("platIndividual").value,
    cuentaId: document.getElementById("cuentaIdIndividual").value,
    perfilNombre: document.getElementById("nombrePerfilIndividual").value,
    mail: document.getElementById("mailIndividual").value,
    password: document.getElementById("passIndividual").value,
    fechaVencimiento: document.getElementById("fechaIndividual").value,
    pin: document.getElementById("pinIndividual").value,
    precio: document.getElementById("precioIndividual").value,
    proveedor: document.getElementById("proveedorIndividual").value,
    whatsappProveedor: document.getElementById("whatsappIndividual").value,
    observaciones: document.getElementById("obsIndividual").value,
    estado: 'activo'
  };

  if(!data.mail || !data.password) return toast("Correo y contraseña obligatorios");

  showLoader("Guardando...");
  try {
    if(editandoId) {
      await db.collection("usuarios").doc(currentUser.uid).collection("perfiles").doc(editandoId).update(data);
      editandoId = null;
      document.getElementById("btnCancelarEdicion").style.display = "none";
      toast("Perfil actualizado");
    } else {
      await db.collection("usuarios").doc(currentUser.uid).collection("perfiles").add({
        ...data,
        fechaCarga: new Date().toISOString()
      });
      toast("Perfil guardado");
    }
    // Limpiar campos
    document.querySelectorAll("#modo-individual input").forEach(i => i.value = "");
  } catch(e) { toast("Error: " + e.message); }
  finally { hideLoader(); }
};

document.getElementById("btnLogoutSubmit")?.addEventListener("click", () => auth.signOut());
document.getElementById("logoutBtn")?.addEventListener("click", () => auth.signOut());
document.getElementById("btnCerrarSesion")?.addEventListener("click", () => auth.signOut());

// ============ AUTH HANDLER ============
auth.onAuthStateChanged(async (user) => {
  const loader = document.getElementById("loaderOverlay");
  const loginWrapper = document.getElementById("loginWrapper");
  const appContainer = document.getElementById("appContainer");
  const nav = document.getElementById("bottomNavBar");

  if(user) {
    currentUser = user;
    if(loginWrapper) loginWrapper.style.display = "none";
    if(appContainer) appContainer.style.display = "flex";
    if(nav) nav.style.display = "flex";
    document.body.style.overflow = "hidden";
    
    // Admin Branding
    if(user.email === "florenciaamor36@gmail.com") {
      const planBadge = document.getElementById("planBadge");
      if(planBadge) {
        planBadge.innerHTML = '<i class="fas fa-shield-alt"></i> ADMIN PRO';
        planBadge.className = "plan-badge pro";
      }
    }
    
    await verificarSuscripcion(user.uid);
    await cargarPerfiles();
    iniciarListenerFirestore(user.uid);
  } else {
    currentUser = null;
    if(loginWrapper) loginWrapper.style.display = "flex";
    if(appContainer) appContainer.style.display = "none";
    if(nav) nav.style.display = "none";
    document.body.style.overflow = "auto";
    if(unsubscribeFirestore) unsubscribeFirestore();
  }
  if(loader) loader.classList.remove("active");
});

// LOGIN UI SWITCH
document.getElementById("showRegister")?.addEventListener("click", () => {
  document.getElementById("loginPanel").style.display = "none";
  document.getElementById("registerPanel").style.display = "block";
});
document.getElementById("showLogin")?.addEventListener("click", () => {
  document.getElementById("registerPanel").style.display = "none";
  document.getElementById("loginPanel").style.display = "block";
});

// LOGIN FORM SUBMIT
document.getElementById("btnLoginSubmit")?.addEventListener("click", async () => {
  const email = document.getElementById("loginEmail").value.trim();
  const pass = document.getElementById("loginPassword").value;
  if(!email || !pass) return toast("Ingresa correo y clave");
  showLoader("Iniciando sesión...");
  try {
    await auth.signInWithEmailAndPassword(email, pass);
  } catch(e) { toast("Error: " + e.message); }
  finally { hideLoader(); }
});

document.getElementById("btnRegisterSubmit")?.addEventListener("click", async () => {
  const email = document.getElementById("regEmail").value.trim();
  const pass = document.getElementById("regPassword").value;
  const confirm = document.getElementById("regPasswordConfirm").value;
  if(!email || !pass || !confirm) return toast("Completa todos los campos");
  if(pass !== confirm) return toast("Las contraseñas no coinciden");
  showLoader("Creando cuenta...");
  try {
    await auth.createUserWithEmailAndPassword(email, pass);
  } catch(e) { toast("Error: " + e.message); }
  finally { hideLoader(); }
});

// INITIALIZE
cargarConfigLocal();
