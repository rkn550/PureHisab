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

  static final FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAb7hHzATDHXhdeSxMnCcisL8SN7MwSKO0',
    appId: '1:583497923220:web:2b2171d847cedd06929281',
    messagingSenderId: '583497923220',
    projectId: 'purehisab-21cf8',
    authDomain: 'purehisab-21cf8.firebaseapp.com',
    storageBucket: 'purehisab-21cf8.firebasestorage.app',
    measurementId: 'G-6M6Z3N0008',
  );

  static final FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCcrcQoUCUQoO4Gj19m1Ob5lBKsznY6xTY',
    appId: '1:583497923220:android:dd7c10dd8df71744929281',
    messagingSenderId: '583497923220',
    projectId: 'purehisab-21cf8',
    storageBucket: 'purehisab-21cf8.firebasestorage.app',
  );

  static final FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDmQvD1OQTg5BomYBizp1awiqjnR1gEFyU',
    appId: '1:583497923220:ios:ecf24d5cbf0b049e929281',
    messagingSenderId: '583497923220',
    projectId: 'purehisab-21cf8',
    storageBucket: 'purehisab-21cf8.firebasestorage.app',
    iosBundleId: 'com.example.purehisab',
  );

  static final FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDmQvD1OQTg5BomYBizp1awiqjnR1gEFyU',
    appId: '1:583497923220:ios:ecf24d5cbf0b049e929281',
    messagingSenderId: '583497923220',
    projectId: 'purehisab-21cf8',
    storageBucket: 'purehisab-21cf8.firebasestorage.app',
    iosBundleId: 'com.example.purehisab',
  );

  static final FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAb7hHzATDHXhdeSxMnCcisL8SN7MwSKO0',
    appId: '1:583497923220:web:28f56fb966ce308c929281',
    messagingSenderId: '583497923220',
    projectId: 'purehisab-21cf8',
    authDomain: 'purehisab-21cf8.firebaseapp.com',
    storageBucket: 'purehisab-21cf8.firebasestorage.app',
    measurementId: 'G-RPPMFF8JFK',
  );
}
