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
    apiKey: 'AIzaSyC2YS9sChOiLFq9kqdzGV4kKX3yeaQRuiw',
    appId: '1:755385050738:web:f174feed5e8832be0ac4eb',
    messagingSenderId: '755385050738',
    projectId: 'purehisab-43e69',
    authDomain: 'purehisab-43e69.firebaseapp.com',
    storageBucket: 'purehisab-43e69.firebasestorage.app',
    measurementId: 'G-R3BSGHCMT8',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA6MdJi0MjarJnPbxOgKXDzRhUYOaVO2YA',
    appId: '1:755385050738:android:fa945241e439b2b40ac4eb',
    messagingSenderId: '755385050738',
    projectId: 'purehisab-43e69',
    storageBucket: 'purehisab-43e69.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAO7F8PWkzRp-lLUGAwaKaqgF3oelXa4UY',
    appId: '1:755385050738:ios:2d3de36a8753e63d0ac4eb',
    messagingSenderId: '755385050738',
    projectId: 'purehisab-43e69',
    storageBucket: 'purehisab-43e69.firebasestorage.app',
    iosBundleId: 'com.purehisab.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAO7F8PWkzRp-lLUGAwaKaqgF3oelXa4UY',
    appId: '1:755385050738:ios:2d3de36a8753e63d0ac4eb',
    messagingSenderId: '755385050738',
    projectId: 'purehisab-43e69',
    storageBucket: 'purehisab-43e69.firebasestorage.app',
    iosBundleId: 'com.purehisab.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC2YS9sChOiLFq9kqdzGV4kKX3yeaQRuiw',
    appId: '1:755385050738:web:48ee83381390c6570ac4eb',
    messagingSenderId: '755385050738',
    projectId: 'purehisab-43e69',
    authDomain: 'purehisab-43e69.firebaseapp.com',
    storageBucket: 'purehisab-43e69.firebasestorage.app',
    measurementId: 'G-BW8F18HPNH',
  );
}
