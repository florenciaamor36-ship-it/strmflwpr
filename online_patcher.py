import os
import base64
import re

with open('index.html', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. CSS
css_add = """
    /* OPTIMIZACIÓN TV */
    @media (min-width: 1200px) {
      html { font-size: 22px; }
      .app-container { max-width: 1200px; }
      .bottom-nav-bar { height: 100px; padding-bottom: 20px; }
      .nav-btn i { font-size: 2rem; }
      .card { margin-bottom: 2rem; padding: 2rem; }
    }
    /* ZAPIA AI CHAT */
    .zapia-chat-bubble {
      position: fixed; bottom: 85px; right: 20px;
      width: 55px; height: 55px; border-radius: 50%;
      background: linear-gradient(145deg, #f5af19, #f12711);
      color: white; display: flex; align-items: center; justify-content: center;
      box-shadow: 0 4px 15px rgba(241, 39, 17, 0.4);
      cursor: pointer; z-index: 1000; transition: transform 0.3s;
      border: 2px solid rgba(255,255,255,0.2);
    }
    .zapia-chat-bubble i { font-size: 1.6rem; }
    .zapia-chat-window {
      position: fixed; bottom: 150px; right: 20px;
      width: 320px; height: 450px; background: #0f0c29;
      border: 1px solid rgba(245, 175, 25, 0.3);
      border-radius: 1.5rem; z-index: 1001; display: none;
      flex-direction: column; overflow: hidden;
      box-shadow: 0 10px 30px rgba(0,0,0,0.5);
      backdrop-filter: blur(10px);
    }
    .zapia-chat-header {
      padding: 1rem; background: linear-gradient(145deg, #f5af19, #f12711);
      display: flex; align-items: center; justify-content: space-between;
      color: white;
    }
    .zapia-chat-body { flex: 1; padding: 1rem; overflow-y: auto; display: flex; flex-direction: column; gap: 0.8rem; background: rgba(0,0,0,0.2); }
    .zapia-msg { padding: 0.7rem 1rem; border-radius: 1rem; font-size: 0.8rem; max-width: 85%; line-height: 1.4; }
    .zapia-msg.bot { background: rgba(255,255,255,0.1); align-self: flex-start; color: #fff; border-bottom-left-radius: 0.2rem; }
    .zapia-msg.user { background: #f5af19; align-self: flex-end; color: #000; font-weight: 600; border-bottom-right-radius: 0.2rem; }
    .zapia-chat-footer { padding: 0.8rem; display: flex; gap: 8px; border-top: 1px solid rgba(255,255,255,0.1); background: rgba(0,0,0,0.3); }
    .zapia-chat-input {
      flex: 1; background: rgba(255,255,255,0.05); border: 1px solid rgba(255,255,255,0.1); border-radius: 1rem;
      padding: 0.6rem 1rem; color: #fff; font-size: 0.85rem; outline: none;
    }
    .zapia-chat-send { background: #f5af19; color: #000; border: none; width: 38px; height: 38px; border-radius: 50%; cursor: pointer; display: flex; align-items: center; justify-content: center; }
"""
if '</style>' in content: content = content.replace('</style>', css_add + '\n</style>')

# 2. HTML: Banner & Chat
banner_html = """
        <div id="appAnnouncement" class="card" style="display:none; border:1px solid #f5af19; background:rgba(245,175,25,0.05); margin-bottom:1rem; position:relative; overflow:hidden;">
          <div style="position:absolute; top:0; left:0; width:4px; height:100%; background:#f5af19;"></div>
          <div style="display:flex; align-items:center; gap:10px;">
            <i class="fas fa-bullhorn" style="color:#f5af19; font-size:1.2rem;"></i>
            <div id="announcementContent" style="font-size:0.85rem; font-weight:600; line-height:1.4;"></div>
          </div>
        </div>
"""
if 'id="tab-dashboard"' in content:
    content = content.replace('<div id="tab-dashboard" class="tab-panel active">', '<div id="tab-dashboard" class="tab-panel active">\n' + banner_html)

chat_html = """
    <div class="zapia-chat-bubble" id="zapiaBubble"><i class="fas fa-robot"></i></div>
    <div class="zapia-chat-window" id="zapiaChatWindow">
      <div class="zapia-chat-header">
        <div style="display:flex; align-items:center; gap:8px;"><i class="fas fa-robot"></i><span style="font-weight:700; font-size:0.9rem;">Zapia AI</span></div>
        <i class="fas fa-times" id="closeChat" style="cursor:pointer;"></i>
      </div>
      <div class="zapia-chat-body" id="zapiaChatBody"><div class="zapia-msg bot">¡Hola! Soy Zapia. 😊 ¿En qué puedo ayudarte hoy?</div></div>
      <div class="zapia-chat-footer">
        <input type="text" class="zapia-chat-input" id="zapiaChatInput" placeholder="Escribí tu duda...">
        <button class="zapia-chat-send" id="zapiaSendBtn"><i class="fas fa-paper-plane"></i></button>
      </div>
    </div>
"""
if '</body>' in content: content = content.replace('</body>', chat_html + '\n</body>')

# 3. Prex Section
prex_html = """
          <div class="card" style="margin-top:1rem; border:1px solid #6366f1; background:rgba(99,102,241,0.05);">
            <div style="display:flex; align-items:center; gap:1rem;">
              <div style="width:40px; height:40px; background:#fff; border-radius:8px; display:flex; align-items:center; justify-content:center; color:#6366f1; font-weight:900; font-style:italic;">prex</div>
              <div style="flex:1;">
                <div style="font-size:0.7rem; font-weight:700;">RENOVAR SUSCRIPCIÓN</div>
                <div style="font-size:0.6rem; opacity:0.7;">Transferí a nuestro alias oficial</div>
                <div style="font-size:0.9rem; font-weight:800; color:#fff; margin-top:3px;">ultralinkpagos.ar</div>
              </div>
              <button onclick="copyPrex()" class="btn btn-primary" style="padding:0.5rem 1rem;"><i class="fas fa-copy"></i></button>
            </div>
            <button onclick="window.open('https://wa.me/5492236785329?text=Hola%20Flor,%20ya%20te%20transferí%20por%20Prex%20para%20renovar%20mi%20cuenta', '_blank')" style="width:100%; margin-top:1rem; background:#6366f1; border:none; color:white; padding:0.8rem; border-radius:0.8rem; font-weight:700; cursor:pointer;"><i class="fab fa-whatsapp"></i> INFORMAR PAGO</button>
          </div>
"""
if 'id="semaforoPerfil"' in content:
    content = content.replace('<div style="margin-top:0.8rem;" id="semaforoPerfil"></div>', '<div style="margin-top:0.8rem;" id="semaforoPerfil"></div>\n' + prex_html)

# 4. Manual
manual_nuevo = """
          <div class="manual-section" id="manual-registro"><div class="manual-section-header"><i class="fas fa-chevron-right"></i> 1. Registro y Acceso</div><div class="manual-section-body"><p>Iniciá sesión con Google. Tu cuenta se activa automáticamente en modo Demo. Para acceso Full, contactá a soporte.</p></div></div>
          <div class="manual-section" id="manual-pagos"><div class="manual-section-header"><i class="fas fa-chevron-right"></i> 2. Pagos y Renovación</div><div class="manual-section-body"><p>En 'Mi Cuenta' encontrás el alias oficial de Prex. Transferí e informá el pago por el botón de WhatsApp para activación inmediata.</p></div></div>
          <div class="manual-section" id="manual-zapia"><div class="manual-section-header"><i class="fas fa-chevron-right"></i> 3. Asistente Zapia IA</div><div class="manual-section-body"><p>Usá el icono del robot abajo a la derecha para sacarte dudas rápidas sobre pagos, vencimientos y perfiles sin esperar.</p></div></div>
          <div class="manual-section" id="manual-gestion"><div class="manual-section-header"><i class="fas fa-chevron-right"></i> 4. Gestión de Perfiles</div><div class="manual-section-body"><p>Control total: Copiar, Renovar, Editar y Vender. Sin límites de pantallas ni dispositivos conectados.</p></div></div>
          <div class="manual-section" id="manual-anuncios"><div class="manual-section-header"><i class="fas fa-chevron-right"></i> 5. Tablón de Anuncios</div><div class="manual-section-body"><p>Revisá el Dashboard para ver noticias importantes y promos de Flor que aparecen arriba de tus estadísticas.</p></div></div>
"""
content = re.sub(r'<div class="manual-section" id="manual-intro">.*?id="manual-config">.*?</div></div>', manual_nuevo, content, flags=re.DOTALL)

# 5. JS
js_logic = """
    // PREMIUM FEATURES
    function copyPrex() { navigator.clipboard.writeText('ultralinkpagos.ar'); toast('Alias copiado: ultralinkpagos.ar'); }
    async function loadAppAnnouncement() {
      try {
        const d = await db.collection('config').doc('announcement').get();
        if (d.exists && d.data().text) {
          const el = document.getElementById('appAnnouncement');
          if(el) { el.style.display = 'block'; document.getElementById('announcementContent').innerText = d.data().text; }
        }
      } catch(e) {}
    }
    function updateProfileUI(user, data) {
      const emailEl = document.getElementById('perfilEmail');
      const planEl = document.getElementById('perfilPlan');
      const badgeEl = document.getElementById('perfilPlanBadge');
      if(emailEl) emailEl.innerText = user.email;
      if(user.email === "florenciaamor36@gmail.com") {
        if(planEl) planEl.innerHTML = '<i class="fas fa-shield-alt" style="color:#f5af19;"></i> ADMIN PRO';
        if(badgeEl) { badgeEl.innerText = "DUEÑA"; badgeEl.style.background = "linear-gradient(145deg, #f5af19, #f12711)"; badgeEl.style.color = "white"; }
      } else {
        if(planEl) planEl.innerText = (data.estado || 'DEMO').toUpperCase();
        if(badgeEl) { const st = data.estado || 'demo'; badgeEl.innerText = st === 'activo' ? 'PREMIUM' : 'PRUEBA'; badgeEl.className = 'badge-' + st; }
      }
    }
    (function initZapiaChat(){
      setTimeout(() => {
        const bubble = document.getElementById('zapiaBubble');
        const win = document.getElementById('zapiaChatWindow');
        if(!bubble) return;
        bubble.onclick = () => { win.style.display='flex'; bubble.style.display='none'; };
        document.getElementById('closeChat').onclick = () => { win.style.display='none'; bubble.style.display='flex'; };
        const inp = document.getElementById('zapiaChatInput');
        const body = document.getElementById('zapiaChatBody');
        const send = () => {
          const t = inp.value.trim(); if(!t) return;
          const m = (txt, cl) => { const d=document.createElement('div'); d.className='zapia-msg '+cl; d.innerText=txt; body.appendChild(d); body.scrollTop=body.scrollHeight; };
          m(t, 'user'); inp.value='';
          setTimeout(() => {
            let r = "No estoy segura, pero Flor te ayuda por WhatsApp.";
            const l = t.toLowerCase();
            if(l.includes("pago") || l.includes("prex")) r = "Paga por Prex en 'Mi Cuenta' (alias: ultralinkpagos.ar)";
            else if(l.includes("vence")) r = "Fijate tus días en 'Mi Cuenta'.";
            else if(l.includes("hola")) r = "¡Hola! Soy Zapia. ¿Cómo va todo?";
            m(r, 'bot');
          }, 800);
        };
        document.getElementById('zapiaSendBtn').onclick = send;
        inp.onkeypress = (e) => { if(e.key==='Enter') send(); };
      }, 2000);
    })();
"""
if '// ============ FUNCIONES UTILITARIAS ============' in content:
    content = content.replace('// ============ FUNCIONES UTILITARIAS ============', '// ============ FUNCIONES UTILITARIAS ============\n' + js_logic)

# 6. Auth
if 'currentUser = user;' in content:
    content = content.replace('currentUser = user;', 'currentUser = user;\n        db.collection("usuarios").doc(user.uid).update({ lastLogin: firebase.firestore.FieldValue.serverTimestamp() }).catch(()=>{});\n        loadAppAnnouncement();\n        db.collection("usuarios").doc(user.uid).get().then(doc => { updateProfileUI(user, doc.data() || {}); });')

with open('index.html', 'w', encoding='utf-8') as f: f.write(content)
