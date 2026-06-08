
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

const loginView = document.getElementById('login-view');
const registerView = document.getElementById('register-view');
const errorMsg = document.getElementById('error-msg');

function toggleAuth() {
    loginView.classList.toggle('hidden');
    registerView.classList.toggle('hidden');
    errorMsg.innerText = '';
}

auth.onAuthStateChanged(user => {
    if (user) window.location.href = 'index.html';
});

function setLoading(isLoading, textId, loaderId) {
    const textEl = document.getElementById(textId);
    const loaderEl = document.getElementById(loaderId);
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

document.getElementById('btn-login').onclick = async () => {
    const email = document.getElementById('login-email').value.trim();
    const pass = document.getElementById('login-pass').value;
    if(!email || !pass) { errorMsg.innerText = 'Completa todos los campos'; return; }

    setLoading(true, 'login-text', 'login-loader');
    try {
        await auth.signInWithEmailAndPassword(email, pass);
    } catch (e) {
        errorMsg.innerText = e.message;
        setLoading(false, 'login-text', 'login-loader');
    }
};

document.getElementById('btn-register').onclick = async () => {
    const email = document.getElementById('reg-email').value.trim();
    const pass = document.getElementById('reg-pass').value;
    if(!email || !pass) { errorMsg.innerText = 'Completa todos los campos'; return; }
    if(pass.length < 6) { errorMsg.innerText = 'Mínimo 6 caracteres'; return; }

    setLoading(true, 'reg-text', 'reg-loader');
    try {
        await auth.createUserWithEmailAndPassword(email, pass);
    } catch (e) {
        errorMsg.innerText = e.message;
        setLoading(false, 'reg-text', 'reg-loader');
    }
};
