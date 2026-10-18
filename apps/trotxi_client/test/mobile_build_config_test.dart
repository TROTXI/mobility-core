import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:trotxi_client/mobile_build_config.dart';

void main() {
  final root = Directory.current.path.endsWith('trotxi_client') ? '../..' : '.';
  final staging = Map<String, String>.from(jsonDecode(
      File('$root/apps/trotxi_commuter/config/staging.json')
          .readAsStringSync()) as Map);
  void validate(Map<String, String> values,
          {bool release = true,
          Map<String, MobileEnvironmentPolicy> policies =
              mobileEnvironmentPolicies}) =>
      MobileBuildConfig(values).validate(release: release, policies: policies);

  test('both checked-in staging environments validate', () {
    for (final app in ['commuter', 'driver']) {
      final values = Map<String, String>.from(jsonDecode(
          File('$root/apps/trotxi_$app/config/staging.json')
              .readAsStringSync()) as Map);
      validate(values);
    }
  });
  for (final key in staging.keys) {
    test('missing $key fails closed', () {
      expect(() => validate({...staging}..remove(key)), throwsFormatException);
    });
  }
  test('production cannot borrow the staging configuration', () {
    expect(() => validate({...staging, 'APP_ENVIRONMENT': 'production'}),
        throwsFormatException);
  });
  for (final value in [
    'http://trotxi-api-staging.onrender.com',
    'https://trotxi-api-staging.onrender.com.evil.test',
    'https://evil.test',
    'https://user:password@trotxi-api-staging.onrender.com',
    'https://trotxi-api-staging.onrender.com/v1',
    'https://trotxi-api-staging.onrender.com?token=private',
    'https://trotxi-api-staging.onrender.com#fragment',
    'http://localhost:3000',
    ''
  ]) {
    test('reject unapproved API origin $value', () {
      expect(() => validate({...staging, 'API_BASE_URL': value}),
          throwsFormatException);
    });
  }
  test('wrong realm, Firebase project, sender and public site fail closed', () {
    for (final key in [
      'API_SESSION_REALM',
      'FIREBASE_PROJECT_ID',
      'FIREBASE_SENDER_ID',
      'FIREBASE_ANDROID_APP_ID',
      'FIREBASE_IOS_APP_ID',
      'PUBLIC_SITE_URL'
    ]) {
      expect(() => validate({...staging, key: 'wrong'}), throwsFormatException);
    }
  });
  test('local emulator API is explicit and debug-only', () {
    for (final host in ['localhost', '127.0.0.1', '10.0.2.2', '[::1]']) {
      final local = {
        ...staging,
        'APP_ENVIRONMENT': 'local',
        'API_BASE_URL': 'http://$host:3000',
        'API_SESSION_REALM': 'local-development'
      };
      validate(local, release: false);
      expect(() => validate(local), throwsFormatException);
      expect(
          () => validate({...local, 'API_BASE_URL': staging['API_BASE_URL']!},
              release: false),
          throwsFormatException);
    }
  });
  test('production policy must isolate API, Firebase, realm and public site',
      () {
    const production = MobileEnvironmentPolicy(
        apiOrigin: 'https://api.example.test',
        publicSiteOrigin: 'https://www.example.test',
        realm: 'production-1',
        firebaseProject: 'trotxi-production-example',
        firebaseSender: '999999999');
    final policies = {...mobileEnvironmentPolicies, 'production': production};
    final values = {
      ...staging,
      'APP_ENVIRONMENT': 'production',
      'API_BASE_URL': production.apiOrigin,
      'PUBLIC_SITE_URL': production.publicSiteOrigin,
      'API_SESSION_REALM': production.realm,
      'FIREBASE_PROJECT_ID': production.firebaseProject,
      'FIREBASE_SENDER_ID': production.firebaseSender,
      'FIREBASE_ANDROID_APP_ID': '1:999999999:android:test',
      'FIREBASE_IOS_APP_ID': '1:999999999:ios:test'
    };
    validate(values, policies: policies);
    for (final key in [
      'API_BASE_URL',
      'PUBLIC_SITE_URL',
      'API_SESSION_REALM',
      'FIREBASE_PROJECT_ID'
    ]) {
      expect(
          () => validate({...values, key: staging[key]!}, policies: policies),
          throwsFormatException);
    }
    expect(
        () => validate({
              ...staging,
              'APP_ENVIRONMENT': 'production'
            }, policies: {
              ...mobileEnvironmentPolicies,
              'production': mobileEnvironmentPolicies['staging']!
            }),
        throwsFormatException);
  });

  test(
      'native guard validates encoded defines and rejects mismatched provider files',
      () async {
    final directory = Directory.systemTemp.createTempSync('trotxi-build-test-');
    addTearDown(() => directory.deleteSync(recursive: true));
    final app = Directory('${directory.path}/trotxi_commuter');
    final provider = File('${app.path}/config/staging/google-services.json');
    provider.parent.createSync(recursive: true);
    provider.writeAsStringSync(
        File('$root/apps/trotxi_commuter/config/staging/google-services.json')
            .readAsStringSync());
    // Flutter tests execute under flutter_tester, not the standalone Dart VM.
    final flutterRoot = Platform.environment['FLUTTER_ROOT'];
    final dart = flutterRoot == null
        ? 'dart'
        : '$flutterRoot/bin/cache/dart-sdk/bin/dart';
    final definitions = staging.entries
        .map((e) => base64.encode(utf8.encode('${e.key}=${e.value}')))
        .join(',');
    Future<ProcessResult> run(String definitions) => Process.run(
        dart, ['$root/tool/validate_mobile_build.dart', app.path, 'release'],
        environment: {'DART_DEFINES': definitions});
    expect((await run(definitions)).exitCode, 0);
    expect((await run('')).exitCode, 1);
    expect(
        (await run(
                '$definitions,${base64.encode(utf8.encode('APP_ENVIRONMENT=staging'))}'))
            .exitCode,
        1);
    final native =
        jsonDecode(provider.readAsStringSync()) as Map<String, dynamic>;
    native['project_info']['project_id'] = 'wrong';
    provider.writeAsStringSync(jsonEncode(native));
    final failure = await run(definitions);
    expect(failure.exitCode, 1);
    expect('${failure.stdout}${failure.stderr}',
        isNot(contains(staging['FIREBASE_ANDROID_API_KEY'])));
  });

  test(
      'optional telemetry and sensitive request logging cannot return unnoticed',
      () {
    for (final app in ['commuter', 'driver']) {
      final path = '$root/apps/trotxi_$app';
      for (final file in ['pubspec.yaml', 'pubspec.lock']) {
        final contents = File('$path/$file').readAsStringSync();
        for (final sdk in [
          'firebase_analytics',
          'firebase_crashlytics',
          'firebase_performance',
          'firebase_auth',
          'google_mobile_ads',
          'app_tracking_transparency'
        ]) {
          expect(contents, isNot(contains(sdk)),
              reason: '$app must not bundle $sdk');
        }
      }
      final main = File('$path/lib/main.dart').readAsStringSync();
      expect(main, contains('initializeOptionalService'));
      expect(main, contains('MobileBuildConfig.fromEnvironment.validate'));
      expect(main, isNot(contains('ApiDebugInterceptor')));
      expect(File('$path/android/app/build.gradle.kts').readAsStringSync(),
          contains('validate_mobile_build.dart'));
      expect(
          File('$path/ios/Runner.xcodeproj/project.pbxproj').readAsStringSync(),
          contains('validate_mobile_build.dart'));
    }
  });
}
