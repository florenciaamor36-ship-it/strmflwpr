
    // ============================================
    // STREAMFLOW PRO - VERSIÓN COMPLETA CORREGIDA
    // Firebase Compat (sin import maps)
    // ============================================
    
    // Configuración de Firebase
    const firebaseConfig = {
      apiKey: "AIzaSyB8jYiHFiD_-MTHUQr2c3WU_b84RAPonvA",
      authDomain: "stream-flow-pro.firebaseapp.com",
      projectId: "stream-flow-pro",
      storageBucket: "stream-flow-pro.firebasestorage.app",
      messagingSenderId: "837367317965",
      appId: "1:837367317965:web:00f039846e2a3646d87084"
    };
    
    // Inicializar Firebase
    firebase.initializeApp(firebaseConfig);
    const auth = firebase.auth();
    const db = firebase.firestore();
    
    // ============ CONFIGURACIÓN GLOBAL ============
    const WHATSAPP_TOKEN_NUMBER = "5492236785329";
    const DIAS_PRUEBA_GRATIS = 3;
    const DIAS_TOKEN = 30;
    
    // ============ TOKENS VÁLIDOS (150+ tokens originales) ============
    const TOKENS_VALIDOS = new Set([
      "SF-A7K2-M9P4-X8N1","SF-B3F8-R6W2-Q5L9","SF-C9M4-T1Y7-V2H6","SF-D5R1-K8U3-W7Z0",
      "SF-E2X6-N4Q9-J3P5","SF-F8S3-Y1M7-B6G4","SF-G4W9-C2T8-L5R1","SF-H6V1-Z5Q3-D9F7",
      "SF-J1A4-B7C9-E2F5","SF-K3D6-G8H1-M4N7","SF-L5F9-J2K6-P8Q3","SF-M7H2-L9R5-T1V4",
      "SF-N9J5-V3X8-W2G1","SF-P1L4-Z7Q3-M9F6","SF-Q3N6-B8C2-T1Y7","SF-R5P9-G4H8-L2V5",
      "SF-S7R2-M1N9-X3W4","SF-T9V5-F6G3-P8Q2","SF-U1X8-Y4Z7-D5R9","SF-V3G6-H2J9-L1M4",
      "SF-W5B9-N7Q3-T2V6","SF-X7M1-P4R9-C8W2","SF-Y9H4-L2G6-F3S7","SF-Z1P7-D5Q3-M8N2",
      "SF-A3V9-T7X4-B2R6","SF-B5G2-H8M1-Y9W4","SF-C7J5-F3N6-P8Q2","SF-D9L1-C4G7-Z5R3",
      "SF-E2R6-M8W2-V3H9","SF-F4G3-N9X7-P1Q5","SF-G6H8-B2C4-L5M7","SF-H8J2-D1F5-W7Y3",
      "SF-J1M4-P9Q3-X8N2","SF-K3G6-L7R5-T2V1","SF-L5H9-F2G6-M4P3","SF-M7N1-B8C2-Y9W4",
      "SF-N9P5-X3W7-G1H4","SF-P1Q7-L2M6-T8V3","SF-Q3R9-F4G2-Z5N1","SF-R5S1-H7J3-P9Q6",
      "SF-S7T3-M2N8-X4W5","SF-T9U5-G1H4-B7C9","SF-U1V7-L3M6-Y2W8","SF-V3W9-F5G2-P1Q4",
      "SF-W5X2-N8Q4-T7V3","SF-X7Y4-M1P9-C2R6","SF-Y9Z6-H5J2-L3M8","SF-Z1A8-G7B3-P4N9",
      "SF-A3C1-L2M5-F8V4","SF-B5D3-B7C9-W2G1","SF-C7F5-G4H8-L1V6","SF-D9G7-M2N9-T3W5",
      "SF-E1H9-P5R2-X7Q4","SF-F3J2-F6G1-M8N3","SF-G5K4-L7P3-V1W9","SF-H7L6-B9C2-T4Y1",
      "SF-J9M8-D5Q3-Z2R6","SF-K1N1-H7G4-X9P2","SF-L3P3-M2N8-F5G7","SF-M5Q5-L1V9-P3B7",
      "SF-N7R7-G4H2-T8V1","SF-P9S9-F6G3-C2Q5","SF-Q1T1-B8C4-M9N7","SF-R3V3-D1F5-X7P2",
      "SF-S5W5-M8L2-Y4G1","SF-T7X7-P5Q9-V3H6","SF-U9Y9-L1R3-T7F2","SF-V1Z1-F4G6-M2N8",
      "SF-W3A3-B7C9-X1P4","SF-X5B5-G2H8-L3M7","SF-Y7C7-M1N9-T5V2","SF-Z9D9-P4Q3-W6G8",
      "SF-A2E2-L7F5-V9M1","SF-B4G4-G1H8-X3P6","SF-C6H6-F2G9-L5M2","SF-D8J8-M3N7-B4Q1",
      "SF-E1K1-P9R4-T2W5","SF-F3L3-G7H2-Z5V8","SF-G5M5-B1C4-M9N3","SF-H7N7-D5Q2-X8P1",
      "SF-J9P9-L1M6-T4V7","SF-K1Q1-F4G8-Z2N5","SF-L3R3-M7N2-X1P9","SF-M5S5-G3H6-P8Q4",
      "SF-N7T7-L2V9-T1M5","SF-P9U9-B8C2-Y4W7","SF-Q1V1-F5G3-P7Q2","SF-R3W3-M1P9-C5R8",
      "SF-S5X5-H2J7-L4M1","SF-T7Y7-G1H4-B9C2","SF-U9Z9-L3M6-T5V8","SF-V1A1-F4G2-P7Q3",
      "SF-W3B3-M8N2-X1P5","SF-X5C5-G7H4-B2R9","SF-Y7D7-L1M5-V3H8","SF-Z9E9-P4Q2-T6G1",
      "SF-A1F1-M2N7-X9P4","SF-B3G3-L8V5-T1M2","SF-C5H5-B7C9-Y2W6","SF-D7J7-F5G3-P1Q4",
      "SF-E9K9-M1P8-C4R7","SF-F1L1-H2J6-L5M9","SF-G3M3-G1H4-B7C2","SF-H5N5-L3M7-V8H4",
      "SF-J7P7-F4G2-P9Q5","SF-K9Q9-M8N1-X2P6","SF-L1R1-G7H4-B5R2","SF-M3S3-L2M6-V1H9",
      "SF-N5T5-P4Q3-T7G2","SF-P7U7-M1N9-X8P5","SF-Q9V9-L7V4-T2M1","SF-R1W1-B8C2-Y5W8",
      "SF-S3X3-F6G3-P9Q4","SF-T5Y5-M2P1-C8R5","SF-U7Z7-H5J9-L4M2","SF-V9A9-G1H4-B3C7",
      "SF-W1B1-L2M6-T9V5","SF-X3C3-F5G2-P8Q1","SF-Y5D5-M1N9-X7P3","SF-Z7E7-G4H8-B2R5",
      "SF-A9F9-L3M7-V1H6","SF-B1G1-P5Q2-T9G4","SF-C3H3-M2N8-X1P7","SF-D5J5-L8V4-T2M9",
      "SF-E7K7-B7C2-Y5W1","SF-F9L9-F4G3-P8Q6","SF-G1M1-M9P4-C2R5","SF-H3N3-H5J2-L7M1",
      "SF-J5P5-G1H8-B4C9","SF-K7Q7-L2M6-T5V9","SF-L9R9-F3G1-P7Q4","SF-M1S1-M2N9-X5P8",
      "SF-N3T3-G7H4-B1R2","SF-P5U5-L3M5-V7H9","SF-Q7V7-P1Q4-T8G2","SF-R9W9-M8N2-X3P1",
      "SF-S1X1-G4H2-B9R6","SF-T3Y3-L1M7-V5H2","SF-U5Z5-P9Q2-T7G4","SF-V7A7-M1N6-X2P9",
      "SF-W9B9-L3V5-T8M1","SF-X1C1-B2C7-Y4W9","SF-Y3D3-F5G1-P2Q8","SF-Z5E5-M9P4-C3R7",
      "SF-A7F7-H2J6-L1M5","SF-B9G9-G1H4-B8C2","SF-C1H1-L3M7-V5H9","SF-D3J3-F4G2-P7Q1",
      "SF-E5K5-M8N2-X1P9","SF-F7L7-G7H4-B2R5","SF-G9M9-L1M6-V3H8","SF-H1N1-P4Q2-T7G1",
      "SF-J3P3-M1N9-X8P4","SF-K5Q5-L7V4-T2M1","SF-L7R7-B8C2-Y5W3","SF-M9S9-F6G3-P1Q4",
      "SF-N1T1-M2P1-C8R7"
    ]);
    
    // ============ ESTADO DE LA APP ============
    let currentUser = null;
    let perfiles = [];
    let unsubscribeFirestore = null;
    let planEstado = "demo"; // demo, token, bloqueado
    let diasPruebaRestantes = 3;
    let appDesbloqueada = false;
    let ordenAsc = true;
    let filtroTimeout = null;
    let pendingVentaId = null;
    let editandoId = null;
    let kioscoMode = false;
    let notificationsEnabled = true;
    let DIAS_PROXIMO = 3;
    
    // ============ UTILIDADES ============
    function toast(msg) {
      console.log("TOAST:", msg);
      const t = document.createElement("div");
      t.className = "toast";
      t.innerText = msg;
      document.body.appendChild(t);
      setTimeout(() => t.classList.add("show"), 100);
      setTimeout(() => {
        t.classList.remove("show");
        setTimeout(() => t.remove(), 500);
      }, 3000);
    }
    
    function showLoader(text = "Cargando...") {
      let l = document.getElementById("globalLoader");
      if(!l) {
        l = document.createElement("div");
        l.id = "globalLoader";
        l.className = "loader-overlay";
        l.innerHTML = `<div class="loader-content"><div class="spinner"></div><p id="loaderText">${text}</p></div>`;
        document.body.appendChild(l);
      } else {
        document.getElementById("loaderText").innerText = text;
      }
      l.style.display = "flex";
    }
    
    function hideLoader() {
      const l = document.getElementById("globalLoader");
      if(l) l.style.display = "none";
    }
    
    function generarIdUnico() {
      return Date.now().toString(36) + Math.random().toString(36).substr(2);
    }
    
    function parseFecha(str) {
      if(!str) return null;
      const [y, m, d] = str.split("-");
      return new Date(y, m - 1, d);
    }
    
    function formatearFecha(str) {
      if(!str) return "Sin fecha";
      const f = parseFecha(str);
      if(!f) return str;
      return f.toLocaleDateString('es-AR', { day: '2-digit', month: '2-digit', year: 'numeric' });
    }
    
    function escapeHtml(text) {
      const div = document.createElement('div');
      div.textContent = text;
      return div.innerHTML;
    }
    
    // ============ LÓGICA DE SUSCRIPCIÓN ============
    async function verificarSuscripcion(uid) {
      try {
        const userDoc = await db.collection("usuarios").doc(uid).get();
        const userData = userDoc.data();
        
        // El email florenciaamor36@gmail.com es siempre PRO
        if(currentUser.email === "florenciaamor36@gmail.com") {
          planEstado = "token";
          appDesbloqueada = true;
          diasPruebaRestantes = 9999;
          aplicarBloqueoApp();
          return;
        }
    
        const suscRef = db.collection("usuarios").doc(uid).collection("suscripcion").doc("estado");
        const snap = await suscRef.get();
        
        if(snap.exists) {
          const data = snap.data();
          if(data.estado === "token") {
            const exp = new Date(data.fechaExpiracion);
            const hoy = new Date();
            if(exp > hoy) {
              planEstado = "token";
              appDesbloqueada = true;
              diasPruebaRestantes = Math.ceil((exp - hoy) / (1000 * 60 * 60 * 24));
            } else {
              planEstado = "bloqueado";
              appDesbloqueada = false;
            }
          } else {
            // Manejar demo
            const creacion = new Date(currentUser.metadata.creationTime);
            const hoy = new Date();
            const dias = Math.ceil((hoy - creacion) / (1000 * 60 * 60 * 24));
            if(dias <= DIAS_PRUEBA_GRATIS) {
              planEstado = "demo";
              appDesbloqueada = true;
              diasPruebaRestantes = DIAS_PRUEBA_GRATIS - dias;
            } else {
              planEstado = "bloqueado";
              appDesbloqueada = false;
            }
          }
        } else {
          // Nueva cuenta, iniciar demo
          const creacion = new Date(currentUser.metadata.creationTime);
          const hoy = new Date();
          const dias = Math.ceil((hoy - creacion) / (1000 * 60 * 60 * 24));
          if(dias <= DIAS_PRUEBA_GRATIS) {
            planEstado = "demo";
            appDesbloqueada = true;
            diasPruebaRestantes = DIAS_PRUEBA_GRATIS - dias;
          } else {
            planEstado = "bloqueado";
            appDesbloqueada = false;
          }
        }
        aplicarBloqueoApp();
      } catch(e) {
        console.error("Error verificando suscripción:", e);
        planEstado = "demo";
        appDesbloqueada = true;
        aplicarBloqueoApp();
      }
    }
    
    function aplicarBloqueoApp() {
      const overlay = document.getElementById("bloqueoOverlay");
      if(!appDesbloqueada && planEstado === "bloqueado") {
        overlay.style.display = "flex";
        document.body.classList.add("app-bloqueada");
      } else {
        overlay.style.display = "none";
        document.body.classList.remove("app-bloqueada");
      }
      actualizarBadgePlan();
    }
    
    function actualizarBadgePlan() {
      const badge = document.getElementById("planBadge");
      if(!badge) return;
      if(planEstado === "token") {
        badge.innerHTML = '<i class="fas fa-crown"></i> PRO';
        badge.className = "plan-badge pro";
      } else if(planEstado === "demo") {
        badge.innerHTML = '<i class="fas fa-star"></i> DEMO';
        badge.className = "plan-badge demo";
      } else {
        badge.innerHTML = '<i class="fas fa-lock"></i> BLOQUEADO';
        badge.className = "plan-badge blocked";
      }
    }
    
    async function validarToken(token, uid) {
      if(!uid) return { valido: false, mensaje: "Usuario no autenticado" };
      token = token.trim().toUpperCase();
      console.log("Validando token:", token, "para UID:", uid);
      
      if(!TOKENS_VALIDOS.has(token)) {
        console.warn("Token inválido (no está en el Set):", token);
        return { valido: false, mensaje: "❌ Token inválido" };
      }
      
      try {
        const tokenRef = db.collection("tokens_usados").doc(token);
        const snap = await tokenRef.get();
        console.log("Firestore snapshot para token:", snap.exists);
        
        if(snap.exists && snap.data().usadoPor !== uid) {
          console.warn("Token ya usado por:", snap.data().usadoPor);
          return { valido: false, mensaje: "❌ Token ya usado por otra cuenta" };
        }
        
        const ahora = new Date();
        const expiracion = new Date(ahora);
        expiracion.setDate(expiracion.getDate() + DIAS_TOKEN);
        
        console.log("Guardando token en tokens_usados...");
        await tokenRef.set({
          token: token,
          usadoPor: uid,
          fechaActivacion: ahora.toISOString(),
          fechaExpiracion: expiracion.toISOString()
        });
        
        console.log("Actualizando suscripción del usuario...");
        const suscRef = db.collection("usuarios").doc(uid).collection("suscripcion").doc("estado");
        await suscRef.set({
          estado: "token",
          fechaExpiracion: expiracion.toISOString()
        }, { merge: true });
        
        appDesbloqueada = true;
        diasPruebaRestantes = DIAS_TOKEN;
        planEstado = "token";
        
        actualizarBadgePlan();
        actualizarTodo();
        aplicarBloqueoApp();
        
        console.log("Token validado exitosamente.");
        return { valido: true, mensaje: "✅ Token activado por 30 días" };
      } catch(e) {
        console.error("TOKEN ERROR DETALLADO:", e.code, e.message, e);
        return { valido: false, mensaje: "⚠️ Error de permisos: No se pudo conectar con el servidor de licencias (" + (e.code || "unknown") + ")" };
      }
    }
    
    // ============ FIRESTORE CORE ============
    async function cargarPerfiles() {
      if(!currentUser) return;
      try {
        const snap = await db.collection("usuarios").doc(currentUser.uid).collection("perfiles").get();
        perfiles = snap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
        actualizarTodo();
      } catch(e) {
        console.error("Error cargando perfiles:", e);
        // Fallback a localStorage si falla Firestore
        const local = localStorage.getItem("streamflow_perfiles_backup");
        if(local) perfiles = JSON.parse(local);
        actualizarTodo();
      }
    }
    
    async function guardarPerfiles() {
      // Nota: Esta función es un placeholder porque ahora usamos persistencia individual por documento
      // Pero la mantenemos para compatibilidad con el resto del código
      actualizarTodo();
    }
    
    function iniciarListenerFirestore(uid) {
      if(unsubscribeFirestore) unsubscribeFirestore();
      unsubscribeFirestore = db.collection("usuarios").doc(uid).collection("perfiles")
        .onSnapshot(snap => {
          perfiles = snap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
          actualizarTodo();
        }, err => console.error("Snapshot error:", err));
    }
    
    // Operaciones CRUD individuales en Firestore
    async function upsertPerfil(perfil) {
      if(!currentUser) return;
      const id = perfil.id || generarIdUnico();
      const p = { ...perfil, id };
      await db.collection("usuarios").doc(currentUser.uid).collection("perfiles").doc(id).set(p);
    }
    
    async function eliminarPerfil(id) {
      if(!confirm("¿Borrar este perfil?")) return;
      if(!currentUser) return;
      await db.collection("usuarios").doc(currentUser.uid).collection("perfiles").doc(id).delete();
      toast("Perfil eliminado");
    }
    
    // ============ LÓGICA DE NEGOCIO ============
    function obtenerEstado(fechaStr) {
      if(!fechaStr) return "libre";
      const f = parseFecha(fechaStr);
      const hoy = new Date();
      hoy.setHours(0,0,0,0);
      const diff = Math.round((f - hoy) / 86400000);
      if(diff < 0) return "vencido";
      if(diff <= DIAS_PROXIMO) return "proximo";
      return "activo";
    }
    
    function estadoTexto(est) {
      const map = { "activo": "✅ Activo", "proximo": "⚠️ Por vencer", "vencido": "❌ Vencido", "libre": "🆓 Libre", "vendido": "💰 Vendido" };
      return map[est] || est;
    }
    
    function estadoClase(est) {
      return "badge-" + (est === "activo" ? "success" : est === "proximo" ? "warning" : est === "vencido" ? "danger" : est === "vendido" ? "info" : "light");
    }
    
    async function venderPerfil(id, datosVenta) {
      const p = perfiles.find(p => p.id === id);
      if(p) {
        Object.assign(p, datosVenta);
        p.estado = "vendido";
        p.fechaVenta = new Date().toISOString();
        p.precioVenta = Number(datosVenta.precio) || 0;
        p.whatsappCliente = datosVenta.cliente;
        await upsertPerfil(p);
        toast("✅ Venta registrada");
        if(datosVenta.cliente) {
          const msg = plantillaCliente(p, true);
          abrirWhatsApp(datosVenta.cliente, msg);
        }
      }
    }
    
    async function renovarPerfil(id) {
      const p = perfiles.find(p => p.id === id);
      if(p) {
        const nuevaFecha = prompt("Nueva fecha de vencimiento (AAAA-MM-DD):", new Date(Date.now() + 30*86400000).toISOString().split('T')[0]);
        if(nuevaFecha) {
          p.fechaVencimiento = nuevaFecha;
          p.estado = obtenerEstado(nuevaFecha);
          p.fechaVenta = null;
          p.precioVenta = null;
          await upsertPerfil(p);
          toast("🔄 Perfil renovado");
        }
      }
    }
    
    async function marcarLibre(id) {
      const p = perfiles.find(p => p.id === id);
      if(p) {
        p.estado = "libre";
        p.fechaVenta = null;
        p.precioVenta = null;
        p.whatsappCliente = "";
        await upsertPerfil(p);
        toast("Perfil marcado como libre");
      }
    }
    
    async function duplicarPerfil(id) {
      const p = perfiles.find(p => p.id === id);
      if(p) {
        const nuevo = { ...p, id: generarIdUnico(), estado: "libre", fechaVenta: null, whatsappCliente: "" };
        await upsertPerfil(nuevo);
        toast("Perfil duplicado");
      }
    }
    
    function abrirWhatsApp(num, msg) {
      const url = "https://wa.me/" + num.replace(/\D/g, '') + "?text=" + encodeURIComponent(msg);
      window.open(url, "_blank");
    }
    
    function plantillaCliente(p, esVenta) {
      return `*STREAMFLOW PRO - DATOS DE TU CUENTA*\n\n` +
             `🎬 *Servicio:* ${p.plataforma}\n` +
             `👤 *Perfil:* ${p.perfilNombre}\n` +
             `📧 *Email:* ${p.mail}\n` +
             `🔑 *Pass:* ${p.password}\n` +
             (p.pin ? `🔢 *PIN:* ${p.pin}\n` : '') +
             `📅 *Vence:* ${formatearFecha(p.fechaVencimiento)}\n\n` +
             `⚠️ *IMPORTANTE:* No cambiar ningún dato de la cuenta.`;
    }
    
    function plantillaProveedor(p) {
      return `Pedido para ${p.plataforma}: ${p.mail} / ${p.password}`;
    }
    
    // ============ FORMULARIOS ============
    function limpiarFormularioIndividual() {
      ["platIndividual", "cuentaIdIndividual", "perfilIndividual", "mailIndividual", "passIndividual", "pinIndividual", "fechaIndividual", "proveedorIndividual", "whatsappIndividual", "obsIndividual", "precioIndividual"].forEach(id => {
        const el = document.getElementById(id);
        if(el) el.value = "";
      });
      document.getElementById("otraPlatIndividualDiv").style.display = "none";
    }
    
    async function guardarPerfilIndividual() {
      let plataforma = document.getElementById("platIndividual").value;
      if(plataforma === "Otros") plataforma = document.getElementById("otraPlatIndividual").value;
      const id = editandoId || generarIdUnico();
      const perfil = {
        id,
        plataforma,
        cuentaId: document.getElementById("cuentaIdIndividual").value,
        perfilNombre: document.getElementById("perfilIndividual").value,
        mail: document.getElementById("mailIndividual").value,
        password: document.getElementById("passIndividual").value,
        pin: document.getElementById("pinIndividual").value,
        fechaVencimiento: document.getElementById("fechaIndividual").value,
        proveedor: document.getElementById("proveedorIndividual").value,
        whatsappProveedor: document.getElementById("whatsappIndividual").value,
        observaciones: document.getElementById("obsIndividual").value,
        precio: Number(document.getElementById("precioIndividual").value) || 0,
        estado: obtenerEstado(document.getElementById("fechaIndividual").value),
        fechaVenta: null,
        precioVenta: null,
        whatsappCliente: ""
      };
      await upsertPerfil(perfil);
      toast(editandoId ? "Perfil actualizado" : "Perfil guardado");
      limpiarFormularioIndividual();
      editandoId = null;
      document.getElementById("btnCancelarEdicion").style.display = "none";
      document.getElementById("btnGuardarIndividual").textContent = "Guardar perfil";
    }
    
    function editarPerfil(id) {
      const p = perfiles.find(p => p.id === id);
      if(p) {
        editandoId = id;
        document.querySelector('.nav-btn[data-nav="cargar"]').click();
        document.querySelector('.carga-tab[data-mod="individual"]').click();
        
        document.getElementById("platIndividual").value = ["Netflix", "Netflix indiv", "Disney", "HBO Max", "Prime video", "Spoty", "YouTube", "Crunchyroll", "Paramount"].includes(p.plataforma) ? p.plataforma : "Otros";
        if(document.getElementById("platIndividual").value === "Otros") {
          document.getElementById("otraPlatIndividualDiv").style.display = "block";
          document.getElementById("otraPlatIndividual").value = p.plataforma;
        }
        
        document.getElementById("cuentaIdIndividual").value = p.cuentaId || "";
        document.getElementById("perfilIndividual").value = p.perfilNombre || "";
        document.getElementById("mailIndividual").value = p.mail || "";
        document.getElementById("passIndividual").value = p.password || "";
        document.getElementById("pinIndividual").value = p.pin || "";
        document.getElementById("fechaIndividual").value = p.fechaVencimiento || "";
        document.getElementById("proveedorIndividual").value = p.proveedor || "";
        document.getElementById("whatsappIndividual").value = p.whatsappProveedor || "";
        document.getElementById("obsIndividual").value = p.observaciones || "";
        document.getElementById("precioIndividual").value = p.precio || "";
        
        document.getElementById("btnCancelarEdicion").style.display = "inline-block";
        document.getElementById("btnGuardarIndividual").textContent = "Actualizar perfil";
      }
    }
    
    async function guardarCuentaCompleta() {
      let plataforma = document.getElementById("platCompleta").value;
      if(plataforma === "Otros") plataforma = document.getElementById("otraPlatCompleta").value;
      const base = {
        plataforma,
        cuentaId: document.getElementById("cuentaIdCompleta").value,
        mail: document.getElementById("mailCompleta").value,
        password: document.getElementById("passCompleta").value,
        fechaVencimiento: document.getElementById("fechaCompleta").value,
        proveedor: document.getElementById("proveedorCompleta").value,
        whatsappProveedor: document.getElementById("whatsappCompleta").value,
        observaciones: document.getElementById("obsCompleta").value,
        precio: Number(document.getElementById("precioCompleta").value) || 0,
        estado: obtenerEstado(document.getElementById("fechaCompleta").value)
      };
      
      const counts = { "Netflix": 5, "Disney": 7, "HBO Max": 5, "Paramount": 5, "Prime video": 6 };
      const num = counts[plataforma] || 1;
      
      showLoader(`Creando ${num} perfiles...`);
      for(let i=1; i<=num; i++) {
        await upsertPerfil({ ...base, id: generarIdUnico(), perfilNombre: "Perfil " + i });
      }
      hideLoader();
      toast(`✅ Cuenta de ${plataforma} cargada (${num} perfiles)`);
      ["cuentaIdCompleta", "mailCompleta", "passCompleta", "fechaCompleta", "proveedorCompleta", "whatsappCompleta", "obsCompleta", "precioCompleta", "otraPlatCompleta"].forEach(id => {
        const el = document.getElementById(id);
        if(el) el.value = "";
      });
    }
    
    // ============ RENDERIZADO ============
    function actualizarDashboard() {
      if(!document.getElementById("totalPerfiles")) return;
      document.getElementById("totalPerfiles").innerText = perfiles.length;
      document.getElementById("libresHoy").innerText = perfiles.filter(p => p.estado === "libre").length;
      document.getElementById("vencenHoy").innerText = perfiles.filter(p => p.estado === "proximo").length;
      
      const ventas = perfiles.filter(p => p.fechaVenta && p.fechaVenta.startsWith(new Date().toISOString().split('T')[0]));
      document.getElementById("ventasHoy").innerText = ventas.length;
      document.getElementById("totalGanado").innerText = "$" + perfiles.reduce((s,p) => s + (p.precioVenta || 0), 0).toLocaleString();
    }
    
    function renderListaPerfiles() {
      const container = document.getElementById("listaPerfilesCont");
      if(!container) return;
      
      const busqueda = document.getElementById("buscarTexto").value.toLowerCase();
      const fPlat = document.getElementById("filtroPlataforma").value;
      const fEst = document.getElementById("filtroEstado").value;
      
      let filtered = perfiles.filter(p => {
        const matchesBusqueda = !busqueda || p.mail.toLowerCase().includes(busqueda) || p.perfilNombre.toLowerCase().includes(busqueda) || (p.cuentaId && p.cuentaId.toLowerCase().includes(busqueda));
        const matchesPlat = !fPlat || p.plataforma === fPlat;
        const matchesEst = !fEst || p.estado === fEst;
        return matchesBusqueda && matchesPlat && matchesEst;
      });
      
      if(filtered.length === 0) {
        container.innerHTML = '<div class="empty-state"><i class="fas fa-search"></i><p>No se encontraron perfiles</p></div>';
        return;
      }
      
      container.innerHTML = filtered.map(p => `
        <div class="profile-card ${p.estado}">
          <div class="card-header">
            <span class="plat-badge">${p.plataforma}</span>
            <span class="status-badge ${p.estado}">${estadoTexto(p.estado)}</span>
          </div>
          <div class="card-body">
            <h3>${p.perfilNombre}</h3>
            <p><i class="fas fa-envelope"></i> ${p.mail}</p>
            <p><i class="fas fa-key"></i> ${p.password}</p>
            ${p.pin ? `<p><i class="fas fa-thumbtack"></i> PIN: ${p.pin}</p>` : ''}
            <p><i class="fas fa-calendar-alt"></i> Vence: ${formatearFecha(p.fechaVencimiento)}</p>
            ${p.whatsappCliente ? `<p><i class="fab fa-whatsapp"></i> Cliente: ${p.whatsappCliente}</p>` : ''}
          </div>
          <div class="card-actions">
            <button onclick="abrirWhatsApp('${p.whatsappProveedor}', '${plantillaProveedor(p)}')" class="btn-icon" title="WhatsApp Proveedor"><i class="fab fa-whatsapp"></i></button>
            <button onclick="editarPerfil('${p.id}')" class="btn-icon" title="Editar"><i class="fas fa-edit"></i></button>
            <button onclick="renovarPerfil('${p.id}')" class="btn-icon" title="Renovar"><i class="fas fa-sync"></i></button>
            ${p.estado === 'libre' ? `<button onclick="mostrarVentaModal('${p.id}')" class="btn-icon sell" title="Vender"><i class="fas fa-tag"></i></button>` : ''}
            <button onclick="eliminarPerfil('${p.id}')" class="btn-icon delete" title="Borrar"><i class="fas fa-trash"></i></button>
          </div>
        </div>
      `).join('');
    }
    
    function actualizarPanelMiCuenta() {
      if(!currentUser) return;
      document.getElementById("perfilEmail").innerText = currentUser.email;
      document.getElementById("perfilPlan").innerText = planEstado === "token" ? "PRO PREMIUM" : (planEstado === "demo" ? "DEMO" : "BLOQUEADO");
      document.getElementById("perfilDiasRestantes").innerText = diasPruebaRestantes + " días";
      
      const bar = document.getElementById("progresoBarra");
      if(bar) {
        const perc = planEstado === "token" ? (diasPruebaRestantes/30)*100 : (diasPruebaRestantes/3)*100;
        bar.style.width = Math.min(100, perc) + "%";
      }
    }
    
    function actualizarTodo() {
      actualizarDashboard();
      renderListaPerfiles();
      actualizarPanelMiCuenta();
    }
    
    function cambiarTab(tabId) {
      document.querySelectorAll(".tab-panel").forEach(p => p.classList.remove("active"));
      document.getElementById("tab-" + tabId)?.classList.add("active");
      document.querySelectorAll(".nav-btn").forEach(b => b.classList.remove("active"));
      document.querySelector(`.nav-btn[data-nav="${tabId}"]`)?.classList.add("active");
      actualizarTodo();
    }
    
    // ============ INICIALIZACIÓN ============
    auth.onAuthStateChanged(user => {
      if(user) {
        currentUser = user;
        document.getElementById("loginWrapper").style.display = "none";
        document.getElementById("appContainer").style.display = "flex";
        document.getElementById("bottomNavBar").style.display = "flex";
        verificarSuscripcion(user.uid);
        iniciarListenerFirestore(user.uid);
      } else {
        currentUser = null;
        document.getElementById("loginWrapper").style.display = "flex";
        document.getElementById("appContainer").style.display = "none";
        document.getElementById("bottomNavBar").style.display = "none";
      }
    });
    
    // Event Listeners Globales
    document.querySelectorAll(".nav-btn").forEach(btn => {
      btn.onclick = () => cambiarTab(btn.dataset.nav);
    });
    
    document.querySelectorAll(".carga-tab").forEach(btn => {
      btn.onclick = () => {
        document.querySelectorAll(".carga-tab").forEach(b => b.classList.remove("active"));
        btn.classList.add("active");
        const mod = btn.dataset.mod;
        document.getElementById("modo-completa").style.display = mod === "completa" ? "block" : "none";
        document.getElementById("modo-individual").style.display = mod === "individual" ? "block" : "none";
      };
    });
    
    document.getElementById("btnValidarToken")?.addEventListener("click", async () => {
      const t = document.getElementById("tokenInput").value;
      if(!t) return toast("Ingresá un token");
      showLoader("Validando...");
      const res = await validarToken(t, currentUser.uid);
      hideLoader();
      toast(res.mensaje);
    });
    
    document.getElementById("logoutBtn")?.addEventListener("click", () => auth.signOut());
    
    document.getElementById("btnGuardarIndividual").onclick = guardarPerfilIndividual;
    document.getElementById("btnGuardarCompleta").onclick = guardarCuentaCompleta;

    // Nexus IA Bubble (Simplificado)
    (function() {
      const b = document.createElement("div");
      b.className = "nexus-bubble";
      b.innerHTML = '<i class="fas fa-brain"></i>';
      b.onclick = () => toast("Nexus IA: ¿En qué puedo ayudarte hoy?");
      document.body.appendChild(b);
    })();
