const firebaseConfig = {
  apiKey: 'AIzaSyB8jYiHFiD_-MTHUQr2c3WU_b84RAPonvA',
  authDomain: 'stream-flow-pro.firebaseapp.com',
  projectId: 'stream-flow-pro',
  storageBucket: 'stream-flow-pro.firebasestorage.app',
  messagingSenderId: '837367317965',
  appId: '1:837367317965:web:00f039846e2a3646d87084'
};
firebase.initializeApp(firebaseConfig);
const auth = firebase.auth();
const authError = document.getElementById('authError');

// Redireccionar si ya está logueado
auth.onAuthStateChanged(user => {
    if (user) {
        window.location.replace('index.html');
    }
});

document.getElementById('btnLoginSubmit')?.addEventListener('click', async () => {
    const email = document.getElementById('loginEmail').value.trim();
    const pass = document.getElementById('loginPassword').value.trim();
    if(!email || !pass) { 
        authError.innerText = 'Completá todos los campos'; 
        return; 
    }
    const btn = document.getElementById('btnLoginSubmit');
    btn.disabled = true; 
    btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Entrando...';
    
    try {
        await auth.signInWithEmailAndPassword(email, pass);
        // Redirección robusta
        window.location.replace('index.html');
    } catch(e) {
        let msg = 'Error al iniciar sesión';
        if (e.code === 'auth/user-not-found' || e.code === 'auth/wrong-password') {
            msg = 'Correo o contraseña incorrectos';
        } else if (e.code === 'auth/invalid-email') {
            msg = 'Correo electrónico no válido';
        } else {
            msg = 'Error: ' + e.message;
        }
        authError.innerText = msg;
        btn.disabled = false; 
        btn.innerHTML = 'Iniciar sesión';
    }
});

// Registro
document.getElementById('btnRegisterSubmit')?.addEventListener('click', async () => {
    const email = document.getElementById('regEmail').value.trim();
    const pass = document.getElementById('regPassword').value.trim();
    const passConfirm = document.getElementById('regPasswordConfirm').value.trim();
    
    if(!email || !pass || !passConfirm) {
        authError.innerText = 'Completá todos los campos de registro';
        return;
    }
    if(pass !== passConfirm) {
        authError.innerText = 'Las contraseñas no coinciden';
        return;
    }
    if(pass.length < 6) {
        authError.innerText = 'La contraseña debe tener al menos 6 caracteres';
        return;
    }
    
    const btn = document.getElementById('btnRegisterSubmit');
    btn.disabled = true;
    btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Registrando...';
    
    try {
        await auth.createUserWithEmailAndPassword(email, pass);
        window.location.replace('index.html');
    } catch(e) {
        authError.innerText = 'Error: ' + e.message;
        btn.disabled = false;
        btn.innerHTML = 'Registrarse';
    }
});

// Toggles de contraseña
const setupToggle = (btnId, inputId) => {
    document.getElementById(btnId)?.addEventListener('click', function() {
        const input = document.getElementById(inputId);
        const icon = this.querySelector('i');
        if (input.type === 'password') {
            input.type = 'text';
            icon.classList.remove('fa-eye');
            icon.classList.add('fa-eye-slash');
        } else {
            input.type = 'password';
            icon.classList.remove('fa-eye-slash');
            icon.classList.add('fa-eye');
        }
    });
};

setupToggle('toggleLoginPassword', 'loginPassword');
setupToggle('toggleRegPassword', 'regPassword');
setupToggle('toggleRegConfirmPassword', 'regPasswordConfirm');

// Cambio de paneles
document.getElementById('showRegister')?.addEventListener('click', () => {
    document.getElementById('loginPanel').style.display = 'none';
    document.getElementById('registerPanel').style.display = 'block';
    authError.innerText = '';
});

document.getElementById('showLogin')?.addEventListener('click', () => {
    document.getElementById('registerPanel').style.display = 'none';
    document.getElementById('loginPanel').style.display = 'block';
    authError.innerText = '';
});

// Recuperar contraseña
document.getElementById('forgotPasswordBtn')?.addEventListener('click', async () => {
    const email = document.getElementById('loginEmail').value.trim();
    if(!email) {
        authError.innerText = 'Ingresá tu email para restablecer la contraseña';
        return;
    }
    try {
        await auth.sendPasswordResetEmail(email);
        authError.style.color = '#10b981';
        authError.innerText = 'Se envió un correo para restablecer tu contraseña';
    } catch(e) {
        authError.style.color = '#ff6b6b';
        authError.innerText = 'Error: ' + e.message;
    }
});
