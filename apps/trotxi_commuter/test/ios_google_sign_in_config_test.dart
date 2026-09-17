import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'iOS Google sign-in has a native client ID and matching callback scheme',
    () {
      final plist = File('ios/Runner/Info.plist').readAsStringSync();
      final clientMatch = RegExp(
        r'<key>GIDClientID</key>\s*<string>([^<]+)</string>',
      ).firstMatch(plist);
      expect(
        clientMatch,
        isNotNull,
        reason: 'serverClientId alone cannot configure the native iOS SDK',
      );
      final clientId = clientMatch!.group(1)!;
      expect(clientId, endsWith('.apps.googleusercontent.com'));
      expect(clientId, isNot(contains(r'$(')));
      final firebase =
          jsonDecode(
                File('android/app/google-services.json').readAsStringSync(),
              )
              as Map<String, dynamic>;
      final rider = (firebase['client'] as List)
          .cast<Map<String, dynamic>>()
          .firstWhere(
            (entry) =>
                entry['client_info']['android_client_info']['package_name'] ==
                'com.trotxi.trotxi_commuter',
          );
      final registration =
          (rider['services']['appinvite_service']['other_platform_oauth_client']
                  as List)
              .cast<Map<String, dynamic>>()
              .firstWhere(
                (entry) =>
                    entry['client_type'] == 2 &&
                    entry['ios_info']['bundle_id'] ==
                        'com.trotxi.trotxiCommuter',
              );
      expect(
        clientId,
        registration['client_id'],
        reason: 'Use the registered iOS client, not an Android or web client',
      );
      final urls = RegExp(
        r'<key>CFBundleURLSchemes</key>\s*<array>([\s\S]*?)</array>',
      ).allMatches(plist).map((match) => match.group(1)!).join();
      final reversedClientId = clientId.split('.').reversed.join('.');
      expect(
        urls,
        contains('<string>$reversedClientId</string>'),
        reason: 'Google must be able to return control to the rider app',
      );
    },
  );

  test(
    'iOS plist config supplies the same backend audience as Dart and Render',
    () {
      final plist = File('ios/Runner/Info.plist').readAsStringSync();
      final serverMatch = RegExp(
        r'<key>GIDServerClientID</key>\s*<string>([^<]+)</string>',
      ).firstMatch(plist);
      expect(
        serverMatch,
        isNotNull,
        reason:
            'Without a runtime clientId, the iOS plugin ignores '
            'serverClientId in Dart and uses Info.plist instead',
      );
      final serverId = serverMatch!.group(1)!;
      final source = File(
        'lib/Features/Onboarding/pages/onboard_page.dart',
      ).readAsStringSync();
      final dartId = RegExp(
        r"_googleServerId\s*=\s*'([^']+)'",
      ).firstMatch(source)?.group(1);
      final renderId = RegExp(
        r'key: REPLACEMENT_GOOGLE_CLIENT_ID\s+value: ([^\s]+)',
      ).firstMatch(File('../../render.yaml').readAsStringSync())?.group(1);
      expect(dartId, isNotNull);
      expect(renderId, isNotNull);
      expect(serverId, dartId);
      expect(serverId, renderId);
      final nativeId = RegExp(
        r'<key>GIDClientID</key>\s*<string>([^<]+)</string>',
      ).firstMatch(plist)?.group(1);
      expect(serverId, isNot(nativeId));
    },
  );

  test(
    'backend audience stays separate and token responses are not logged',
    () {
      final source = File(
        'lib/Features/Onboarding/pages/onboard_page.dart',
      ).readAsStringSync();
      expect(source, contains('initialize(serverClientId: _googleServerId)'));
      expect(source, isNot(contains('Backend authentication response:')));
    },
  );
}
