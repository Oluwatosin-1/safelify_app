import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseConfig {
  static FirebaseOptions get platformOptions {
    if (kIsWeb) {
      // Web
      return const FirebaseOptions(
        appId: '1:987744605674:android:276ec0471e387d5304ce93',
        apiKey: 'AIzaSyCgW9uH8bdR2-VZWlYwPFhIiUSHDdjqkyY',
        projectId: 'tele-health-3b847',
        messagingSenderId: '987744605674',
      );
    } else if (Platform.isIOS || Platform.isMacOS) {
      // iOS and MacOS
      return const FirebaseOptions(
        appId: '1:987744605674:android:276ec0471e387d5304ce93',
        apiKey: 'AIzaSyCgW9uH8bdR2-VZWlYwPFhIiUSHDdjqkyY',
        projectId: 'tele-health-3b847',
        messagingSenderId: '987744605674',
        iosBundleId: '' ,
      );
    } else {
      // Android
      return const FirebaseOptions(
        appId: '1:987744605674:android:276ec0471e387d5304ce93',
        apiKey: 'AIzaSyCgW9uH8bdR2-VZWlYwPFhIiUSHDdjqkyY',
        projectId: 'tele-health-3b847',
        messagingSenderId: '987744605674',
        storageBucket: 'tele-health-3b847.appspot.com',
      );
    }
  }
}
