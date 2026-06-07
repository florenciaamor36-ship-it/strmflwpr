import os
import re

with open('current_index.html', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. ADMIN PRO Badge + Logo shield
if 'id="perfilPlan">DEMO</div>' in content:
    # Si es florenciaamor36@gmail.com, forzar ADMIN PRO en el JS o directamente aqui si es el perfil
    # Mejor en el JS que ya puse antes (updateProfileUI)
    # Solo me aseguro que el HTML tenga el ID correcto
    pass

# 2. Prex Section
prex_html = """
          <div class="card" style="margin-top:1rem; border:1px solid #6366f1; background:rgba(99,102,241,0.05);">
            <div style="display:flex; align-items:center; gap:1rem;">
              <div style="width:40px; height:40px; background:#fff; border-radius:8px; display:flex; align-items:center; justify-content:center; color:#6366f1; font-weight:900; font-style:italic;">prex</div>
              <div style="flex:1;">
                <div style="font-size:0.7rem; font-weight:700;">RENOVAR SUSCRIPCIÓN</div>
                <div style="font-size:0.6rem; opacity:0.7;">Transferí a nuestro alias oficial</div>
                <div style="font-size:0.9rem; font-weight:800; color:#fff; margin-top:3px;">ultralinkpagos.ar</div>
              </div>
              <button onclick="navigator.clipboard.writeText('ultralinkpagos.ar'); toast('Alias copiado');" class="btn btn-primary" style="padding:0.5rem 1rem;"><i class="fas fa-copy"></i></button>
            </div>
            <button onclick="window.open('https://wa.me/5492236785329?text=Hola%20Flor,%20ya%20te%20transferí%20por%20Prex', '_blank')" style="width:100%; margin-top:1rem; background:#6366f1; border:none; color:white; padding:0.8rem; border-radius:0.8rem; font-weight:700; cursor:pointer;"><i class="fab fa-whatsapp"></i> INFORMAR PAGO</button>
          </div>
"""
if 'id="semaforoPerfil"></div>' in content and 'ultralinkpagos.ar' not in content:
    content = content.replace('id="semaforoPerfil"></div>', 'id="semaforoPerfil"></div>' + prex_html)

# 3. Zapia AI Floating Bubble
chat_html = """
    <div onclick="document.getElementById('zapiaWindow').style.display='flex'; this.style.display='none'" id="zapiaBubble" style="position:fixed; bottom:85px; right:20px; width:60px; height:60px; background:linear-gradient(145deg,#f5af19,#f12711); border-radius:50%; display:flex; align-items:center; justify-content:center; color:white; font-size:1.5rem; z-index:1000; box-shadow:0 5px 15px rgba(0,0,0,0.3); cursor:pointer;"><i class="fas fa-robot"></i></div>
    <div id="zapiaWindow" style="position:fixed; bottom:150px; right:20px; width:300px; height:400px; background:#0f0c29; border:1px solid #f5af19; border-radius:1rem; z-index:1001; display:none; flex-direction:column; overflow:hidden;">
      <div style="padding:1rem; background:linear-gradient(145deg,#f5af19,#f12711); display:flex; justify-content:space-between; align-items:center;">
        <span>Zapia AI</span>
        <i onclick="document.getElementById('zapiaWindow').style.display='none'; document.getElementById('zapiaBubble').style.display='flex'" class="fas fa-times" style="cursor:pointer;"></i>
      </div>
      <div style="flex:1; padding:1rem; overflow-y:auto; font-size:0.8rem;" id="zapiaChat">¡Hola Flor! Soy tu asistente Zapia. ¿Necesitás ayuda con los pagos o renovaciones?</div>
      <div style="padding:0.5rem; display:flex; gap:5px;">
        <input id="zapiaInp" type="text" style="flex:1; background:rgba(255,255,255,0.1); border:none; padding:0.5rem; color:white; border-radius:5px;" placeholder="Escribí...">
        <button onclick="sendZapia()" style="background:#f5af19; border:none; padding:0.5rem; border-radius:5px;"><i class="fas fa-paper-plane"></i></button>
      </div>
    </div>
    <script>
      function sendZapia() {
        const inp = document.getElementById('zapiaInp');
        const chat = document.getElementById('zapiaChat');
        if(!inp.value) return;
        chat.innerHTML += '<br><br><b>Vos:</b> ' + inp.value;
        const v = inp.value.toLowerCase();
        let r = "No tengo esa info ahora, consultale a Flor por WhatsApp.";
        if(v.includes("pago") || v.includes("prex")) r = "Podés pagar por Prex al alias ultralinkpagos.ar";
        chat.innerHTML += '<br><br><b>Zapia:</b> ' + r;
        inp.value = '';
        chat.scrollTop = chat.scrollHeight;
      }
    </script>
"""
if '</body>' in content and 'zapiaBubble' not in content:
    content = content.replace('</body>', chat_html + '</body>')

# 4. Admin Pro Label Fix for the specific user
admin_fix_js = """
      if (user.email === "florenciaamor36@gmail.com") {
        const p = document.getElementById('perfilPlan');
        if(p) p.innerHTML = '<i class="fas fa-shield-alt" style="color:#f5af19"></i> ADMIN PRO';
        const b = document.getElementById('perfilPlanBadge');
        if(b) { b.innerText = "DUEÑA"; b.style.background = "linear-gradient(145deg, #f5af19, #f12711)"; }
      }
"""
if 'currentUser = user;' in content:
    content = content.replace('currentUser = user;', 'currentUser = user;' + admin_fix_js)

with open('patched_index.html', 'w', encoding='utf-8') as f:
    f.write(content)
