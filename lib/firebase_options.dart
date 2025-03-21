// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBkjdkq0w-kYaRzRCW5LdizPTN8Srj3MnA',
    appId: '1:842655527724:web:d4bcf045439b6f8d08b289',
    messagingSenderId: '842655527724',
    projectId: 'bustrackingapp-12967',
    authDomain: 'bustrackingapp-12967.firebaseapp.com',
    storageBucket: 'bustrackingapp-12967.firebasestorage.app',
    measurementId: 'G-CZJCZ0F1B6',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA3csv8ICqeydiCFl1QCUzn2fy_rBhIrBk',
    appId: '1:842655527724:android:da13f6618f8cbe9208b289',
    messagingSenderId: '842655527724',
    projectId: 'bustrackingapp-12967',
    storageBucket: 'bustrackingapp-12967.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDJAAI4WNEb-ljCN0xvfdZoa-RE9dtwPfc',
    appId: '1:842655527724:ios:985423b2c238806308b289',
    messagingSenderId: '842655527724',
    projectId: 'bustrackingapp-12967',
    storageBucket: 'bustrackingapp-12967.firebasestorage.app',
    iosBundleId: 'com.example.busTracking',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDJAAI4WNEb-ljCN0xvfdZoa-RE9dtwPfc',
    appId: '1:842655527724:ios:985423b2c238806308b289',
    messagingSenderId: '842655527724',
    projectId: 'bustrackingapp-12967',
    storageBucket: 'bustrackingapp-12967.firebasestorage.app',
    iosBundleId: 'com.example.busTracking',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBkjdkq0w-kYaRzRCW5LdizPTN8Srj3MnA',
    appId: '1:842655527724:web:c72b8b80651950ee08b289',
    messagingSenderId: '842655527724',
    projectId: 'bustrackingapp-12967',
    authDomain: 'bustrackingapp-12967.firebaseapp.com',
    storageBucket: 'bustrackingapp-12967.firebasestorage.app',
    measurementId: 'G-SMEFPNY1MD',
  );

}