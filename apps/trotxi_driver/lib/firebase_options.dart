import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform, kIsWeb;
import 'package:trotxi_client/mobile_build_config.dart';

/// Provider identity comes from the same environment file as the API.
/// There is deliberately no fallback to the old staging Firebase project.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    const config = MobileBuildConfig.fromEnvironment;
    if (kIsWeb ||
        !{
          TargetPlatform.android,
          TargetPlatform.iOS,
        }.contains(defaultTargetPlatform)) {
      throw UnsupportedError('This app requires Android or iOS.');
    }
    final ios = defaultTargetPlatform == TargetPlatform.iOS;
    final platform = ios ? 'IOS' : 'ANDROID';
    return FirebaseOptions(
      apiKey: config.require('FIREBASE_${platform}_API_KEY'),
      appId: config.require('FIREBASE_${platform}_APP_ID'),
      messagingSenderId: config.require('FIREBASE_SENDER_ID'),
      projectId: config.require('FIREBASE_PROJECT_ID'),
      iosBundleId: ios ? config.require('FIREBASE_IOS_BUNDLE_ID') : null,
    );
  }
}
