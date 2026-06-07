import os
import re

with open('index.html', 'r', encoding='utf-8') as f:
    content = f.read()

# Replace big blocks
content = re.sub(r'<style>.*?</style>', '<link rel="stylesheet" href="style.css">', content, flags=re.DOTALL)
content = re.sub(r'<script>\s*// ============ CONFIGURACIÓN FIREBASE ============.*?</script>', '<script src="app.js"></script>', content, flags=re.DOTALL)

# Add Prex
prex_html = """
          <div class="card" style="margin-top:1rem; border:1px solid #6366f1; background:rgba(99,102,241,0.05);">
            <div style="display:flex; align-items:center; gap:1rem;">
              <div style="width:40px; height:40px; background:#fff; border-radius:8px; display:flex; align-items:center; justify-content:center; color:#6366f1; font-weight:900; font-style:italic;">prex</div>
              <div style="flex:1;">
                <div style="font-size:0.7rem; font-weight:700;">RENOVAR SUSCRIPCIÓN</div>
                <div style="font-size:0.6rem; opacity:0.7;">Alias oficial Prex</div>
                <div style="font-size:0.9rem; font-weight:800; color:#fff; margin-top:3px;">ultralinkpagos.ar</div>
              </div>
              <button onclick="navigator.clipboard.writeText('ultralinkpagos.ar'); toast('Alias copiado');" class="btn btn-primary" style="padding:0.5rem 1rem;"><i class="fas fa-copy"></i></button>
            </div>
            <button onclick="window.open('https://wa.me/5492236785329?text=Hola%20Flor,%20ya%20te%20transferí%20por%20Prex', '_blank')" style="width:100%; margin-top:1rem; background:#6366f1; border:none; color:white; padding:0.8rem; border-radius:0.8rem; font-weight:700; cursor:pointer;"><i class="fab fa-whatsapp"></i> INFORMAR PAGO</button>
          </div>
"""
if 'id="semaforoPerfil"></div>' in content:
    content = content.replace('id="semaforoPerfil"></div>', 'id="semaforoPerfil"></div>' + prex_html)

# Add Zapia Bubble
zapia_html = """
    <div class="zapia-chat-bubble" id="zapiaBubble"><i class="fas fa-robot"></i></div>
    <div class="zapia-chat-window" id="zapiaWindow">
      <div class="zapia-chat-header">
        <div style="display:flex; align-items:center; gap:8px;"><i class="fas fa-robot"></i><span style="font-weight:700; font-size:0.9rem;">Zapia AI</span></div>
        <i class="fas fa-times" id="closeZapia" style="cursor:pointer;"></i>
      </div>
      <div class="zapia-chat-body" id="zapiaChat"><div class="zapia-msg bot">¡Hola! Soy Zapia. 😊 ¿En qué puedo ayudarte hoy?</div></div>
      <div class="zapia-chat-footer">
        <input type="text" class="zapia-chat-input" id="zapiaInp" placeholder="Escribí tu duda...">
        <button class="zapia-chat-send" id="zapiaSendBtn"><i class="fas fa-paper-plane"></i></button>
      </div>
    </div>
"""
if '</body>' in content:
    content = content.replace('</body>', zapia_html + '\n</body>')

with open('index.html', 'w', encoding='utf-8') as f:
    f.write(content)
