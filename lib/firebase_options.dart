// File: lib/firebase_options.dart

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyCf81OnIDA4eMz1jKY7InO8RmrqDDn2FNM",
    authDomain: "belajarin-2121.firebaseapp.com",
    projectId: "belajarin-2121",
    storageBucket: "belajarin-2121.firebasestorage.app",
    messagingSenderId: "844286991467",
    appId: "1:844286991467:web:be5514f91113388b23252e",
    measurementId: "G-5Q88DQY6Z1",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyCf81OnIDA4eMz1jKY7InO8RmrqDDn2FNM",
    authDomain: "belajarin-2121.firebaseapp.com",
    projectId: "belajarin-2121",
    storageBucket: "belajarin-2121.firebasestorage.app",
    messagingSenderId: "844286991467",
    appId: "1:844286991467:web:be5514f91113388b23252e",
    measurementId: "G-5Q88DQY6Z1",
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "AIzaSyCf81OnIDA4eMz1jKY7InO8RmrqDDn2FNM",
    authDomain: "belajarin-2121.firebaseapp.com",
    projectId: "belajarin-2121",
    storageBucket: "belajarin-2121.firebasestorage.app",
    messagingSenderId: "844286991467",
    appId: "1:844286991467:web:be5514f91113388b23252e",
    measurementId: "G-5Q88DQY6Z1",
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: "AIzaSyCf81OnIDA4eMz1jKY7InO8RmrqDDn2FNM",
    authDomain: "belajarin-2121.firebaseapp.com",
    projectId: "belajarin-2121",
    storageBucket: "belajarin-2121.firebasestorage.app",
    messagingSenderId: "844286991467",
    appId: "1:844286991467:web:be5514f91113388b23252e",
    measurementId: "G-5Q88DQY6Z1",
  );
}
