import 'dart:convert';
import 'dart:io';

import '../apps/trotxi_client/lib/mobile_build_config.dart';

/// Native builds pass Flutter's encoded definitions through the environment,
/// never through a command line that might print keys. Manual validation:
/// dart tool/validate_mobile_build.dart <app-directory> <debug|release> <json>
void main(List<String> args) {
  try {
    if (args.length < 2 || args.length > 3) {
      throw const FormatException(
        'Expected app directory, build mode and optional config file.',
      );
    }
    final values = <String, String>{};
    if (args.length == 3) {
      final decoded =
          jsonDecode(File(args[2]).readAsStringSync()) as Map<String, dynamic>;
      for (final entry in decoded.entries) {
        if (entry.value is! String) {
          throw const FormatException('Build settings must be strings.');
        }
        values[entry.key] = entry.value as String;
      }
    } else {
      for (final part in (Platform.environment['DART_DEFINES'] ?? '').split(
        ',',
      )) {
        if (part.isEmpty) continue;
        final pair = utf8.decode(base64.decode(part));
        final separator = pair.indexOf('=');
        if (separator <= 0) {
          throw const FormatException('Invalid encoded build setting.');
        }
        final name = pair.substring(0, separator);
        if (values.containsKey(name)) {
          throw const FormatException('Duplicate build setting.');
        }
        values[name] = pair.substring(separator + 1);
      }
    }
    final config = MobileBuildConfig(values);
    final app = Uri.directory(
      Directory(args[0]).resolveSymbolicLinksSync(),
    ).pathSegments.where((s) => s.isNotEmpty).last;
    if (!{'trotxi_commuter', 'trotxi_driver'}.contains(app)) {
      throw const FormatException('Unknown mobile app.');
    }
    config.validate(release: args[1].toLowerCase() != 'debug', app: app);
    // Android's auto-initialized native app must be identical to Dart's app.
    final providerEnvironment = config.environment == 'local'
        ? 'staging'
        : config.environment;
    final native =
        jsonDecode(
              File(
                '${args[0]}/config/$providerEnvironment/google-services.json',
              ).readAsStringSync(),
            )
            as Map<String, dynamic>;
    final project = native['project_info'] as Map<String, dynamic>;
    if (project['project_id'] != config.firebaseProject ||
        project['project_number'] != values['FIREBASE_SENDER_ID']) {
      throw const FormatException(
        'Native Firebase project does not match build settings.',
      );
    }
    final clients = (native['client'] as List).cast<Map<String, dynamic>>();
    final matches = clients.where(
      (c) =>
          c['client_info']['android_client_info']['package_name'] ==
          'com.trotxi.$app',
    );
    if (matches.length != 1 ||
        matches.single['client_info']['mobilesdk_app_id'] !=
            values['FIREBASE_ANDROID_APP_ID'] ||
        !(matches.single['api_key'] as List).any(
          (key) => key['current_key'] == values['FIREBASE_ANDROID_API_KEY'],
        )) {
      throw const FormatException(
        'Native Firebase application does not match build settings.',
      );
    }
    final expectedBundle = app == 'trotxi_commuter'
        ? 'com.trotxi.trotxiCommuter'
        : 'com.trotxi.trotxiDriver';
    if (values['FIREBASE_IOS_BUNDLE_ID'] != expectedBundle) {
      throw const FormatException(
        'Firebase iOS bundle does not match this application.',
      );
    }
    stdout.writeln('Mobile configuration validated: ${config.environment}.');
  } catch (_) {
    // Do not print the input or exception: provider files can contain keys.
    stderr.writeln(
      'Mobile build blocked: invalid or unapproved environment configuration. See docs/mobile-release-readiness.md.',
    );
    exitCode = 1;
  }
}
