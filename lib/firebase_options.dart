import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return const FirebaseOptions(
          apiKey: 'AIzaSyDqczZ0I4hYo3z45DvZWb9OiaZnww7gc3g',
          appId: '1:1019289529063:android:129a496f5b972ddf6dd042',
          messagingSenderId: '1019289529063',
          projectId: 'nutripump',
          storageBucket: 'nutripump.firebasestorage.app',
        );
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return const FirebaseOptions(
          apiKey: 'AIzaSyABh-JbQLjJWzqb0fj4ebOZs0YJijKwTJ0',
          appId: '1:1019289529063:ios:f39282240b60ecf36dd042',
          messagingSenderId: '1019289529063',
          projectId: 'nutripump',
          storageBucket: 'nutripump.firebasestorage.app',
          iosClientId: '1019289529063-9lkc83gil9hldhm4ihu4fa04op8npgff.apps.googleusercontent.com',
          iosBundleId: 'com.nutripump.nutripumpMobile',
        );
    }
  }
}
