
// ============================================
// CONFIGURACIÓN FIREBASE
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

// UI Elements
const loginView = document.getElementById('login-view');
const registerView = document.getElementById('register-view');
const errorMsg = document.getElementById('error-msg');

function toggleAuth() {
    loginView.classList.toggle('hidden');
    registerView.classList.toggle('hidden');
    errorMsg.innerText = '';
}

// Redirigir si ya está logueado
auth.onAuthStateChanged(user => {
    if (user) {
        window.location.href = 'index.html';
    }
});

// LOGIN LOGIC
document.getElementById('btn-login').onclick = async () => {
    const email = document.getElementById('login-email').value.trim();
    const pass = document.getElementById('login-pass').value;
    const btnText = document.getElementById('login-text');
    const loader = document.getElementById('login-loader');

    if(!email || !pass) return showError('Completa todos los campos');

    setLoading(true, btnText, loader);
    try {
        await auth.signInWithEmailAndPassword(email, pass);
    } catch (e) {
        showError(mapError(e.code));
        setLoading(false, btnText, loader);
    }
};

// REGISTER LOGIC
document.getElementById('btn-register').onclick = async () => {
    const email = document.getElementById('reg-email').value.trim();
    const pass = document.getElementById('reg-pass').value;
    const btnText = document.getElementById('reg-text');
    const loader = document.getElementById('reg-loader');

    if(!email || !pass) return showError('Completa todos los campos');
    if(pass.length < 6) return showError('Contraseña muy corta (mín. 6)');

    setLoading(true, btnText, loader);
    try {
        await auth.createUserWithEmailAndPassword(email, pass);
    } catch (e) {
        showError(mapError(e.code));
        setLoading(false, btnText, loader);
    }
};

function showError(msg) {
    errorMsg.innerText = msg;
}

function setLoading(isLoading, textEl, loaderEl) {
    if(isLoading) {
        textEl.style.display = 'none';
        loaderEl.style.display = 'block';
        document.querySelectorAll('button').forEach(b => b.disabled = true);
    } else {
        textEl.style.display = 'block';
        loaderEl.style.display = 'none';
        document.querySelectorAll('button').forEach(b => b.disabled = false);
    }
}

function mapError(code) {
    switch(code) {
        case 'auth/user-not-found': return 'Usuario no encontrado';
        case 'auth/wrong-password': return 'Contraseña incorrecta';
        case 'auth/email-already-in-use': return 'El correo ya está en uso';
        case 'auth/invalid-email': return 'Correo inválido';
        case 'auth/weak-password': return 'Contraseña muy débil';
        default: return 'Error (' + code + ')';
    }
}
