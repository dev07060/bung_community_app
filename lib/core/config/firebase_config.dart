import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseConfig {
  static Future<void> initialize() async {
    // Check if Firebase is already initialized
    if (Firebase.apps.isNotEmpty) {
      if (kDebugMode) {
        print('Firebase already initialized');
      }
      return;
    }

    try {
      // Firebase 초기화는 main.dart에서 DefaultFirebaseOptions를 사용하므로 여기서는 스킵
      if (kDebugMode) {
        print('Firebase initialization handled in main.dart');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Firebase initialization error: $e');
      }
      rethrow;
    }
  }

  static FirebaseOptions _getFirebaseOptions() {
    if (kIsWeb) {
      return const FirebaseOptions(
        apiKey: "your-web-api-key",
        authDomain: "your-project.firebaseapp.com",
        projectId: "your-project-id",
        storageBucket: "your-project.appspot.com",
        messagingSenderId: "your-sender-id",
        appId: "your-web-app-id",
      );
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return const FirebaseOptions(
        apiKey: "your-android-api-key",
        appId: "your-android-app-id",
        messagingSenderId: "your-sender-id",
        projectId: "your-project-id",
        storageBucket: "your-project.appspot.com",
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return const FirebaseOptions(
        apiKey: "your-ios-api-key",
        appId: "your-ios-app-id",
        messagingSenderId: "your-sender-id",
        projectId: "your-project-id",
        storageBucket: "your-project.appspot.com",
        iosBundleId: "com.example.ourBungPlay",
      );
    }

    throw UnsupportedError('Unsupported platform');
  }
}
