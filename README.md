# strmflwpr v2.0

**Streaming account manager for resellers** — built with Flutter + Firebase.

> Gestionate cuentas de streaming y perfiles como un pro. Registro de clientes, ventas, renovaciones, stock y estadísticas.

---

## ✨ Features

### Core
- 🔐 Firebase Authentication (email/password)
- 📱 Real-time Firestore streams (no stale data)
- 🌙 Dark/light/system theme

### Inventory Management
- 🎬 **Platforms**: Netflix, Disney+, Spotify, etc. with custom emoji & pricing
- 📦 **Accounts**: master accounts with purchase cost tracking
- 👤 **Profiles**: per-account profiles with PIN, availability tracking
- 📊 **Stock view**: real-time available/sold/reserved counts per platform

### Sales
- 💰 **Quick Sale (Venta Rápida)**: 3-step wizard for fast sales in under 5 taps
- 📋 **Sales management**: active, expired, all — with search
- 🔄 **Renewals**: one-tap renewal with date picker + renewal history
- ✅ **Confirmation dialogs** before all destructive actions
- 📱 **QR code** per sale with share button

### Clients
- 👥 **Client profiles**: name, phone, email, notes, tags
- 🔍 **Search**: by name or phone
- 💵 **Total spent** tracking
- 📜 **Purchase history** per client

### WhatsApp Integration
- 📨 **Templates**: welcome, reminder, expired — customizable per platform
- 🔗 **Client page link**: unique `strmflwpr://client/{token}` deep link per sale
- 🗓 **Automated reminders**: via Workmanager background scheduler

### Financial Dashboard
- 📈 **Line chart**: monthly revenue last 6 months (fl_chart)
- 🥧 **Pie chart**: revenue by platform
- 💡 **Stats**: total revenue, this month, avg price, best platform
- 📤 **CSV export** of all sales

---

## 🚀 Setup

### 1. Firebase
See [FIREBASE_SETUP.md](FIREBASE_SETUP.md) for full setup instructions.

### 2. Install dependencies
```bash
flutter pub get
```

### 3. Run
```bash
flutter run
```

---

## 🏗️ Architecture

```
lib/
├── main.dart           # Firebase init, Workmanager, providers
├── firebase_options.dart
├── app/                # MaterialApp, routing, theme
├── models/             # Data models with Firestore serialization
├── services/           # Firebase, WhatsApp, notifications, export
├── providers/          # Auth, Theme, Settings (ChangeNotifier)
├── screens/            # Feature screens
└── widgets/            # Reusable UI components
```

---

## 📦 Key Dependencies

| Package | Use |
|---|---|
| `firebase_auth` | Authentication |
| `cloud_firestore` | Real-time database |
| `flutter_local_notifications` | Local push notifications |
| `workmanager` | Background daily expiration check |
| `fl_chart` | Revenue charts |
| `qr_flutter` | QR code generation |
| `share_plus` | System share sheet |
| `url_launcher` | WhatsApp deep links |
| `shared_preferences` | User settings persistence |

---

## 🔧 Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{collection}/{document} {
      allow read, write: if request.auth != null 
        && request.auth.uid == resource.data.userId;
      allow create: if request.auth != null;
    }
  }
}
```

---

## 📱 Build APK

GitHub Actions automatically builds an APK on every push to `main`. Download from the Actions tab.

Manual:
```bash
flutter build apk --release
```

---

## v2.0 Changelog

- ✅ FutureBuilder → StreamBuilder everywhere (real-time updates)
- ✅ `profileName` added to SaleModel
- ✅ Workmanager daily background scheduler for notifications
- ✅ Phone number validation with country code detection
- ✅ Account cards show available/sold profile count
- ✅ Confirmation dialogs before all destructive actions
- ✅ Client management (ClientModel + CRUD screens)
- ✅ Financial dashboard with fl_chart charts
- ✅ Renewals system with history
- ✅ Customizable WhatsApp templates per platform
- ✅ Inventory/stock view
- ✅ Client page unique token + QR code
- ✅ Quick Sale 3-step wizard
- ✅ CSV export
- ✅ Low stock alerts (banner + notifications)
- ✅ Dark/light/system theme toggle
- ✅ Currency symbol setting
