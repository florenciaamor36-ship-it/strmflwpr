# Firebase Setup Guide

## 1. Create Firebase Project

1. Go to [console.firebase.google.com](https://console.firebase.google.com)
2. Create new project: `strmflwpr` (or your preferred name)
3. Disable Google Analytics (optional)

## 2. Enable Authentication

1. Firebase Console → Authentication → Get started
2. Sign-in method → Email/Password → Enable → Save

## 3. Enable Firestore

1. Firebase Console → Firestore Database → Create database
2. Start in **production mode**
3. Choose your region (e.g. `southamerica-east1` for Argentina)

## 4. Add Android App

1. Firebase Console → Project settings → Add app → Android
2. Package name: `com.strmflwpr.app`
3. Download `google-services.json`
4. Place it at: `android/app/google-services.json`

## 5. Configure firebase_options.dart

Run FlutterFire CLI to auto-generate:
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure (from your Flutter project root)
flutterfire configure --project=YOUR_PROJECT_ID
```

This will update `lib/firebase_options.dart` with your real credentials.

**OR** manually edit `lib/firebase_options.dart` and replace all `YOUR_*` placeholders with values from Firebase Console → Project settings → Your apps.

## 6. Firestore Security Rules

Firebase Console → Firestore → Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own data
    match /platforms/{doc} {
      allow read, write: if request.auth != null 
        && (resource == null || resource.data.userId == request.auth.uid)
        && (request.resource == null || request.resource.data.userId == request.auth.uid);
    }
    match /accounts/{doc} {
      allow read, write: if request.auth != null 
        && (resource == null || resource.data.userId == request.auth.uid)
        && (request.resource == null || request.resource.data.userId == request.auth.uid);
    }
    match /profiles/{doc} {
      allow read, write: if request.auth != null 
        && (resource == null || resource.data.userId == request.auth.uid)
        && (request.resource == null || request.resource.data.userId == request.auth.uid);
    }
    match /sales/{doc} {
      allow read, write: if request.auth != null 
        && (resource == null || resource.data.userId == request.auth.uid)
        && (request.resource == null || request.resource.data.userId == request.auth.uid);
    }
    match /clients/{doc} {
      allow read, write: if request.auth != null 
        && (resource == null || resource.data.userId == request.auth.uid)
        && (request.resource == null || request.resource.data.userId == request.auth.uid);
    }
    match /templates/{doc} {
      allow read, write: if request.auth != null 
        && (resource == null || resource.data.userId == request.auth.uid)
        && (request.resource == null || request.resource.data.userId == request.auth.uid);
    }
    match /renewals/{doc} {
      allow read, write: if request.auth != null 
        && (resource == null || resource.data.userId == request.auth.uid)
        && (request.resource == null || request.resource.data.userId == request.auth.uid);
    }
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## 7. Firestore Indexes

Create these composite indexes (Firebase will also prompt you in debug mode):

| Collection | Fields | Order |
|---|---|---|
| `sales` | `userId` ASC, `expirationDate` ASC | - |
| `sales` | `userId` ASC, `status` ASC, `expirationDate` ASC | - |
| `sales` | `userId` ASC, `clientId` ASC, `createdAt` DESC | - |
| `sales` | `userId` ASC, `createdAt` ASC | - |
| `platforms` | `userId` ASC, `isActive` ASC, `name` ASC | - |
| `accounts` | `userId` ASC, `platformId` ASC | - |
| `profiles` | `userId` ASC, `accountId` ASC | - |
| `profiles` | `userId` ASC, `platformId` ASC, `status` ASC | - |
| `renewals` | `saleId` ASC, `renewedAt` DESC | - |

## 8. Build & Run

```bash
flutter pub get
flutter run
```

For APK:
```bash
flutter build apk --release
```

## 9. Optional: Google Services JSON for CI/CD

If using GitHub Actions, add `google-services.json` content as a repository secret:
- Secret name: `GOOGLE_SERVICES_JSON`
- Add a build step to write the file before building

```yaml
- name: Write google-services.json
  run: echo '${{ secrets.GOOGLE_SERVICES_JSON }}' > android/app/google-services.json
```
