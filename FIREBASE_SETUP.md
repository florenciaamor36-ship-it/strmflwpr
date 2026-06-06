# 🔥 Configuración de Firebase para strmflwpr

Seguí estos pasos para conectar la app a tu propio proyecto de Firebase.

---

## Paso 1 — Crear un proyecto en Firebase

1. Ir a [https://console.firebase.google.com](https://console.firebase.google.com)
2. Hacer clic en **"Agregar proyecto"**
3. Nombre del proyecto: `strmflwpr` (o el que prefieras)
4. Desactivar Google Analytics (opcional, no es necesario)
5. Hacer clic en **"Crear proyecto"**

---

## Paso 2 — Agregar la app Android

1. En la consola de Firebase, hacer clic en el ícono de Android **( 🤖 )**
2. Completar:
   - **Package name:** `com.strmflwpr.app`
   - **App nickname:** strmflwpr (opcional)
   - **SHA-1:** dejar vacío por ahora
3. Hacer clic en **"Registrar app"**
4. **Descargar `google-services.json`**
5. Colocar el archivo en: `android/app/google-services.json`

   ```
   strmflwpr/
   └── android/
       └── app/
           └── google-services.json  ← acá
   ```

6. Hacer clic en **"Siguiente"** hasta terminar

---

## Paso 3 — Habilitar Authentication

1. En la consola de Firebase, ir a **Authentication** (menú izquierdo)
2. Hacer clic en **"Comenzar"**
3. En la pestaña **"Métodos de inicio de sesión"**
4. Hacer clic en **Email/Contraseña**
5. Activar el primer toggle (Email/Contraseña)
6. Hacer clic en **"Guardar"**

---

## Paso 4 — Crear la base de datos Firestore

1. En la consola, ir a **Firestore Database**
2. Hacer clic en **"Crear base de datos"**
3. Seleccionar **"Iniciar en modo de prueba"** (válido 30 días)
   > ⚠️ Para producción, configurar reglas de seguridad apropiadas
4. Elegir la ubicación más cercana (ej. `southamerica-east1` para Argentina)
5. Hacer clic en **"Listo"**

### Reglas de seguridad recomendadas para producción

En Firestore → Reglas, reemplazar con:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Each user can only access their own data
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## Paso 5 — Actualizar `firebase_options.dart`

Abrir `lib/firebase_options.dart` y reemplazar los valores placeholder con los reales.

Para obtener los valores:
1. En la consola de Firebase, ir a ⚙️ **Configuración del proyecto**
2. En la sección **"Tus apps"**, seleccionar la app Android
3. Copiar los valores del JSON de configuración

Los valores que necesitás:
- `apiKey` → clave de API
- `appId` → ID de la app (formato: `1:XXXX:android:XXXX`)
- `messagingSenderId` → ID del remitente
- `projectId` → ID del proyecto

### Alternativa: usar FlutterFire CLI (recomendado)

```bash
# Instalar la CLI
dart pub global activate flutterfire_cli

# Configurar automáticamente
flutterfire configure
```

Esto actualiza `firebase_options.dart` automáticamente.

---

## Paso 6 — Compilar y probar

```bash
# Instalar dependencias
flutter pub get

# Compilar APK de debug (para pruebas)
flutter run

# Compilar APK de release
flutter build apk --release
```

---

## 📋 Checklist final

- [ ] Proyecto de Firebase creado
- [ ] App Android registrada con package `com.strmflwpr.app`
- [ ] `google-services.json` descargado y colocado en `android/app/`
- [ ] Authentication habilitado (Email/Contraseña)
- [ ] Firestore Database creado
- [ ] `lib/firebase_options.dart` actualizado con valores reales
- [ ] `flutter pub get` ejecutado
- [ ] App compilada y funcionando

---

## 🆘 Problemas comunes

### "FirebaseException: [core/no-app]"
→ Falta configurar Firebase. Verificar que `google-services.json` esté en `android/app/`.

### "Permission denied" en Firestore
→ La base de datos está en modo producción sin reglas. Ir a Firestore → Reglas y configurar acceso.

### "The email address is already in use"
→ Ya existe un usuario con ese email. Intentar con otro email o usar "Olvidé mi contraseña".

### La app no compila con el APK de GitHub Actions
→ Verificar que `google-services.json` esté incluido. Por seguridad, podés agregarlo como GitHub Secret.

---

## 🔐 Seguridad en producción

1. **No subir `google-services.json` a GitHub** si el repo es público
   - Agregar a `.gitignore`
   - Usar GitHub Secrets para el CI/CD

2. **Configurar reglas de Firestore** para proteger los datos

3. **Habilitar App Check** en Firebase para validar que las requests vienen de la app real

4. **Configurar SHA-1** en Firebase para Android production builds
