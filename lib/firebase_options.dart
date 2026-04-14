import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return web;
      case TargetPlatform.linux:
        return web;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCjXsd4daIOv3sgACBamoATYzJFksHSkkI',
    authDomain: 'ai-road-map-80d4a.firebaseapp.com',
    projectId: 'ai-road-map-80d4a',
    appId: '1:413591364448:web:3d03b00b8447aee78e7405',
    messagingSenderId: '413591364448',
    storageBucket: 'ai-road-map-80d4a.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCjXsd4daIOv3sgACBamoATYzJFksHSkkI',
    authDomain: 'ai-road-map-80d4a.firebaseapp.com',
    projectId: 'ai-road-map-80d4a',
    appId: '1:413591364448:web:3d03b00b8447aee78e7405',
    messagingSenderId: '413591364448',
    storageBucket: 'ai-road-map-80d4a.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCjXsd4daIOv3sgACBamoATYzJFksHSkkI',
    authDomain: 'ai-road-map-80d4a.firebaseapp.com',
    projectId: 'ai-road-map-80d4a',
    appId: '1:413591364448:web:3d03b00b8447aee78e7405',
    messagingSenderId: '413591364448',
    storageBucket: 'ai-road-map-80d4a.appspot.com',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCjXsd4daIOv3sgACBamoATYzJFksHSkkI',
    authDomain: 'ai-road-map-80d4a.firebaseapp.com',
    projectId: 'ai-road-map-80d4a',
    appId: '1:413591364448:web:3d03b00b8447aee78e7405',
    messagingSenderId: '413591364448',
    storageBucket: 'ai-road-map-80d4a.appspot.com',
  );
}
