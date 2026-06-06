# 📺 strmflwpr

**Gestor de cuentas streaming para revendedores**

strmflwpr es una app Android (Flutter) que te permite gestionar tus cuentas de plataformas de streaming (Netflix, Disney+, HBO, Spotify, etc.) y los perfiles que vendés individualmente a tus clientes.

---

## ✨ Características

- 🔐 **Multi-usuario** — Login con email y contraseña (Firebase Auth)
- 📺 **Gestión de plataformas** — Netflix, Disney+, HBO Max, Spotify y más. También podés agregar plataformas personalizadas
- 👤 **Gestión de perfiles** — Cada cuenta tiene N perfiles que podés vender individualmente
- 💰 **Registro de ventas** — Seguimiento de ventas con fechas de vencimiento por perfil
- 🔔 **Recordatorios configurables** — Notificaciones X días antes del vencimiento
- 💬 **Integración con WhatsApp** — Genera mensajes pre-llenados y los envía con un tap
- 📊 **Dashboard** — Estadísticas de cuentas, ventas activas y vencimientos próximos
- 🌙 **Dark mode** — Soporte para tema oscuro

---

## 🚀 Setup rápido

### 1. Requisitos previos

- Flutter 3.16.x o superior
- Android Studio o VS Code con el plugin de Flutter
- Cuenta en Firebase (gratuita)

### 2. Clonar el repositorio

```bash
git clone https://github.com/florenciaamor36-ship-it/strmflwpr.git
cd strmflwpr
```

### 3. Configurar Firebase

**⚠️ Paso obligatorio — la app no funciona sin Firebase**

Ver instrucciones detalladas en [FIREBASE_SETUP.md](FIREBASE_SETUP.md).

En resumen:
1. Crear proyecto en [Firebase Console](https://console.firebase.google.com)
2. Habilitar Authentication (email/contraseña)
3. Habilitar Firestore Database
4. Descargar `google-services.json` y colocarlo en `android/app/`
5. Actualizar `lib/firebase_options.dart` con tus valores reales

### 4. Instalar dependencias

```bash
flutter pub get
```

### 5. Ejecutar en desarrollo

```bash
flutter run
```

---

## 📱 Descargar el APK

### Opción A — GitHub Actions (recomendado)

Cada vez que se hace un push a `main`, GitHub Actions compila el APK automáticamente.

1. Ve a **Actions** en este repositorio
2. Hacé clic en el último workflow completado (✅)
3. En la sección **Artifacts**, descargá `strmflwpr-apk`

### Opción B — Compilar manualmente

```bash
flutter build apk --release
# El APK estará en: build/app/outputs/flutter-apk/app-release.apk
```

### Instalar el APK en Android

1. Transferir el APK al teléfono
2. En el teléfono: **Ajustes → Seguridad → Instalar apps desconocidas** → Permitir
3. Abrir el APK desde el gestor de archivos

---

## 🏗️ Estructura del proyecto

```
lib/
├── main.dart                    # Punto de entrada
├── firebase_options.dart        # Config de Firebase (debes completar)
├── models/                      # Modelos de datos
│   ├── platform_model.dart      # Plataformas streaming
│   ├── account_model.dart       # Cuentas
│   ├── profile_model.dart       # Perfiles
│   └── sale_model.dart          # Ventas
├── services/
│   ├── auth_service.dart        # Firebase Auth
│   ├── firestore_service.dart   # Firestore CRUD
│   ├── notification_service.dart # Notificaciones locales
│   └── whatsapp_service.dart    # Generación de mensajes WhatsApp
├── screens/                     # Pantallas
│   ├── auth/                    # Login / Registro
│   ├── home/                    # Dashboard
│   ├── platforms/               # Plataformas
│   ├── accounts/                # Cuentas
│   ├── profiles/                # Perfiles
│   ├── sales/                   # Ventas
│   └── settings/                # Configuración
└── widgets/                     # Componentes reutilizables
```

---

## 🔧 Tech Stack

| Tecnología | Uso |
|---|---|
| Flutter 3.16+ | Framework UI |
| Dart 3.x | Lenguaje |
| Firebase Auth | Autenticación |
| Cloud Firestore | Base de datos |
| flutter_local_notifications | Recordatorios |
| url_launcher | WhatsApp |
| provider | State management |
| google_fonts | Tipografía |

---

## 📋 Plataformas incluidas por defecto

| Plataforma | Emoji | Perfiles |
|---|---|---|
| Netflix | 🎬 | 5 |
| Disney+ | 🏰 | 4 |
| HBO Max | 👑 | 5 |
| Amazon Prime | 📦 | 3 |
| Spotify | 🎵 | 6 |
| YouTube Premium | ▶️ | 6 |
| Paramount+ | ⭐ | 3 |
| Apple TV+ | 🍎 | 6 |
| Star+ | ⭐ | 4 |
| Crunchyroll | 🎌 | 4 |
| Canva Pro | 🎨 | 5 |
| Microsoft 365 | 💼 | 5 |

Podés agregar plataformas personalizadas desde la app.

---

## 🤝 Contribuir

Pull requests bienvenidos. Para cambios grandes, abrir primero un issue.

---

## 📄 Licencia

MIT
