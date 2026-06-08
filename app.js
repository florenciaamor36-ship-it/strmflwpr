// StreamFlow Pro - Stable Version
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

let currentUser = null;
let perfiles = [];
let unsubscribeFirestore = null;

const byId = id => document.getElementById(id);

function toast(msg) {
    const t = document.createElement("div");
    t.style = "position:fixed;bottom:80px;left:50%;transform:translateX(-50%);background:rgba(0,0,0,0.9);color:white;padding:12px 24px;border-radius:24px;z-index:10000;font-size:14px;box-shadow:0 4px 12px rgba(0,0,0,0.3);";
    t.innerText = msg;
    document.body.appendChild(t);
    setTimeout(() => t.remove(), 3000);
}

window.cambiarTab = (tabId) => {
    document.querySelectorAll('.tab-panel').forEach(p => p.classList.remove('active'));
    const panel = byId('tab-' + tabId);
    if (panel) panel.classList.add('active');
    document.querySelectorAll('.nav-btn').forEach(b => b.classList.remove('active'));
    const btn = document.querySelector(`.nav-btn[data-nav="${tabId}"]`);
    if (btn) btn.classList.add('active');
};

async function cargarPerfiles() {
    if (!currentUser) return;
    try {
        const snap = await db.collection("usuarios").doc(currentUser.uid).get();
        if (snap.exists && snap.data().perfiles) {
            perfiles = snap.data().perfiles;
            renderizarPerfiles();
        }
    } catch (e) {
        console.error("Error al cargar perfiles:", e);
    }
}

function renderizarPerfiles() {
    const cont = byId("listaPerfilesCont");
    if (!cont) return;
    cont.innerHTML = "";
    if (perfiles.length === 0) {
        cont.innerHTML = "<p style='text-align:center;color:#666;margin-top:20px;'>No hay perfiles cargados.</p>";
        return;
    }
    perfiles.forEach((p, index) => {
        const div = document.createElement("div");
        div.className = "profile-card";
        div.innerHTML = `
            <div class="profile-info">
                <strong>${p.email || 'Sin email'}</strong>
                <span>${p.perfil || 'Perfil'} - ${p.plataforma || 'Netflix'}</span>
            </div>
            <div class="profile-status ${p.estado === 'libre' ? 'libre' : 'ocupado'}">
                ${p.estado || 'libre'}
            </div>
        `;
        cont.appendChild(div);
    });
}

function iniciarListenerFirestore(uid) {
    if (unsubscribeFirestore) unsubscribeFirestore();
    unsubscribeFirestore = db.collection("usuarios").doc(uid).onSnapshot(snap => {
        if (snap.exists && snap.data().perfiles) {
            perfiles = snap.data().perfiles;
            renderizarPerfiles();
        }
    }, err => console.error("Error en listener:", err));
}

document.addEventListener('DOMContentLoaded', () => {
    const loginForm = byId("login-form");
    if (loginForm) {
        loginForm.onsubmit = async (e) => {
            e.preventDefault();
            const email = byId("login-email")?.value.trim();
            const pass = byId("login-pass")?.value;
            if (!email || !pass) return toast("Completar email y contraseña");
            
            const btn = byId("btn-login-index");
            if (btn) {
                btn.disabled = true;
                btn.innerText = "Iniciando...";
            }
            
            try {
                await auth.signInWithEmailAndPassword(email, pass);
            } catch (e) {
                toast("Error: " + e.message);
                if (btn) {
                    btn.disabled = false;
                    btn.innerText = "Iniciar sesión";
                }
            }
        };
    }

    const logoutBtn = byId("logoutBtn");
    if (logoutBtn) {
        logoutBtn.onclick = () => {
            if (confirm("¿Cerrar sesión?")) auth.signOut();
        };
    }

    document.querySelectorAll('.nav-btn').forEach(btn => {
        btn.onclick = () => cambiarTab(btn.dataset.nav);
    });

    auth.onAuthStateChanged(user => {
        const lw = byId("loginWrapper");
        const ac = byId("appContainer");
        const nav = byId("bottomNavBar");
        
        if (user) {
            currentUser = user;
            if (lw) lw.style.display = "none";
            if (ac) ac.style.display = "flex";
            if (nav) nav.style.display = "flex";
            
            // Admin Check
            if (user.email === "florenciaamor36@gmail.com") {
                const pPlan = byId('perfilPlan');
                if (pPlan) pPlan.innerHTML = '<i class="fas fa-shield-alt" style="color:#f5af19"></i> ADMIN PRO';
            }
            
            iniciarListenerFirestore(user.uid);
            cargarPerfiles();
            toast("¡Bienvenido!");
        } else {
            currentUser = null;
            if (lw) lw.style.display = "flex";
            if (ac) ac.style.display = "none";
            if (nav) nav.style.display = "none";
            if (unsubscribeFirestore) unsubscribeFirestore();
            
            const btn = byId("btn-login-index");
            if (btn) {
                btn.disabled = false;
                btn.innerText = "Iniciar sesión";
            }
        }
    });
});
