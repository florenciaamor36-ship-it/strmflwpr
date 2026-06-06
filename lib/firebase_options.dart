import "package:firebase_core/firebase_core.dart" show FirebaseOptions;
import "package:flutter/foundation.dart" show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return android;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android: return android;
      default: throw UnsupportedError("Platform not supported");
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyC3BnZ33CruBYHeXnjyqjGKfT2-__DUxBo",
    appId: "1:576163951145:android:b8c5a08d6b906919616238",
    messagingSenderId: "576163951145",
    projectId: "strmflwpr-33e74",
    storageBucket: "strmflwpr-33e74.firebasestorage.app",
  );
}