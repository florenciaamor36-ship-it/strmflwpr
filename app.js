
// ============================================
// STREAMFLOW PRO - CORE ENGINE
// ============================================

const firebaseConfig = {
    apiKey: "AIzaSyB8jYiHFiD_-MTHUQr2c3WU_b84RAPonvA",
    authDomain: "stream-flow-pro.firebaseapp.com",
    projectId: "stream-flow-pro",
    storageBucket: "stream-flow-pro.firebasestorage.app",
    messagingSenderId: "837367317965",
    appId: "1:837367317965:web:00f039846e2a3646d87084"
};

if (!firebase.apps.length) firebase.initializeApp(firebaseConfig);
const auth = firebase.auth();
const db = firebase.firestore();

// Global State
let currentUser = null;

auth.onAuthStateChanged(user => {
    if (user) {
        currentUser = user;
        initApp();
    } else {
        window.location.href = 'login.html';
    }
});

function initApp() {
    console.log("App Initialized for:", currentUser.email);
    // Load Dashboard, Listeners, etc.
    updateUI();
}

function updateUI() {
    const welcome = document.getElementById('welcomeName');
    if(welcome) welcome.innerText = "Hola, " + (currentUser.displayName || currentUser.email.split('@')[0]);
}

// LOGOUT
const btnConfig = document.getElementById('btnConfig');
if(btnConfig) {
    btnConfig.onclick = () => {
        if(confirm('¿Cerrar sesión?')) {
            auth.signOut().then(() => window.location.href = 'login.html');
        }
    };
}

// Global functions like showLoader/hideLoader
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
