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
      "SF-N9K4-P3S7-W6X2","SF-P2M5-R8T4-Y9Z1","SF-Q4N7-V1W6-A3B8","SF-R6P9-X5Y2-C7D3",
      "SF-S8R1-Z7A4-E9F6","SF-T1S3-B6C8-G2H5","SF-U3T5-D9F1-J4K7","SF-V5U7-G2H3-M6N9",
      "SF-W7V9-J5K8-P1Q4","SF-X9W2-L7M3-R5S8","SF-Y2X4-N8P6-T9U3","SF-Z4Y6-Q1R7-V2W5",
      "SF-A6Z8-S3T9-X7Y1","SF-B8A1-U5V2-Z9W4","SF-C1B3-W7X5-A2D6","SF-D3C5-Y9Z1-B4F8",
      "SF-E5D7-A2B6-C8G3","SF-F7E9-C4D8-H1J5","SF-G9F2-E6H3-K4L7","SF-H2G4-F8J5-M6N9",
      "SF-J4H6-G1K7-P8Q2","SF-K6J8-H3L9-R1S4","SF-L8K1-J5M2-T3U6","SF-M1L3-K7N4-V5W8",
      "SF-N3M5-L9P6-X7Y2","SF-P5N7-M2Q8-Z9A4","SF-Q7P9-N4R1-B3C6","SF-R9Q2-P6S3-D5F8",
      "SF-S2R4-Q8T5-G7H1","SF-T4S6-R1U7-J9K3","SF-U6T8-S3V9-L2M5","SF-V8U1-T5W2-N4P7",
      "SF-W1V3-U7X4-Q6R9","SF-X3W5-V9Y6-S8T2","SF-Y5X7-W2Z8-U4V6","SF-Z7Y9-X4A1-W6B3",
      "SF-A9Z2-Y6B3-X8C5","SF-B2A4-Z8C5-Y1D7","SF-C4B6-A1D7-Z3E9","SF-D6C8-B3E9-A5F2",
      "SF-E8D1-C5F2-B7G4","SF-F1E3-D7G4-C9H6","SF-G3F5-E9H6-D2J8","SF-H5G7-F2J8-E4K1",
      "SF-J7H9-G4K1-F6L3","SF-K9J2-H6L3-G8M5","SF-L2K4-J8M5-H1N7","SF-M4L6-K1N7-J3P9",
      "SF-N6M8-L3P9-K5Q2","SF-P8N1-M5Q2-L7R4","SF-Q1P3-N7R4-M9S6","SF-R3Q5-P9S6-N2T8",
      "SF-S5R7-Q2T8-P4U1","SF-T7S9-R4U1-Q6V3","SF-U9T2-S6V3-R8W5","SF-V2U4-T8W5-S1X7",
      "SF-W4V6-U1X7-T3Y9","SF-X6W8-V3Y9-U5Z2","SF-Y8X1-W5Z2-V7A4","SF-Z1Y3-X7A4-W9B6",
      "SF-A3Z5-Y9B6-X2C8","SF-B5A7-Z2C8-Y4D1","SF-C7B9-A4D1-Z6E3","SF-D9C2-B6E3-A8F5",
      "SF-E2D4-C8F5-B1G7","SF-F4E6-D1G7-C3H9","SF-G6F8-E3H9-D5J2","SF-H8G1-F5J2-E7K4",
      "SF-J1H3-G7K4-F9L6","SF-K3J5-H9L6-G2M8","SF-L5K7-J2M8-H4N1","SF-M7L9-K4N1-J6P3",
      "SF-N9M2-L6P3-K8Q5","SF-P2N4-M8Q5-L1R7","SF-Q4P6-N1R7-M3S9","SF-R6Q8-P3S9-N5T2",
      "SF-S8R1-Q5T2-P7U4","SF-T1S3-R7U4-Q9V6","SF-U3T5-S9V6-R2W8","SF-V5U7-T2W8-S4X1",
      "SF-W7V9-U4X1-T6Y3","SF-X9W2-V6Y3-U8Z5","SF-Y2X4-W8Z5-V1A7","SF-Z4Y6-X1A7-W3B9",
      "SF-A6Z8-Y3B9-X5C2","SF-B8A1-Z5C2-Y7D4","SF-C1B3-A7D4-Z9E6","SF-D3C5-B9E6-A2F8",
      "SF-E5D7-C2F8-B4G1","SF-F7E9-D4G1-C6H3","SF-G9F2-E6H3-D8J5","SF-H2G4-F8J5-E1K7",
      "SF-J4H6-G1K7-F3L9","SF-K6J8-H3L9-G5M2","SF-L8K1-J5M2-H7N4","SF-M1L3-K7N4-J9P6",
      "SF-N3M5-L9P6-K2Q8","SF-P5N7-M2Q8-L4R1","SF-Q7P9-N4R1-M6S3","SF-R9Q2-P6S3-N8T5",
      "SF-S2R4-Q8T5-P1U7","SF-T4S6-R1U7-Q3V9","SF-U6T8-S3V9-R5W2","SF-V8U1-T5W2-S7X4",
      "SF-W1V3-U7X4-T9Y6","SF-X3W5-V9Y6-U2Z8","SF-Y5X7-W2Z8-V4A1","SF-Z7Y9-X4A1-W6B3"
    ]);
    
    // ============ VARIABLES GLOBALES ============
    let perfiles = [];
    let DIAS_PROXIMO = 3;
    let kioscoMode = false;
    let notificationsEnabled = true;
    let ordenAsc = true;
    let currentUser = null;
    let editandoId = null;
    let pendingVentaId = null;
    let unsubscribeFirestore = null;
    let filtroTimeout = null;
    let appDesbloqueada = true;
    let diasPruebaRestantes = DIAS_PRUEBA_GRATIS;
    let planEstado = "demo";
    let versionLocal = 0;
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
      const p = str.split("-");
      if(p.length !== 3) return null;
      return new Date(p[0], p[1] - 1, p[2]);
    }
    
    function formatearFecha(str) {
      if(!str) return "";
      const f = parseFecha(str);
      if(!f) return str;
      return f.getDate().toString().padStart(2, '0') + '/' + (f.getMonth() + 1).toString().padStart(2, '0') + '/' + f.getFullYear();
    }
    
    function aInputDate(d) {
      return d.getFullYear() + '-' + (d.getMonth() + 1).toString().padStart(2, '0') + '-' + d.getDate().toString().padStart(2, '0');
    }
    
    function obtenerEstado(fechaStr) {
      if(!fechaStr) return "libre";
      const hoy = new Date();
      hoy.setHours(0, 0, 0, 0);
      const venc = parseFecha(fechaStr);
      if(!venc) return "libre";
      venc.setHours(0, 0, 0, 0);
      const diff = Math.round((venc - hoy) / 86400000);
      if(diff < 0) return "vencido";
      if(diff <= DIAS_PROXIMO) return "proximo";
      return "activo";
    }
    
    function estadoTexto(e) {
      const mapa = { activo: "Activo", proximo: "Próximo", vencido: "Vencido", libre: "Libre", vendido: "Vendido" };
      return mapa[e] || e;
    }
    
    function estadoClase(e) {
      const mapa = { activo: "badge-success", proximo: "badge-warning", vencido: "badge-danger", libre: "badge-info", vendido: "badge-vendido" };
      return mapa[e] || "badge";
    }
    
    function abrirWhatsApp(numero, mensaje) {
      if(!numero) {
        toast("⚠️ No hay número de WhatsApp");
        return;
      }
      const url = "https://wa.me/" + numero.replace(/\D/g, '') + "?text=" + encodeURIComponent(mensaje);
      window.open(url, "_blank");
    }
    
    // ============ PLANTILLAS ============
    function plantillaCliente(p, esVenta) {
      const fechaVence = p.fechaVencimiento ? formatearFecha(p.fechaVencimiento) : "Sin fecha asignada";
      const garantia = p.fechaVencimiento ? "hasta " + fechaVence : "durante el período contratado";
      const proveedorMostrar = p.proveedor || "StreamFlow Pro";
      const whatsappMostrar = p.whatsappProveedor || "";
      
      return (esVenta ? "🎉 *¡CUENTA ACTIVADA!* 🎉" : "🔄 *RENOVACIÓN DE CUENTA*") + 
             "\n\n📺 *Plataforma:* " + p.plataforma +
             "\n👤 *Perfil:* " + p.perfilNombre +
             (p.pin ? "\n🔢 *PIN:* " + p.pin : "") +
             "\n📧 *Usuario:* " + p.mail +
             "\n🔐 *Contraseña:* " + p.password +
             "\n📅 *Vence:* " + fechaVence +
             (p.precioVenta ? "\n💰 *Precio:* $" + p.precioVenta : "") +
             "\n\n━━━━━━━━━━━━━━━" +
             "\n📋 *REGLAS DE USO Y SEGURIDAD*" +
             "\n━━━━━━━━━━━━━━━" +
             "\n\n✅ *Perfil 100% seguro y verificado*" +
             "\n🔒 *No modificar:* correo, contraseña ni PIN del perfil" +
             "\n🚫 *Prohibido:* compartir el acceso con terceros" +
             "\n👤 *Uso exclusivo:* solo el comprador autorizado" +
             "\n⚠️ *No cambiar:* configuración de cuenta ni datos de facturación" +
             "\n🛡️ *Garantía:* " + garantia + ". Si tenés problemas técnicos, contactanos de inmediato." +
             "\n📞 *Soporte:* " + proveedorMostrar + (whatsappMostrar ? " - +" + whatsappMostrar : "") +
             "\n🔄 *Renovación:* avisamos con anticipación para que no te quedes sin servicio." +
             "\n\n━━━━━━━━━━━━━━━" +
             "\n💎 *CUENTA PREMIUM GARANTIZADA*" +
             "\n━━━━━━━━━━━━━━━" +
             "\n\n✅ Guardá estos datos en un lugar seguro." +
             "\n🙏 ¡Gracias por confiar en nosotros!" +
             (p.observaciones ? "\n📝 Notas: " + p.observaciones : "");
    }
    
    function plantillaProveedor(p) {
      return "🚨 *CONSULTA DE PERFIL*\n\n" +
             "📺 *Plataforma:* " + p.plataforma +
             "\n👤 *Perfil:* " + p.perfilNombre +
             "\n📧 *Usuario:* " + p.mail +
             "\n🔐 *Contraseña:* " + p.password +
             (p.pin ? "\n🔢 *PIN:* " + p.pin : "") +
             "\n📅 *Vencimiento:* " + (p.fechaVencimiento ? formatearFecha(p.fechaVencimiento) : "Sin fecha") +
             "\n👤 *Proveedor:* " + (p.proveedor || "No especificado") +
             "\n📞 Necesito información sobre este perfil.";
    }
    
    // ============ SINCRONIZACIÓN CON FIRESTORE ============
    async function guardarPerfiles() {
      if(!currentUser) return;
      showLoader("Guardando en la nube...");
      try {
        await db.collection("usuarios").doc(currentUser.uid).set({
          perfiles: perfiles,
          ultimaActualizacion: new Date().toISOString(),
          version: Date.now()
        }, { merge: true });
        toast("✅ Datos guardados en la nube");
        actualizarSyncStatus("sincronizado");
        document.getElementById("saveText").innerText = "Sincronizado en la nube";
      } catch(e) {
        console.error(e);
        toast("⚠️ Sin conexión. Datos guardados localmente");
        actualizarSyncStatus("error");
        document.getElementById("saveText").innerText = "Guardado local (sin conexión)";
      } finally {
        hideLoader();
      }
    }
    
    async function cargarPerfiles() {
      if(!currentUser) return;
      showLoader("Cargando datos desde la nube...");
      try {
        const doc = await db.collection("usuarios").doc(currentUser.uid).get();
        if(doc.exists && doc.data().perfiles) {
          perfiles = doc.data().perfiles;
          toast("✅ Datos cargados desde la nube");
          actualizarSyncStatus("sincronizado");
          document.getElementById("saveText").innerText = "Sincronizado en la nube";
        } else {
          perfiles = [];
          toast("📦 No hay datos, comenzando con perfil vacío");
        }
        actualizarTodo();
      } catch(e) {
        console.error(e);
        toast("⚠️ Sin conexión. Usando datos locales");
        actualizarSyncStatus("error");
        document.getElementById("saveText").innerText = "Modo local (sin conexión)";
        const localBackup = localStorage.getItem("streamflow_perfiles_backup");
        if(localBackup) {
          try {
            perfiles = JSON.parse(localBackup);
            actualizarTodo();
          } catch(e2) {}
        }
      } finally {
        hideLoader();
      }
    }
    
    function iniciarListenerFirestore(uid) {
      if(unsubscribeFirestore) unsubscribeFirestore();
      if(!uid) return;
      unsubscribeFirestore = db.collection("usuarios").doc(uid).onSnapshot((snap) => {
        if(snap.exists && snap.data().perfiles) {
          const serverData = snap.data().perfiles;
          if(JSON.stringify(serverData) !== JSON.stringify(perfiles)) {
            perfiles = serverData;
            localStorage.setItem("streamflow_perfiles_backup", JSON.stringify(perfiles));
            actualizarTodo();
            toast("🔄 Datos actualizados desde la nube");
          }
        }
      }, (error) => {
        console.error("Error en listener:", error);
      });
    }
    
    function actualizarSyncStatus(estado) {
      const btn = document.getElementById("syncStatus");
      if(!btn) return;
      if(estado === "sincronizado") {
        btn.className = "sync-status sincronizado";
        btn.title = "Sincronizado con la nube";
      } else if(estado === "esperando") {
        btn.className = "sync-status esperando";
        btn.title = "Sincronizando...";
      } else {
        btn.className = "sync-status error";
        btn.title = "Sin conexión - Modo local";
      }
    }
    
    // ============ SISTEMA DE SUSCRIPCIÓN Y TOKENS ============
    async function verificarSuscripcion(uid) {
      if(!uid) return;
      try {
        const suscRef = db.collection("usuarios").doc(uid).collection("suscripcion").doc("estado");
        const snap = await suscRef.get();
        const ahora = new Date();
        
        if(!snap.exists) {
          const fechaFinPrueba = new Date(ahora);
          fechaFinPrueba.setDate(fechaFinPrueba.getDate() + DIAS_PRUEBA_GRATIS);
          await suscRef.set({
            fechaPrimerIngreso: ahora.toISOString(),
            estado: "prueba",
            fechaExpiracion: fechaFinPrueba.toISOString()
          });
          appDesbloqueada = true;
          diasPruebaRestantes = DIAS_PRUEBA_GRATIS;
          planEstado = "demo";
          actualizarBadgePlan();
          actualizarSemaforo();
          return;
        }
        
        const data = snap.data();
        const fechaExpiracion = new Date(data.fechaExpiracion);
        
        if(data.estado === "prueba") {
          if(ahora < fechaExpiracion) {
            appDesbloqueada = true;
            diasPruebaRestantes = Math.ceil((fechaExpiracion - ahora) / 86400000);
            planEstado = "demo";
          } else {
            appDesbloqueada = false;
            diasPruebaRestantes = 0;
            planEstado = "bloqueado";
          }
        } else if(data.estado === "token") {
          if(ahora < fechaExpiracion) {
            appDesbloqueada = true;
            diasPruebaRestantes = Math.ceil((fechaExpiracion - ahora) / 86400000);
            planEstado = "token";
          } else {
            appDesbloqueada = false;
            diasPruebaRestantes = 0;
            planEstado = "bloqueado";
          }
        }
        
        actualizarBadgePlan();
        actualizarSemaforo();
        aplicarBloqueoApp();
        actualizarPanelMiCuenta();
      } catch(e) {
        console.error("Error al verificar suscripción:", e);
        appDesbloqueada = true;
        planEstado = "demo";
        actualizarBadgePlan();
      }
    }
    
    async function validarToken(token, uid) {
      if(!uid) return { valido: false, mensaje: "Usuario no autenticado" };
      token = token.trim().toUpperCase();
      if(!TOKENS_VALIDOS.has(token)) return { valido: false, mensaje: "❌ Token inválido" };
      try {
        const tokenRef = db.collection("tokens_usados").doc(token);
        const snap = await tokenRef.get();
        if(snap.exists && snap.data().usadoPor !== uid) {
          return { valido: false, mensaje: "❌ Token ya usado por otra cuenta" };
        }
        const ahora = new Date();
        const expiracion = new Date(ahora);
        expiracion.setDate(expiracion.getDate() + DIAS_TOKEN);
        await tokenRef.set({
          token: token,
          usadoPor: uid,
          fechaActivacion: ahora.toISOString(),
          fechaExpiracion: expiracion.toISOString()
        });
        const suscRef = db.collection("usuarios").doc(uid).collection("suscripcion").doc("estado");
        await suscRef.set({
          estado: "token",
          fechaExpiracion: expiracion.toISOString()
        }, { merge: true });
        appDesbloqueada = true;
        diasPruebaRestantes = DIAS_TOKEN;
        planEstado = "token";
        actualizarBadgePlan();
        actualizarSemaforo();
        aplicarBloqueoApp();
        actualizarPanelMiCuenta();
        return { valido: true, mensaje: "✅ Token activado por 30 días" };
      } catch(e) {
        console.error(e);
        return { valido: false, mensaje: "⚠️ Error al validar token" };
      }
    }
    
    function actualizarBadgePlan() {
      const badge = document.getElementById("planBadge");
      if(!badge) return;
      if(planEstado === "token") {
        badge.className = "plan-badge pro";
        badge.innerHTML = '<i class="fas fa-crown"></i> PRO ' + diasPruebaRestantes + 'd';
      } else if(planEstado === "bloqueado") {
        badge.className = "plan-badge blocked";
        badge.innerHTML = '<i class="fas fa-lock"></i> BLOQUEADO';
      } else {
        badge.className = "plan-badge demo";
        badge.innerHTML = '<i class="fas fa-gift"></i> DEMO ' + diasPruebaRestantes + 'd';
      }
    }
    
    function actualizarSemaforo() {
      const semaforoPerfil = document.getElementById("semaforoPerfil");
      let color = "", texto = "", icono = "";
      
      if(planEstado === "bloqueado") {
        color = "semaforo-rojo";
        texto = "BLOQUEADO - Ingresá un token";
        icono = '<i class="fas fa-ban"></i>';
      } else if(planEstado === "token") {
        color = "semaforo-verde";
        texto = "PRO ACTIVO - " + diasPruebaRestantes + " días";
        icono = '<i class="fas fa-check-circle"></i>';
      } else {
        if(diasPruebaRestantes <= 1) {
          color = "semaforo-rojo";
          texto = "DEMO - ÚLTIMO DÍA";
          icono = '<i class="fas fa-exclamation-triangle"></i>';
        } else if(diasPruebaRestantes === 2) {
          color = "semaforo-amarillo";
          texto = "DEMO - 2 DÍAS";
          icono = '<i class="fas fa-clock"></i>';
        } else {
          color = "semaforo-verde";
          texto = "DEMO - " + diasPruebaRestantes + " DÍAS";
          icono = '<i class="fas fa-gift"></i>';
        }
      }
      
      if(semaforoPerfil) {
        semaforoPerfil.innerHTML = '<div class="semaforo ' + color + '" style="display:inline-flex;">' + icono + ' Estado: ' + texto + '</div>';
      }
    }
    
    function aplicarBloqueoApp() {
      const bloqueoMsg = document.getElementById("bloqueoAppMsg");
      if(planEstado === "bloqueado") {
        if(!bloqueoMsg) {
          const msg = document.createElement("div");
          msg.id = "bloqueoAppMsg";
          msg.className = "bloqueo-app-msg";
          msg.innerHTML = '<i class="fas fa-lock"></i><strong>App bloqueada</strong><br>Tu período de prueba ha expirado o tu token ha vencido.<br>Ingresá un token en Ajustes para continuar.<br><small>⚠️ Tus datos NO se perderán al ingresar un nuevo token.</small>';
          const mainContent = document.getElementById("mainContent");
          if(mainContent) mainContent.insertBefore(msg, mainContent.firstChild);
        }
        if(kioscoMode) {
          toast("Modo bloqueado: solo lectura. Ingresá un token para editar.");
        }
      } else {
        if(bloqueoMsg) bloqueoMsg.remove();
      }
    }
    
    // ============ CRUD DE PERFILES ============
    async function venderPerfil(id, datos) {
      const p = perfiles.find(p => p.id === id);
      if(!p) return;
      
      // Actualizar el perfil con los datos editados en el modal
      p.plataforma = datos.plataforma || p.plataforma;
      p.cuentaId = datos.cuentaId || p.cuentaId;
      p.perfilNombre = datos.perfilNombre || p.perfilNombre;
      p.mail = datos.mail || p.mail;
      p.password = datos.password || p.password;
      p.pin = datos.pin || p.pin;
      p.fechaVencimiento = datos.fechaVencimiento || p.fechaVencimiento;
      p.proveedor = datos.proveedor || p.proveedor;
      p.observaciones = datos.observaciones || p.observaciones;
      
      p.precioVenta = parseFloat(datos.precio);
      p.whatsappCliente = datos.cliente || "";
      p.fechaVenta = new Date().toISOString();
      p.estado = "vendido";
      
      if(!p.fechaVencimiento) {
        let nueva = new Date();
        nueva.setDate(nueva.getDate() + 30);
        p.fechaVencimiento = aInputDate(nueva);
      }
      p.estado = obtenerEstado(p.fechaVencimiento);
      if(p.estado === "libre") p.estado = "vendido";
      
      await guardarPerfiles();
      localStorage.setItem("streamflow_perfiles_backup", JSON.stringify(perfiles));
      actualizarTodo();
      
      const mensaje = plantillaCliente(p, true);
      if(datos.cliente && datos.cliente.trim() !== "") {
        abrirWhatsApp(datos.cliente, mensaje);
        toast("✅ Venta registrada. Redirigiendo a WhatsApp...");
      } else {
        toast("✅ Venta registrada. Plantilla copiada al portapapeles");
        navigator.clipboard.writeText(mensaje);
      }
    }
    
    async function renovarPerfil(id) {
      const p = perfiles.find(p => p.id === id);
      if(p) {
        let base = p.fechaVencimiento ? parseFecha(p.fechaVencimiento) : new Date();
        base.setMonth(base.getMonth() + 1);
        p.fechaVencimiento = aInputDate(base);
        p.estado = obtenerEstado(p.fechaVencimiento);
        await guardarPerfiles();
        localStorage.setItem("streamflow_perfiles_backup", JSON.stringify(perfiles));
        actualizarTodo();
        toast("Renovado hasta " + formatearFecha(p.fechaVencimiento));
      }
    }
    
    async function marcarLibre(id) {
      const p = perfiles.find(p => p.id === id);
      if(p && confirm("¿Marcar este perfil como libre?")) {
        p.estado = "libre";
        p.fechaVencimiento = null;
        p.fechaVenta = null;
        p.precioVenta = null;
        p.whatsappCliente = "";
        await guardarPerfiles();
        localStorage.setItem("streamflow_perfiles_backup", JSON.stringify(perfiles));
        actualizarTodo();
        toast("Perfil marcado como libre");
      }
    }
    
    async function eliminarPerfil(id) {
      if(kioscoMode) {
        toast("Modo kiosco: no se puede eliminar");
        return;
      }
      if(confirm("¿Eliminar este perfil permanentemente?")) {
        perfiles = perfiles.filter(p => p.id !== id);
        await guardarPerfiles();
        localStorage.setItem("streamflow_perfiles_backup", JSON.stringify(perfiles));
        actualizarTodo();
        toast("Perfil eliminado");
      }
    }
    
    async function duplicarPerfil(id) {
      const orig = perfiles.find(p => p.id === id);
      if(orig) {
        const nombre = prompt("Nombre del nuevo perfil:", orig.perfilNombre + " (copia)");
        if(nombre && nombre.trim()) {
          const copia = { 
            ...orig, 
            id: generarIdUnico(), 
            perfilNombre: nombre.trim(), 
            estado: "libre", 
            fechaVenta: null, 
            precioVenta: null, 
            whatsappCliente: "" 
          };
          perfiles.push(copia);
          await guardarPerfiles();
          localStorage.setItem("streamflow_perfiles_backup", JSON.stringify(perfiles));
          actualizarTodo();
          toast("Perfil duplicado");
        }
      }
    }
    
    function editarPerfil(id) {
      if(kioscoMode) {
        toast("Modo kiosco: no se puede editar");
        return;
      }
      const p = perfiles.find(p => p.id === id);
      if(!p) return;
      editandoId = id;
      
      const conocidas = ["Netflix", "Netflix indiv", "Disney", "HBO Max", "Prime video", "Paramount", "Crunchyroll", "Spoty", "YouTube"];
      if(!conocidas.includes(p.plataforma)) {
        document.getElementById("platIndividual").value = "Otros";
        document.getElementById("otraPlatIndividualDiv").style.display = "block";
        document.getElementById("otraPlatIndividual").value = p.plataforma;
      } else {
        document.getElementById("platIndividual").value = p.plataforma;
        document.getElementById("otraPlatIndividualDiv").style.display = "none";
      }
      document.getElementById("cuentaIdIndividual").value = p.cuentaId || "";
      document.getElementById("nombrePerfilIndividual").value = p.perfilNombre || "";
      document.getElementById("pinIndividual").value = p.pin || "";
      document.getElementById("mailIndividual").value = p.mail || "";
      document.getElementById("passIndividual").value = p.password || "";
      document.getElementById("fechaIndividual").value = p.fechaVencimiento || "";
      document.getElementById("precioIndividual").value = p.precio || "";
      document.getElementById("proveedorIndividual").value = p.proveedor || "";
      document.getElementById("whatsappIndividual").value = p.whatsappProveedor || "";
      document.getElementById("obsIndividual").value = p.observaciones || "";
      
      document.querySelectorAll(".carga-tab").forEach(b => b.classList.remove("active"));
      document.querySelector(".carga-tab[data-mod='individual']").classList.add("active");
      document.getElementById("modo-completa").style.display = "none";
      document.getElementById("modo-individual").style.display = "block";
      document.getElementById("modo-masiva").style.display = "none";
      document.getElementById("btnCancelarEdicion").style.display = "inline-block";
      document.getElementById("btnGuardarIndividual").textContent = "Guardar cambios";
      
      cambiarTab("carga");
    }
    
    async function guardarPerfilEditado() {
      const id = editandoId;
      let plataforma = document.getElementById("platIndividual").value;
      if(plataforma === "Otros") {
        plataforma = document.getElementById("otraPlatIndividual").value.trim();
        if(!plataforma) {
          toast("Escribí el nombre de la plataforma");
          return;
        }
      }
      const index = perfiles.findIndex(p => p.id === id);
      if(index !== -1) {
        perfiles[index] = {
          ...perfiles[index],
          plataforma: plataforma,
          cuentaId: document.getElementById("cuentaIdIndividual").value,
          perfilNombre: document.getElementById("nombrePerfilIndividual").value,
          mail: document.getElementById("mailIndividual").value,
          password: document.getElementById("passIndividual").value,
          pin: document.getElementById("pinIndividual").value,
          fechaVencimiento: document.getElementById("fechaIndividual").value || null,
          proveedor: document.getElementById("proveedorIndividual").value,
          whatsappProveedor: document.getElementById("whatsappIndividual").value,
          observaciones: document.getElementById("obsIndividual").value,
          precio: document.getElementById("precioIndividual").value ? Number(document.getElementById("precioIndividual").value) : null,
          estado: document.getElementById("fechaIndividual").value ? obtenerEstado(document.getElementById("fechaIndividual").value) : "libre"
        };
        await guardarPerfiles();
        localStorage.setItem("streamflow_perfiles_backup", JSON.stringify(perfiles));
        actualizarTodo();
        toast("✅ Perfil actualizado");
        editandoId = null;
        limpiarFormularioIndividual();
        document.getElementById("btnCancelarEdicion").style.display = "none";
        document.getElementById("btnGuardarIndividual").textContent = "Guardar perfil";
      }
    }
    
    function limpiarFormularioIndividual() {
      document.getElementById("platIndividual").value = "Netflix";
      document.getElementById("cuentaIdIndividual").value = "";
      document.getElementById("nombrePerfilIndividual").value = "";
      document.getElementById("pinIndividual").value = "";
      document.getElementById("mailIndividual").value = "";
      document.getElementById("passIndividual").value = "";
      document.getElementById("fechaIndividual").value = "";
      document.getElementById("precioIndividual").value = "";
      document.getElementById("proveedorIndividual").value = "";
      document.getElementById("whatsappIndividual").value = "";
      document.getElementById("obsIndividual").value = "";
      document.getElementById("otraPlatIndividual").value = "";
      document.getElementById("otraPlatIndividualDiv").style.display = "none";
    }
    
    async function guardarPerfilIndividual() {
      let plataforma = document.getElementById("platIndividual").value;
      if(plataforma === "Otros") {
        plataforma = document.getElementById("otraPlatIndividual").value.trim();
        if(!plataforma) {
          toast("Escribí el nombre de la plataforma");
          return;
        }
      }
      const cuentaId = document.getElementById("cuentaIdIndividual").value;
      const nombrePerfil = document.getElementById("nombrePerfilIndividual").value;
      const mail = document.getElementById("mailIndividual").value;
      const password = document.getElementById("passIndividual").value;
      const fecha = document.getElementById("fechaIndividual").value || null;
      const proveedor = document.getElementById("proveedorIndividual").value;
      const whatsapp = document.getElementById("whatsappIndividual").value;
      const obs = document.getElementById("obsIndividual").value;
      const precio = document.getElementById("precioIndividual").value;
      const pin = document.getElementById("pinIndividual").value;
      
      if(!plataforma || !cuentaId || !nombrePerfil || !mail || !password || !proveedor) {
        toast("Completá todos los campos");
        return;
      }
      
      perfiles.push({
        id: generarIdUnico(),
        plataforma: plataforma,
        cuentaId: cuentaId,
        perfilNombre: nombrePerfil,
        mail: mail,
        password: password,
        pin: pin || "",
        fechaVencimiento: fecha,
        proveedor: proveedor,
        whatsappProveedor: whatsapp,
        observaciones: obs,
        precio: precio ? Number(precio) : null,
        estado: fecha ? obtenerEstado(fecha) : "libre",
        fechaVenta: null,
        precioVenta: null,
        whatsappCliente: ""
      });
      
      await guardarPerfiles();
      localStorage.setItem("streamflow_perfiles_backup", JSON.stringify(perfiles));
      actualizarTodo();
      toast("✅ Perfil guardado");
      limpiarFormularioIndividual();
    }
    
    async function guardarCuentaCompleta() {
      let plataforma = document.getElementById("platCompleta").value;
      if(plataforma === "Otros") {
        plataforma = document.getElementById("otraPlatCompleta").value.trim();
        if(!plataforma) {
          toast("Escribí el nombre de la plataforma");
          return;
        }
      }
      const cuentaId = document.getElementById("cuentaIdCompleta").value;
      const mail = document.getElementById("mailCompleta").value;
      const password = document.getElementById("passCompleta").value;
      const fecha = document.getElementById("fechaCompleta").value || null;
      const proveedor = document.getElementById("proveedorCompleta").value;
      const whatsapp = document.getElementById("whatsappCompleta").value;
      const obs = document.getElementById("obsCompleta").value;
      const precio = document.getElementById("precioCompleta").value;
      
      if(!plataforma || !cuentaId || !mail || !password || !proveedor) {
        toast("Completá todos los campos");
        return;
      }
      
      const cantidades = {
        "Netflix": 5, "Netflix indiv": 1, "Disney": 7, "HBO Max": 5,
        "Paramount": 5, "Crunchyroll": 1, "Prime video": 6, "Spoty": 1, "YouTube": 1
      };
      const cantidad = cantidades[plataforma] || 1;
      
      for(let i = 1; i <= cantidad; i++) {
        perfiles.push({
          id: generarIdUnico(),
          plataforma: plataforma,
          cuentaId: cuentaId,
          mail: mail,
          password: password,
          perfilNombre: cantidad === 1 ? "Principal" : "Perfil " + i,
          pin: "",
          fechaVencimiento: fecha,
          proveedor: proveedor,
          whatsappProveedor: whatsapp,
          observaciones: obs,
          precio: precio ? Number(precio) : null,
          estado: fecha ? obtenerEstado(fecha) : "libre",
          fechaVenta: null,
          precioVenta: null,
          whatsappCliente: ""
        });
      }
      
      await guardarPerfiles();
      localStorage.setItem("streamflow_perfiles_backup", JSON.stringify(perfiles));
      actualizarTodo();
      toast("✅ " + plataforma + " guardada (" + cantidad + " perfiles)");
      
      document.getElementById("cuentaIdCompleta").value = "";
      document.getElementById("mailCompleta").value = "";
      document.getElementById("passCompleta").value = "";
      document.getElementById("proveedorCompleta").value = "";
      document.getElementById("fechaCompleta").value = "";
      document.getElementById("precioCompleta").value = "";
      document.getElementById("whatsappCompleta").value = "";
      document.getElementById("obsCompleta").value = "";
      document.getElementById("otraPlatCompleta").value = "";
      document.getElementById("otraPlatCompletaDiv").style.display = "none";
    }
    
    // ============ RENDERIZADO ============
    function actualizarDashboard() {
      document.getElementById("totalPerfiles").innerHTML = perfiles.length;
      document.getElementById("libresHoy").innerHTML = perfiles.filter(p => p.estado === "libre").length;
      document.getElementById("vencenHoy").innerHTML = perfiles.filter(p => p.estado === "proximo").length;
      document.getElementById("ventasHoy").innerHTML = perfiles.filter(p => p.fechaVenta && p.fechaVenta.split('T')[0] === new Date().toISOString().split('T')[0]).length;
      document.getElementById("totalGanado").innerHTML = "$" + perfiles.reduce((s,p) => s + (p.precioVenta || 0), 0).toLocaleString();
      document.getElementById("cantidadVendidos").innerHTML = perfiles.filter(p => p.fechaVenta).length;
      
      const porPlataforma = {};
      perfiles.forEach(p => { porPlataforma[p.plataforma] = (porPlataforma[p.plataforma] || 0) + 1; });
      document.getElementById("resumenRapido").innerHTML = Object.entries(porPlataforma).map(([k,v]) => `<span class="badge">${k}: ${v}</span>`).join('');
      
      const ventasPlataforma = {};
      perfiles.filter(p => p.fechaVenta).forEach(p => { ventasPlataforma[p.plataforma] = (ventasPlataforma[p.plataforma] || 0) + 1; });
      const top = Object.entries(ventasPlataforma).sort((a,b) => b[1] - a[1])[0];
      document.getElementById("menosVendido").innerHTML = top ? `🔥 Más vendido: ${top[0]} (${top[1]} ventas)` : "📊 Sin ventas aún";
      
      const libresPlata = {};
      perfiles.filter(p => p.estado === "libre").forEach(p => { libresPlata[p.plataforma] = (libresPlata[p.plataforma] || 0) + 1; });
      const disponibles = Object.keys(libresPlata);
      let combosHtml = "";
      if(disponibles.length >= 2) {
        combosHtml += `<div class="combo-card">⚡ Combo ${disponibles.slice(0,2).join(" + ")} - Precio especial</div>`;
      }
      combosHtml += `<div class="combo-card">🎯 Combo del día: Netflix + Disney + HBO Max</div>`;
      document.getElementById("combosContainer").innerHTML = combosHtml;
    }
    
    function renderResumenes() {
      const streaming = {};
      const proveedores = {};
      perfiles.forEach(p => {
        const plataforma = p.plataforma || "Otros";
        if(!streaming[plataforma]) streaming[plataforma] = { total:0, activo:0, proximo:0, vencido:0, libre:0, vendido:0 };
        streaming[plataforma].total++;
        streaming[plataforma][p.estado]++;
        const proveedor = p.proveedor || "Sin proveedor";
        if(!proveedores[proveedor]) proveedores[proveedor] = { total:0, activo:0, proximo:0, vencido:0, libre:0, vendido:0 };
        proveedores[proveedor].total++;
        proveedores[proveedor][p.estado]++;
      });
      document.getElementById("resumenStreaming").innerHTML = Object.keys(streaming).sort().map(k => `<div style="font-size:0.7rem; margin-bottom:0.4rem;"><strong>${k}</strong> · ${streaming[k].total} total · ✅${streaming[k].activo||0} ⚠️${streaming[k].proximo||0} ❌${streaming[k].vencido||0} 🆓${streaming[k].libre||0} 💰${streaming[k].vendido||0}</div>`).join('');
      document.getElementById("resumenProveedores").innerHTML = Object.keys(proveedores).sort().map(k => `<div style="font-size:0.7rem; margin-bottom:0.4rem;"><strong>${k}</strong> · ${proveedores[k].total} total · ✅${proveedores[k].activo||0} ⚠️${proveedores[k].proximo||0} ❌${proveedores[k].vencido||0} 🆓${proveedores[k].libre||0} 💰${proveedores[k].vendido||0}</div>`).join('');
    }
    
    function renderListaPerfiles() {
      let filtroPlat = document.getElementById("filtroPlataforma").value;
      const filtroEst = document.getElementById("filtroEstado").value;
      const busqueda = document.getElementById("buscarTexto").value.toLowerCase().trim();
      const proveedorFiltro = document.getElementById("filtroProveedor").value.toLowerCase().trim();
      const fechaDesde = document.getElementById("fechaDesde").value;
      const fechaHasta = document.getElementById("fechaHasta").value;
      const otraPlat = document.getElementById("otraPlatFiltro")?.value.toLowerCase().trim();
      
      // Si seleccionó "Otros", mostrar el input para escribir la plataforma personalizada
      if(filtroPlat === "Otros") {
        document.getElementById("otraPlatFiltroDiv").style.display = "block";
        filtroPlat = otraPlat || "";
      } else {
        document.getElementById("otraPlatFiltroDiv").style.display = "none";
      }
      
      let datos = perfiles.filter(p => {
        if(filtroPlat && p.plataforma !== filtroPlat && (filtroPlat !== "Otros" || (filtroPlat === "Otros" && !p.plataforma.match(/^(Netflix|Netflix indiv|Disney|HBO Max|Prime video|Spoty|YouTube|Crunchyroll|Paramount)$/)))) return false;
        if(filtroEst && p.estado !== filtroEst) return false;
        if(proveedorFiltro && !p.proveedor?.toLowerCase().includes(proveedorFiltro)) return false;
        if(fechaDesde && p.fechaVencimiento && p.fechaVencimiento < fechaDesde) return false;
        if(fechaHasta && p.fechaVencimiento && p.fechaVencimiento > fechaHasta) return false;
        if(busqueda) {
          const campos = [p.perfilNombre, p.cuentaId, p.mail, p.proveedor, p.whatsappCliente, p.whatsappProveedor, p.plataforma];
          return campos.some(campo => campo && campo.toLowerCase().includes(busqueda));
        }
        return true;
      });
      
      const activos = datos.filter(p => p.estado !== "libre" && p.estado !== "vendido");
      const libres = datos.filter(p => p.estado === "libre");
      const vendidos = datos.filter(p => p.estado === "vendido");
      const todosActivos = [...activos, ...vendidos];
      
      const contAct = document.getElementById("listaActivos");
      const contLib = document.getElementById("listaLibres");
      if(!contAct || !contLib) return;
      
      if(todosActivos.length === 0) {
        contAct.innerHTML = '<div class="empty-state">No hay perfiles activos o vendidos</div>';
      } else {
        contAct.innerHTML = todosActivos.map(p => crearTarjetaPerfil(p, false)).join('');
      }
      
      if(libres.length === 0) {
        contLib.innerHTML = '<div class="empty-state">No hay perfiles libres</div>';
      } else {
        contLib.innerHTML = libres.map(p => crearTarjetaPerfil(p, true)).join('');
      }
      
      agregarEventosBotones();
    }
    
    function crearTarjetaPerfil(p, esLibre) {
      const passOculto = '•'.repeat(Math.min(10, (p.password || "").length));
      let botones = `
        <button class="action-btn" data-act="wa" data-id="${p.id}"><i class="fab fa-whatsapp"></i> WA Prov</button>
        <button class="action-btn" data-act="copy" data-id="${p.id}"><i class="fas fa-copy"></i> Copiar</button>
        <button class="action-btn" data-act="pass" data-id="${p.id}"><i class="fas fa-key"></i> Pass</button>
        <button class="action-btn" data-act="edit" data-id="${p.id}"><i class="fas fa-edit"></i> Editar</button>
        <button class="action-btn" data-act="renew" data-id="${p.id}"><i class="fas fa-sync-alt"></i> Renovar</button>
        <button class="action-btn" data-act="free" data-id="${p.id}"><i class="fas fa-circle"></i> Libre</button>
        <button class="action-btn" data-act="dup" data-id="${p.id}"><i class="fas fa-copy"></i> Duplicar</button>
        <button class="action-btn btn-danger" data-act="del" data-id="${p.id}"><i class="fas fa-trash"></i> Eliminar</button>
      `;
      
      if(esLibre) {
        botones += `<button class="action-btn btn-primary" data-act="sell" data-id="${p.id}"><i class="fas fa-tag"></i> Vender</button>`;
        botones += `<button class="action-btn" data-act="reassign" data-id="${p.id}"><i class="fas fa-calendar-alt"></i> Reasignar</button>`;
      }
      
      if(p.estado === "vendido" && p.whatsappCliente) {
        botones += `<button class="action-btn whatsapp-btn" data-act="wacliente" data-id="${p.id}"><i class="fab fa-whatsapp"></i> WA Cliente</button>`;
      }
      
      let fechaTexto = p.fechaVencimiento ? formatearFecha(p.fechaVencimiento) : "Sin fecha";
      if(p.estado === "vendido" && p.fechaVenta) {
        fechaTexto = `Vendido el ${new Date(p.fechaVenta).toLocaleDateString()}`;
      }
      
      return `
        <div class="profile-card">
          <div class="profile-header">
            <span class="badge">${escapeHtml(p.plataforma)}</span>
            <span class="badge ${estadoClase(p.estado)}">${estadoTexto(p.estado)}</span>
            ${p.precioVenta ? `<span class="badge">💰 $${p.precioVenta}</span>` : ''}
          </div>
          <div class="profile-info">
            <strong>${escapeHtml(p.cuentaId || '')} - ${escapeHtml(p.perfilNombre || '')}</strong><br>
            📧 ${escapeHtml(p.mail || '')}<br>
            👤 ${escapeHtml(p.proveedor || '')}<br>
            📅 ${fechaTexto}<br>
            🔑 <span id="pass-${p.id}">${passOculto}</span>
            <button class="toggle-password" data-id="${p.id}"><i class="fas fa-eye"></i></button>
            ${p.whatsappCliente ? `<br>📱 Cliente: ${escapeHtml(p.whatsappCliente)}` : ''}
            ${p.whatsappProveedor ? `<br>📱 Tu WhatsApp: ${escapeHtml(p.whatsappProveedor)}` : ''}
          </div>
          <div class="action-buttons">${botones}</div>
        </div>
      `;
    }
    
    function agregarEventosBotones() {
      document.querySelectorAll(".toggle-password").forEach(btn => {
        btn.onclick = (e) => {
          e.stopPropagation();
          const p = perfiles.find(p => p.id === btn.dataset.id);
          if(p) {
            const span = document.getElementById(`pass-${p.id}`);
            if(span.innerText === '•••••••') {
              span.innerText = p.password;
              btn.innerHTML = '<i class="fas fa-eye-slash"></i>';
            } else {
              span.innerText = '•••••••';
              btn.innerHTML = '<i class="fas fa-eye"></i>';
            }
          }
        };
      });
      
      document.querySelectorAll(".action-btn").forEach(btn => {
        btn.onclick = () => {
          const id = btn.dataset.id;
          const act = btn.dataset.act;
          const p = perfiles.find(p => p.id === id);
          if(!p) return;
          if(act === "wa") {
            if(p.whatsappProveedor) abrirWhatsApp(p.whatsappProveedor, plantillaProveedor(p));
            else toast("Sin WhatsApp del proveedor");
          } else if(act === "wacliente") {
            if(p.whatsappCliente) abrirWhatsApp(p.whatsappCliente, plantillaCliente(p, false));
            else toast("Sin WhatsApp del cliente");
          } else if(act === "copy") {
            navigator.clipboard.writeText(plantillaProveedor(p));
            toast("Copiado");
          } else if(act === "pass") {
            cambiarPass(id);
          } else if(act === "edit") {
            editarPerfil(id);
          } else if(act === "renew") {
            renovarPerfil(id);
          } else if(act === "free") {
            marcarLibre(id);
          } else if(act === "dup") {
            duplicarPerfil(id);
          } else if(act === "del") {
            eliminarPerfil(id);
          } else if(act === "sell") {
            mostrarVentaModal(id);
          } else if(act === "reassign") {
            mostrarReasignarModal(id);
          }
        };
      });
    }
    
    function mostrarVentaModal(id) {
      const p = perfiles.find(p => p.id === id);
      if(!p) return;
      pendingVentaId = id;
      document.getElementById("ventaPerfilInfo").innerHTML = `<strong>${escapeHtml(p.plataforma)} - ${escapeHtml(p.perfilNombre)}</strong><br>Estado actual: ${estadoTexto(p.estado)}`;
      document.getElementById("ventaPlataforma").value = p.plataforma || "Netflix";
      document.getElementById("ventaCuentaId").value = p.cuentaId || "";
      document.getElementById("ventaPerfilNombre").value = p.perfilNombre || "";
      document.getElementById("ventaMail").value = p.mail || "";
      document.getElementById("ventaPassword").value = p.password || "";
      document.getElementById("ventaPin").value = p.pin || "";
      document.getElementById("ventaFechaVencimiento").value = p.fechaVencimiento || "";
      document.getElementById("ventaProveedor").value = p.proveedor || "";
      document.getElementById("ventaPrecio").value = p.precio || 2500;
      document.getElementById("ventaCliente").value = "";
      document.getElementById("ventaObservaciones").value = p.observaciones || "";
      document.getElementById("ventaModal").style.display = "flex";
    }
    
    function mostrarReasignarModal(id) {
      const p = perfiles.find(p => p.id === id);
      if(p) {
        document.getElementById("reasignarPerfilInfo").innerHTML = `${p.plataforma} - ${p.perfilNombre}`;
        document.getElementById("reasignarFecha").value = p.fechaVencimiento || "";
        document.getElementById("reasignarModal").style.display = "flex";
        window.reasignarId = id;
      }
    }
    
    async function confirmarReasignar() {
      const nuevaFecha = document.getElementById("reasignarFecha").value;
      if(!nuevaFecha) {
        toast("Seleccioná una fecha");
        return;
      }
      const p = perfiles.find(p => p.id === window.reasignarId);
      if(p) {
        p.fechaVencimiento = nuevaFecha;
        p.estado = obtenerEstado(nuevaFecha);
        await guardarPerfiles();
        actualizarTodo();
        toast("Fecha reasignada");
        document.getElementById("reasignarModal").style.display = "none";
      }
    }
    
    async function cambiarPass(id) {
      const p = perfiles.find(p => p.id === id);
      if(p) {
        const nueva = prompt("Nueva contraseña (mínimo 6 caracteres):");
        if(nueva && nueva.length >= 6) {
          const confirmar = prompt("Confirmar nueva contraseña:");
          if(confirmar === nueva) {
            p.password = nueva;
            await guardarPerfiles();
            actualizarTodo();
            toast("Contraseña actualizada");
          } else {
            toast("Las contraseñas no coinciden");
          }
        } else if(nueva) {
          toast("La contraseña debe tener al menos 6 caracteres");
        }
      }
    }
    
    function renderHistorial() {
      const fp = document.getElementById("historialFiltroPlataforma").value;
      const busqueda = document.getElementById("historialBuscar").value.toLowerCase();
      let ventas = perfiles.filter(p => p.fechaVenta);
      if(fp) ventas = ventas.filter(p => p.plataforma === fp);
      if(busqueda) ventas = ventas.filter(p => p.perfilNombre.toLowerCase().includes(busqueda) || (p.whatsappCliente && p.whatsappCliente.toLowerCase().includes(busqueda)));
      ventas.sort((a,b) => new Date(b.fechaVenta) - new Date(a.fechaVenta));
      const container = document.getElementById("historialLista");
      if(ventas.length === 0) {
        container.innerHTML = '<div class="empty-state">No hay ventas registradas</div>';
      } else {
        container.innerHTML = ventas.map(p => `
          <div class="profile-card">
            <div class="profile-header"><span class="badge">${escapeHtml(p.plataforma)}</span><span class="badge badge-success">Vendido</span></div>
            <div class="profile-info"><strong>${escapeHtml(p.perfilNombre)}</strong><br>💰 $${p.precioVenta}<br>📅 ${new Date(p.fechaVenta).toLocaleDateString()}<br>👤 Cliente: ${p.whatsappCliente || "No especificado"}</div>
            <div class="action-buttons"><button class="action-btn reenviar-wa" data-numero="${p.whatsappCliente || ''}" data-mensaje="${escapeHtml(plantillaCliente(p, true))}"><i class="fab fa-whatsapp"></i> Reenviar plantilla</button></div>
          </div>
        `).join('');
      }
      document.querySelectorAll(".reenviar-wa").forEach(btn => {
        btn.onclick = () => {
          const numero = btn.dataset.numero;
          const mensaje = btn.dataset.mensaje;
          if(numero) abrirWhatsApp(numero, mensaje);
          else toast("Sin número de cliente");
        };
      });
    }
    
    function actualizarPanelMiCuenta() {
      if(!currentUser) return;
      document.getElementById("perfilEmail").innerHTML = currentUser.email || "-";
      document.getElementById("perfilPlan").innerHTML = planEstado === "token" ? "PRO - PREMIUM" : (planEstado === "bloqueado" ? "BLOQUEADO" : "DEMO - PRUEBA");
      document.getElementById("perfilDiasRestantes").innerHTML = planEstado === "token" ? "✅ Suscripción activa" : (planEstado === "bloqueado" ? "⚠️ Período expirado - Ingresá un token" : `🎯 ${diasPruebaRestantes} días restantes`);
      document.getElementById("perfilTotalPerfiles").innerHTML = perfiles.length;
      document.getElementById("perfilTotalVentas").innerHTML = perfiles.filter(p => p.fechaVenta).length;
      document.getElementById("perfilGanado").innerHTML = "$" + perfiles.reduce((s,p) => s + (p.precioVenta || 0), 0).toLocaleString();
      document.getElementById("perfilActivos").innerHTML = perfiles.filter(p => p.estado === "activo" || p.estado === "proximo").length;
      
      const progresoBarra = document.getElementById("progresoBarra");
      const progresoTexto = document.getElementById("progresoTexto");
      const fechaExpiracionSpan = document.getElementById("fechaExpiracionTexto");
      if(planEstado === "token") {
        const totalDias = DIAS_TOKEN;
        const progreso = (diasPruebaRestantes / totalDias) * 100;
        if(progresoBarra) progresoBarra.style.width = `${progreso}%`;
        if(progresoTexto) progresoTexto.innerText = `${diasPruebaRestantes} días restantes del plan PRO`;
        if(fechaExpiracionSpan) fechaExpiracionSpan.innerText = `+${diasPruebaRestantes} días`;
      } else if(planEstado === "demo") {
        const totalDias = DIAS_PRUEBA_GRATIS;
        const progreso = (diasPruebaRestantes / totalDias) * 100;
        if(progresoBarra) progresoBarra.style.width = `${progreso}%`;
        if(progresoTexto) progresoTexto.innerText = `${diasPruebaRestantes} días restantes de prueba`;
        if(fechaExpiracionSpan) fechaExpiracionSpan.innerText = `+${diasPruebaRestantes} días`;
      } else {
        if(progresoBarra) progresoBarra.style.width = "0%";
        if(progresoTexto) progresoTexto.innerText = "Cuenta bloqueada";
        if(fechaExpiracionSpan) fechaExpiracionSpan.innerText = "Expirado";
      }
    }
    
    function actualizarTodo() {
      actualizarDashboard();
      renderListaPerfiles();
      renderResumenes();
      renderHistorial();
      actualizarPanelMiCuenta();
      const emailEl = document.getElementById("emailEnPerfiles");
      if(emailEl) emailEl.innerText = currentUser ? currentUser.email : "No logueado";
    }
    
    function actualizarConDebounce() {
      if(filtroTimeout) clearTimeout(filtroTimeout);
      filtroTimeout = setTimeout(() => {
        renderListaPerfiles();
      }, 300);
    }
    
    function cambiarTab(tabId) {
      document.querySelectorAll(".tab-panel").forEach(p => p.classList.remove("active"));
      const tp = document.getElementById(`tab-${tabId}`);
      if(tp) tp.classList.add("active");
      document.querySelectorAll(".nav-btn").forEach(b => b.classList.remove("active"));
      const navBtn = document.querySelector(`.nav-btn[data-nav="${tabId}"]`);
      if(navBtn) navBtn.classList.add("active");
      if(tabId === "micuenta") actualizarPanelMiCuenta();
      if(tabId === "perfiles") renderListaPerfiles();
      if(tabId === "dashboard") actualizarDashboard();
      if(tabId === "historial") renderHistorial();
      if(tabId === "stats") { actualizarDashboard(); renderResumenes(); }
    }
    
    function limpiarFiltros() {
      document.getElementById("filtroPlataforma").value = "";
      document.getElementById("filtroEstado").value = "";
      document.getElementById("buscarTexto").value = "";
      document.getElementById("filtroProveedor").value = "";
      document.getElementById("fechaDesde").value = "";
      document.getElementById("fechaHasta").value = "";
      document.getElementById("otraPlatFiltro").value = "";
      document.getElementById("otraPlatFiltroDiv").style.display = "none";
      renderListaPerfiles();
      toast("Filtros limpiados");
    }
    
    function ordenarPerfiles() {
      perfiles.sort((a,b) => {
        if(!a.fechaVencimiento && !b.fechaVencimiento) return 0;
        if(!a.fechaVencimiento) return 1;
        if(!b.fechaVencimiento) return -1;
        const fa = parseFecha(a.fechaVencimiento);
        const fb = parseFecha(b.fechaVencimiento);
        if(!fa || !fb) return 0;
        return ordenAsc ? fa - fb : fb - fa;
      });
      ordenAsc = !ordenAsc;
      guardarPerfiles();
      actualizarTodo();
      toast(ordenAsc ? "Orden ascendente" : "Orden descendente");
    }
    
    async function resetearVentas() {
      if(confirm("¿Reiniciar todas las ventas? Los perfiles volverán a estado libre.")) {
        perfiles.forEach(p => {
          p.fechaVenta = null;
          p.precioVenta = null;
          p.whatsappCliente = "";
          if(p.estado === "vendido") p.estado = "libre";
        });
        await guardarPerfiles();
        actualizarTodo();
        toast("Ventas reiniciadas");
      }
    }
    
    function exportarDatos() {
      if(perfiles.length === 0) {
        toast("Sin datos para exportar");
        return;
      }
      const data = JSON.stringify(perfiles);
      const blob = new Blob([data], { type: "application/json" });
      const a = document.createElement("a");
      a.href = URL.createObjectURL(blob);
      a.download = `streamflow_backup_${new Date().toISOString().split('T')[0]}.json`;
      a.click();
      toast("Backup exportado");
    }
    
    function importarDatos() {
      document.getElementById("archivoImportar").click();
    }
    
    async function borrarTodosLosPerfiles() {
      if(confirm("⚠️ ¿BORRAR TODOS LOS PERFILES? Esta acción no se puede deshacer.")) {
        const confirmar = prompt("Escribí CONFIRMAR para borrar todo");
        if(confirmar === "CONFIRMAR") {
          perfiles = [];
          await guardarPerfiles();
          localStorage.setItem("streamflow_perfiles_backup", JSON.stringify(perfiles));
          actualizarTodo();
          toast("Todos los datos eliminados");
        }
      }
    }
    
    function previsualizarCargaMasiva() {
      const texto = document.getElementById("batchTexto").value;
      if(!texto.trim()) {
        toast("No hay datos para previsualizar");
        return;
      }
      const lineas = texto.split(/\r?\n/);
      let cuentaActual = {};
      const cuentas = [];
      for(const linea of lineas) {
        const lineaTrim = linea.trim();
        if(lineaTrim === "" || lineaTrim === "---") {
          if(Object.keys(cuentaActual).length > 0) {
            cuentas.push(cuentaActual);
            cuentaActual = {};
          }
          continue;
        }
        const partes = lineaTrim.split(/[=:]/);
        if(partes.length >= 2) {
          const clave = partes[0].trim().toLowerCase();
          const valor = partes.slice(1).join(":").trim();
          if(clave.includes("mail") || clave.includes("email") || clave.includes("correo")) cuentaActual.mail = valor;
          else if(clave.includes("contraseña") || clave.includes("password") || clave.includes("pass")) cuentaActual.password = valor;
          else if(clave.includes("perfil") || clave.includes("usuario")) cuentaActual.perfilNombre = valor;
          else if(clave.includes("proveedor") || clave.includes("vendedor")) cuentaActual.proveedor = valor;
          else if(clave.includes("vencimiento") || clave.includes("fecha")) cuentaActual.fechaVencimiento = valor;
          else if(clave.includes("whatsapp") || clave.includes("wa")) cuentaActual.whatsapp = valor;
        }
      }
      if(Object.keys(cuentaActual).length > 0) cuentas.push(cuentaActual);
      const resultadosDiv = document.getElementById("batchResultados");
      resultadosDiv.style.display = "block";
      resultadosDiv.innerHTML = `<strong>📋 Previsualización (${cuentas.length} cuentas encontradas)</strong><br>${cuentas.map((c, i) => `${i+1}. ${c.perfilNombre || "Sin nombre"} - ${c.mail || "Sin email"} - ${c.proveedor || "Sin proveedor"}`).join('<br>')}<br><small>✅ Verifica que los datos sean correctos antes de cargar.</small>`;
    }
    
    async function cargarMasiva() {
      const texto = document.getElementById("batchTexto").value;
      if(!texto.trim()) {
        toast("No hay datos para cargar");
        return;
      }
      const lineas = texto.split(/\r?\n/);
      let cuentaActual = {};
      let agregadas = 0;
      for(const linea of lineas) {
        const lineaTrim = linea.trim();
        if(lineaTrim === "" || lineaTrim === "---") {
          if(Object.keys(cuentaActual).length > 0 && cuentaActual.mail && cuentaActual.password && cuentaActual.perfilNombre && cuentaActual.proveedor) {
            perfiles.push({
              id: generarIdUnico(),
              plataforma: "Carga masiva",
              cuentaId: "MASIVA_" + Date.now(),
              perfilNombre: cuentaActual.perfilNombre,
              mail: cuentaActual.mail,
              password: cuentaActual.password,
              pin: "",
              fechaVencimiento: cuentaActual.fechaVencimiento || null,
              proveedor: cuentaActual.proveedor,
              whatsappProveedor: cuentaActual.whatsapp || "",
              observaciones: "",
              precio: null,
              estado: cuentaActual.fechaVencimiento ? obtenerEstado(cuentaActual.fechaVencimiento) : "libre",
              fechaVenta: null,
              precioVenta: null,
              whatsappCliente: ""
            });
            agregadas++;
          }
          cuentaActual = {};
          continue;
        }
        const partes = lineaTrim.split(/[=:]/);
        if(partes.length >= 2) {
          const clave = partes[0].trim().toLowerCase();
          const valor = partes.slice(1).join(":").trim();
          if(clave.includes("mail") || clave.includes("email") || clave.includes("correo")) cuentaActual.mail = valor;
          else if(clave.includes("contraseña") || clave.includes("password") || clave.includes("pass")) cuentaActual.password = valor;
          else if(clave.includes("perfil") || clave.includes("usuario")) cuentaActual.perfilNombre = valor;
          else if(clave.includes("proveedor") || clave.includes("vendedor")) cuentaActual.proveedor = valor;
          else if(clave.includes("vencimiento") || clave.includes("fecha")) cuentaActual.fechaVencimiento = valor;
          else if(clave.includes("whatsapp") || clave.includes("wa")) cuentaActual.whatsapp = valor;
        }
      }
      if(Object.keys(cuentaActual).length > 0 && cuentaActual.mail && cuentaActual.password && cuentaActual.perfilNombre && cuentaActual.proveedor) {
        perfiles.push({
          id: generarIdUnico(),
          plataforma: "Carga masiva",
          cuentaId: "MASIVA_" + Date.now(),
          perfilNombre: cuentaActual.perfilNombre,
          mail: cuentaActual.mail,
          password: cuentaActual.password,
          pin: "",
          fechaVencimiento: cuentaActual.fechaVencimiento || null,
          proveedor: cuentaActual.proveedor,
          whatsappProveedor: cuentaActual.whatsapp || "",
          observaciones: "",
          precio: null,
          estado: cuentaActual.fechaVencimiento ? obtenerEstado(cuentaActual.fechaVencimiento) : "libre",
          fechaVenta: null,
          precioVenta: null,
          whatsappCliente: ""
        });
        agregadas++;
      }
      if(agregadas > 0) {
        await guardarPerfiles();
        actualizarTodo();
        toast(`✅ ${agregadas} perfiles cargados correctamente`);
        document.getElementById("batchTexto").value = "";
        document.getElementById("batchResultados").style.display = "none";
      } else {
        toast("No se encontraron perfiles válidos para cargar");
      }
    }
    
    // ============ CONFIGURACIÓN LOCAL ============
    function guardarConfigLocal() {
      localStorage.setItem("streamflow_config", JSON.stringify({
        tema: document.body.classList.contains("light") ? "light" : "dark",
        kiosco: kioscoMode,
        notifications: notificationsEnabled,
        diasProximo: DIAS_PROXIMO
      }));
    }
    
    function cargarConfigLocal() {
      const saved = localStorage.getItem("streamflow_config");
      if(saved) {
        try {
          const cfg = JSON.parse(saved);
          if(cfg.tema === "light") document.body.classList.add("light");
          document.getElementById("themeToggle").checked = cfg.tema === "light";
          kioscoMode = cfg.kiosco || false;
          document.getElementById("kioscoToggle").checked = kioscoMode;
          notificationsEnabled = cfg.notifications !== false;
          document.getElementById("notificationsToggle").checked = notificationsEnabled;
          DIAS_PROXIMO = cfg.diasProximo || 3;
          document.getElementById("diasProximoConfig").value = DIAS_PROXIMO;
        } catch(e) {}
      }
    }
    
    // ============ NOTIFICACIONES DE VENCIMIENTO ============
    function mostrarAvisoVencimientos() {
      if(!notificationsEnabled) return;
      const hoy = new Date();
      hoy.setHours(0,0,0,0);
      const vencidos = [];
      const proximos = [];
      perfiles.forEach(p => {
        if(!p.fechaVencimiento || p.estado === "libre" || p.estado === "vendido" || !p.whatsappCliente) return;
        const f = parseFecha(p.fechaVencimiento);
        if(!f) return;
        f.setHours(0,0,0,0);
        const diff = Math.round((f - hoy) / 86400000);
        if(diff < 0) {
          vencidos.push(p);
        } else if(diff <= DIAS_PROXIMO) {
          proximos.push(p);
        }
      });
      if(vencidos.length > 0 || proximos.length > 0) {
        let html = "<strong>📢 RECORDATORIO DE VENCIMIENTOS</strong><br><br>";
        if(vencidos.length > 0) {
          html += '<span style="color:#ef4444;">🔴 VENCIDOS:</span><br>';
          vencidos.forEach(p => html += `❌ ${p.plataforma} - ${p.perfilNombre}<br>`);
        }
        if(proximos.length > 0) {
          html += '<br><span style="color:#f5af19;">🟡 PRÓXIMOS A VENCER:</span><br>';
          proximos.forEach(p => {
            html += `⚠️ ${p.plataforma} - ${p.perfilNombre} (${formatearFecha(p.fechaVencimiento)})`;
            if(p.whatsappCliente) {
              html += ` <button onclick="avisarClienteVencimiento('${p.id}')" style="background:#25D366; color:#fff; border:none; border-radius:1rem; padding:0.2rem 0.6rem; font-size:0.65rem; cursor:pointer;"><i class="fab fa-whatsapp"></i> Avisar</button>`;
            }
            html += "<br>";
          });
        }
        document.getElementById("vencimientoModalMensaje").innerHTML = html;
        document.getElementById("vencimientoModal").style.display = "flex";
      }
    }
    
    window.avisarClienteVencimiento = function(perfilId) {
      const p = perfiles.find(p => p.id === perfilId);
      if(p && p.whatsappCliente) {
        const fechaVence = p.fechaVencimiento ? formatearFecha(p.fechaVencimiento) : "próximamente";
        const mensaje = `🔔 *AVISO DE VENCIMIENTO* 🔔\n\nHola,\n\nTu cuenta de *${p.plataforma}* (Perfil: ${p.perfilNombre}) está próxima a vencer.\n\n📅 *Vence el:* ${fechaVence}\n\nPor favor, contactanos para renovarla y seguir disfrutando del servicio sin interrupciones.\n\n¡Gracias por confiar en nosotros! 🙏`;
        abrirWhatsApp(p.whatsappCliente, mensaje);
      } else {
        toast("No hay WhatsApp del cliente registrado");
      }
    };
    
    // ============ EVENT LISTENERS ============
    document.getElementById("platCompleta")?.addEventListener("change", function() {
      document.getElementById("otraPlatCompletaDiv").style.display = this.value === "Otros" ? "block" : "none";
    });
    
    document.getElementById("platIndividual")?.addEventListener("change", function() {
      document.getElementById("otraPlatIndividualDiv").style.display = this.value === "Otros" ? "block" : "none";
    });
    
    document.getElementById("filtroPlataforma")?.addEventListener("change", function() {
      if(this.value === "Otros") {
        document.getElementById("otraPlatFiltroDiv").style.display = "block";
      } else {
        document.getElementById("otraPlatFiltroDiv").style.display = "none";
        renderListaPerfiles();
      }
    });
    
    document.getElementById("otraPlatFiltro")?.addEventListener("input", renderListaPerfiles);
    
    document.getElementById("showRegister")?.addEventListener("click", () => {
      document.getElementById("loginPanel").style.display = "none";
      document.getElementById("registerPanel").style.display = "block";
    });
    
    document.getElementById("showLogin")?.addEventListener("click", () => {
      document.getElementById("registerPanel").style.display = "none";
      document.getElementById("loginPanel").style.display = "block";
    });
    
    document.getElementById("forgotPasswordBtn")?.addEventListener("click", () => {
      document.getElementById("resetPasswordModal").style.display = "flex";
    });
    
    document.getElementById("modalCancelBtn")?.addEventListener("click", () => {
      document.getElementById("resetPasswordModal").style.display = "none";
    });
    
    document.getElementById("modalSendBtn")?.addEventListener("click", async () => {
      const email = document.getElementById("resetEmail").value;
      if(!email) {
        toast("Ingresá un email");
        return;
      }
      try {
        await auth.sendPasswordResetEmail(email);
        toast("✅ Correo enviado");
        document.getElementById("resetPasswordModal").style.display = "none";
      } catch(e) {
        toast("❌ Error: " + e.message);
      }
    });
    
    document.getElementById("btnLoginSubmit")?.addEventListener("click", async () => {
      const email = document.getElementById("loginEmail").value;
      const pass = document.getElementById("loginPassword").value;
      if(!email || !pass) {
        document.getElementById("authError").innerText = "Completá todos los campos";
        return;
      }
      const btn = document.getElementById("btnLoginSubmit");
      btn.disabled = true;
      btn.innerHTML = '<span class="spinner"></span> Entrando...';
      try {
        await auth.signInWithEmailAndPassword(email, pass);
        if(document.getElementById("rememberMeCheckbox").checked) {
          localStorage.setItem("recordarEmail", email);
        }
        toast("✅ Bienvenido");
      } catch(e) {
        document.getElementById("authError").innerText = e.message;
      } finally {
        btn.disabled = false;
        btn.innerHTML = "Iniciar sesión";
      }
    });
    
    document.getElementById("btnRegisterSubmit")?.addEventListener("click", async () => {
      const email = document.getElementById("regEmail").value;
      const pass = document.getElementById("regPassword").value;
      const confirm = document.getElementById("regPasswordConfirm").value;
      if(pass !== confirm) {
        document.getElementById("authError").innerText = "Las contraseñas no coinciden";
        return;
      }
      if(pass.length < 6) {
        document.getElementById("authError").innerText = "La contraseña debe tener al menos 6 caracteres";
        return;
      }
      const btn = document.getElementById("btnRegisterSubmit");
      btn.disabled = true;
      btn.innerHTML = '<span class="spinner"></span> Registrando...';
      try {
        await auth.createUserWithEmailAndPassword(email, pass);
        toast("✅ Registro exitoso");
      } catch(e) {
        document.getElementById("authError").innerText = e.message;
      } finally {
        btn.disabled = false;
        btn.innerHTML = "Registrarse";
      }
    });
    
    document.getElementById("logoutBtn")?.addEventListener("click", async () => {
      await auth.signOut();
      toast("Sesión cerrada");
    });
    
    document.getElementById("btnGuardarCompleta")?.addEventListener("click", guardarCuentaCompleta);
    
    document.getElementById("btnGuardarIndividual")?.addEventListener("click", () => {
      if(editandoId) {
        guardarPerfilEditado();
      } else {
        guardarPerfilIndividual();
      }
    });
    
    document.getElementById("btnCancelarEdicion")?.addEventListener("click", () => {
      editandoId = null;
      limpiarFormularioIndividual();
      document.getElementById("btnCancelarEdicion").style.display = "none";
      document.getElementById("btnGuardarIndividual").textContent = "Guardar perfil";
      toast("Edición cancelada");
    });
    
    document.getElementById("btnExportar")?.addEventListener("click", exportarDatos);
    document.getElementById("btnImportar")?.addEventListener("click", importarDatos);
    document.getElementById("btnBorrarTodo")?.addEventListener("click", borrarTodosLosPerfiles);
    document.getElementById("btnOrdenar")?.addEventListener("click", ordenarPerfiles);
    document.getElementById("btnLimpiarFiltros")?.addEventListener("click", limpiarFiltros);
    document.getElementById("btnResetVentas")?.addEventListener("click", resetearVentas);
    document.getElementById("btnPrevisualizar")?.addEventListener("click", previsualizarCargaMasiva);
    document.getElementById("btnCargarMasivo")?.addEventListener("click", cargarMasiva);
    
    document.getElementById("btnValidarToken")?.addEventListener("click", async () => {
      const token = document.getElementById("tokenAcceso").value;
      if(!token) {
        toast("Ingresá un token");
        return;
      }
      if(!currentUser) {
        toast("Iniciá sesión primero");
        return;
      }
      showLoader("Validando token...");
      const resultado = await validarToken(token, currentUser.uid);
      hideLoader();
      toast(resultado.mensaje);
      if(resultado.valido) {
        document.getElementById("tokenAcceso").value = "";
        document.getElementById("tokenEstado").innerHTML = `<span style="color:#10b981;">✅ ${resultado.mensaje}</span>`;
        actualizarPanelMiCuenta();
        aplicarBloqueoApp();
      } else {
        document.getElementById("tokenEstado").innerHTML = `<span style="color:#ef4444;">❌ ${resultado.mensaje}</span>`;
      }
    });
    
    document.getElementById("btnWhatsAppToken")?.addEventListener("click", () => {
      abrirWhatsApp(WHATSAPP_TOKEN_NUMBER, "Hola, quiero comprar un token para StreamFlow Pro. ¿Me ayudas?");
    });
    
    document.getElementById("btnCerrarSesion")?.addEventListener("click", async () => {
      await auth.signOut();
    });
    document.getElementById("btnAbrirManual")?.addEventListener("click", () => cambiarTab("ayuda"));
    document.getElementById("btnVolverDeAyuda")?.addEventListener("click", () => cambiarTab("ajustes"));
    document.getElementById("btnAcercaDe")?.addEventListener("click", () => {
      document.getElementById("acercaModal").style.display = "flex";
    });
    document.getElementById("acercaCerrar")?.addEventListener("click", () => {
      document.getElementById("acercaModal").style.display = "none";
    });
    
    document.getElementById("ventaConfirmar")?.addEventListener("click", async () => {
      if(pendingVentaId) {
        await venderPerfil(pendingVentaId, {
          plataforma: document.getElementById("ventaPlataforma").value,
          cuentaId: document.getElementById("ventaCuentaId").value,
          perfilNombre: document.getElementById("ventaPerfilNombre").value,
          mail: document.getElementById("ventaMail").value,
          password: document.getElementById("ventaPassword").value,
          pin: document.getElementById("ventaPin").value,
          fechaVencimiento: document.getElementById("ventaFechaVencimiento").value,
          proveedor: document.getElementById("ventaProveedor").value,
          precio: document.getElementById("ventaPrecio").value,
          cliente: document.getElementById("ventaCliente").value,
          observaciones: document.getElementById("ventaObservaciones").value
        });
        document.getElementById("ventaModal").style.display = "none";
        pendingVentaId = null;
      }
    });
    
    document.getElementById("ventaCancelar")?.addEventListener("click", () => {
      document.getElementById("ventaModal").style.display = "none";
      pendingVentaId = null;
    });
    
    document.getElementById("reasignarConfirmar")?.addEventListener("click", confirmarReasignar);
    document.getElementById("reasignarCancelar")?.addEventListener("click", () => {
      document.getElementById("reasignarModal").style.display = "none";
    });
    
    document.getElementById("themeToggle")?.addEventListener("change", (e) => {
      if(e.target.checked) document.body.classList.add("light");
      else document.body.classList.remove("light");
      guardarConfigLocal();
    });
    
    document.getElementById("kioscoToggle")?.addEventListener("change", (e) => {
      kioscoMode = e.target.checked;
      guardarConfigLocal();
      actualizarTodo();
      if(kioscoMode) toast("Modo kiosco activado - edición deshabilitada");
      else toast("Modo kiosco desactivado");
    });
    
    document.getElementById("notificationsToggle")?.addEventListener("change", (e) => {
      notificationsEnabled = e.target.checked;
      guardarConfigLocal();
      if(notificationsEnabled) mostrarAvisoVencimientos();
    });
    
    document.getElementById("diasProximoConfig")?.addEventListener("change", (e) => {
      DIAS_PROXIMO = parseInt(e.target.value) || 3;
      guardarConfigLocal();
      actualizarTodo();
    });
    
    document.getElementById("btnExportConfig")?.addEventListener("click", () => {
      const config = {
        tema: document.body.classList.contains("light") ? "light" : "dark",
        kiosco: kioscoMode,
        notifications: notificationsEnabled,
        diasProximo: DIAS_PROXIMO
      };
      const blob = new Blob([JSON.stringify(config)], { type: "application/json" });
      const a = document.createElement("a");
      a.download = "streamflow_config.json";
      a.href = URL.createObjectURL(blob);
      a.click();
      toast("Configuración exportada");
    });
    
    document.getElementById("btnImportConfig")?.addEventListener("click", () => {
      document.getElementById("archivoConfig").click();
    });
    
    document.getElementById("archivoConfig")?.addEventListener("change", (e) => {
      const file = e.target.files[0];
      if(!file) return;
      const reader = new FileReader();
      reader.onload = (ev) => {
        try {
          const cfg = JSON.parse(ev.target.result);
          if(cfg.tema === "light") document.body.classList.add("light");
          else document.body.classList.remove("light");
          document.getElementById("themeToggle").checked = cfg.tema === "light";
          kioscoMode = cfg.kiosco || false;
          document.getElementById("kioscoToggle").checked = kioscoMode;
          notificationsEnabled = cfg.notifications !== false;
          document.getElementById("notificationsToggle").checked = notificationsEnabled;
          DIAS_PROXIMO = cfg.diasProximo || 3;
          document.getElementById("diasProximoConfig").value = DIAS_PROXIMO;
          guardarConfigLocal();
          toast("Configuración importada");
        } catch(err) { toast("Archivo inválido"); }
      };
      reader.readAsText(file);
      e.target.value = "";
    });
    
    document.getElementById("btnResetConfig")?.addEventListener("click", () => {
      DIAS_PROXIMO = 3;
      kioscoMode = false;
      notificationsEnabled = true;
      document.body.classList.remove("light");
      document.getElementById("themeToggle").checked = false;
      document.getElementById("kioscoToggle").checked = false;
      document.getElementById("notificationsToggle").checked = true;
      document.getElementById("diasProximoConfig").value = 3;
      guardarConfigLocal();
      actualizarTodo();
      toast("Configuración restablecida");
    });
    
    document.getElementById("archivoImportar")?.addEventListener("change", async (e) => {
      const file = e.target.files[0];
      if(!file) return;
      const reader = new FileReader();
      reader.onload = async (ev) => {
        try {
          const data = JSON.parse(ev.target.result);
          if(Array.isArray(data) && confirm("¿Reemplazar todos los datos actuales?")) {
            perfiles = data;
            await guardarPerfiles();
            localStorage.setItem("streamflow_perfiles_backup", JSON.stringify(perfiles));
            actualizarTodo();
            toast("Datos importados");
          } else {
            toast("Archivo inválido");
          }
        } catch(err) { toast("Error al leer archivo"); }
      };
      reader.readAsText(file);
      e.target.value = "";
    });
    
    document.getElementById("vencimientoModalCerrar")?.addEventListener("click", () => {
      document.getElementById("vencimientoModal").style.display = "none";
    });
    
    document.getElementById("syncStatus")?.addEventListener("click", async () => {
      if(currentUser) {
        await guardarPerfiles();
        toast("Sincronización manual completada");
      } else {
        toast("No hay usuario logueado");
      }
    });
    
    document.getElementById("filtroPlataforma")?.addEventListener("change", actualizarConDebounce);
    document.getElementById("filtroEstado")?.addEventListener("change", actualizarConDebounce);
    document.getElementById("buscarTexto")?.addEventListener("input", actualizarConDebounce);
    document.getElementById("filtroProveedor")?.addEventListener("input", actualizarConDebounce);
    document.getElementById("fechaDesde")?.addEventListener("change", actualizarConDebounce);
    document.getElementById("fechaHasta")?.addEventListener("change", actualizarConDebounce);
    document.getElementById("historialFiltroPlataforma")?.addEventListener("change", renderHistorial);
    document.getElementById("historialBuscar")?.addEventListener("input", () => setTimeout(renderHistorial, 300));
    
    document.querySelectorAll(".nav-btn").forEach(btn => {
      btn.addEventListener("click", () => cambiarTab(btn.dataset.nav));
    });
    
    document.querySelectorAll(".carga-tab").forEach(btn => {
      btn.addEventListener("click", () => {
        document.querySelectorAll(".carga-tab").forEach(b => b.classList.remove("active"));
        btn.classList.add("active");
        const mod = btn.dataset.mod;
        document.getElementById("modo-completa").style.display = mod === "completa" ? "block" : "none";
        document.getElementById("modo-individual").style.display = mod === "individual" ? "block" : "none";
        document.getElementById("modo-masiva").style.display = mod === "masiva" ? "block" : "none";
        editandoId = null;
        document.getElementById("btnCancelarEdicion").style.display = "none";
        document.getElementById("btnGuardarIndividual").textContent = "Guardar perfil";
      });
    });
    
    document.querySelectorAll("#manualQuickNav .quick-link").forEach(link => {
      link.addEventListener("click", () => {
        const section = link.dataset.section;
        const target = document.getElementById(`manual-${section}`);
        if(target) {
          target.scrollIntoView({ behavior: "smooth" });
          target.querySelector(".manual-section-body")?.classList.add("open");
        }
      });
    });
    
    document.querySelectorAll(".manual-section-header").forEach(header => {
      header.addEventListener("click", () => {
        const body = header.nextElementSibling;
        const icon = header.querySelector("i");
        body.classList.toggle("open");
        if(body.classList.contains("open")) {
          icon.classList.remove("fa-chevron-right");
          icon.classList.add("fa-chevron-down");
        } else {
          icon.classList.remove("fa-chevron-down");
          icon.classList.add("fa-chevron-right");
        }
      });
    });
    
    document.getElementById("manualSearch")?.addEventListener("input", function() {
      const query = this.value.toLowerCase().trim();
      const secciones = document.querySelectorAll(".manual-section");
      let found = 0;
      secciones.forEach(seccion => {
        if(!query || seccion.textContent.toLowerCase().includes(query)) {
          seccion.style.display = "block";
          found++;
        } else {
          seccion.style.display = "none";
        }
      });
      const resultsDiv = document.getElementById("manualSearchResults");
      if(query) {
        resultsDiv.style.display = "block";
        resultsDiv.innerHTML = `🔍 ${found} resultado(s) para "<strong>${escapeHtml(query)}</strong>"`;
      } else {
        resultsDiv.style.display = "none";
      }
    });
    
    // ============ INICIALIZACIÓN ============
    cargarConfigLocal();
    
    const emailGuardado = localStorage.getItem("recordarEmail");
    if(emailGuardado) {
      document.getElementById("loginEmail").value = emailGuardado;
      document.getElementById("rememberMeCheckbox").checked = true;
    }
    
    auth.onAuthStateChanged(async (user) => {
      if(user) {
        currentUser = user;
    // PREMIUM: Admin Pro Branding for Florencia
    if (user && user.email === "florenciaamor36@gmail.com") {
      const pPlan = document.getElementById('perfilPlan');
      if(pPlan) pPlan.innerHTML = '<i class="fas fa-shield-alt" style="color:#f5af19"></i> ADMIN PRO';
      const pBadge = document.getElementById('perfilPlanBadge');
      if(pBadge) { 
        pBadge.innerText = "DUEÑA"; 
        pBadge.style.background = "linear-gradient(145deg, #f5af19, #f12711)"; 
        pBadge.style.color = "white";
      }
    }
    
        document.getElementById("loginWrapper").style.display = "none";
        document.getElementById("appContainer").style.display = "flex";
        document.body.style.overflow = "hidden";
        document.body.style.height = "100vh";
        document.body.style.position = "fixed";
        document.body.style.width = "100%";
        await verificarSuscripcion(user.uid);
        await cargarPerfiles();
        iniciarListenerFirestore(user.uid);
        toast("Bienvenido " + user.email);
        if(notificationsEnabled) mostrarAvisoVencimientos();
      } else {
        currentUser = null;
        document.getElementById("loginWrapper").style.display = "flex";
        document.getElementById("appContainer").style.display = "none";
        document.body.style.overflow = "";
        document.body.style.height = "";
        document.body.style.position = "";
        document.body.style.width = "";
        if(unsubscribeFirestore) unsubscribeFirestore();
      }
    });

    function initZapiaChat(){
      const bubble = document.getElementById('zapiaBubble');
      const win = document.getElementById('zapiaWindow');
      if(!bubble) return;
      bubble.onclick = () => { win.style.display='flex'; bubble.style.display='none'; };
      document.getElementById('closeZapia').onclick = () => { win.style.display='none'; bubble.style.display='flex'; };
      const inp = document.getElementById('zapiaInp');
      const body = document.getElementById('zapiaChat');
      const send = () => {
        const t = inp.value.trim(); if(!t) return;
        const m = (txt, cl) => { const d=document.createElement('div'); d.className='zapia-msg '+cl; d.innerText=txt; body.appendChild(d); body.scrollTop=body.scrollHeight; };
        m(t, 'user'); inp.value='';
        setTimeout(() => {
          let r = "Hola! Soy Zapia. Flor te puede ayudar por WhatsApp si necesitas algo puntual.";
          const l = t.toLowerCase();
          if(l.includes("pago") || l.includes("prex")) r = "Podés pagar por Prex al alias: ultralinkpagos.ar";
          else if(l.includes("hola")) r = "¡Hola! ¿En qué te puedo ayudar hoy?";
          m(r, 'bot');
        }, 800);
      };
      document.getElementById('zapiaSendBtn').onclick = send;
      inp.onkeypress = (e) => { if(e.key==='Enter') send(); };
    }
    setTimeout(initZapiaChat, 2000);
    