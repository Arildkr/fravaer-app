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
    apiKey: 'AIzaSyA8ZnvpNXKfrCwtKPLpNi9nZ71-I5mD358',
    appId: '1:945845824430:android:62721a95cc69206e21b63f',
    messagingSenderId: '945845824430',
    projectId: 'fravaer-app-prod',
    storageBucket: 'fravaer-app-prod.firebasestorage.app',
  );

}