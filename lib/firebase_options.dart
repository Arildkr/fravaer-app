// Generert fra google-services.json for Firebase-prosjekt "alle-med"
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions er ikke konfigurert for denne plattformen.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBA2EaoTrOqya7uEEOqNaXdXRF5NTVtZh0',
    appId: '1:591979578674:android:f9fac989e46365eec6032b',
    messagingSenderId: '591979578674',
    projectId: 'alle-med',
    storageBucket: 'alle-med.firebasestorage.app',
  );
}
