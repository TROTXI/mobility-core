import 'approved_firebase_options.dart';

export 'approved_firebase_options.dart' show MobileFirebaseAppPolicy;

/// Non-secret, reviewed destinations. Production remains locked until its
/// actual API origin, public site, realm and Firebase project are approved.
const mobileEnvironmentPolicies = <String, MobileEnvironmentPolicy>{
  'staging': MobileEnvironmentPolicy(
    apiOrigin: 'https://trotxi-api-staging.onrender.com',
    publicSiteOrigin: 'https://trotxi-ops-staging.onrender.com',
    realm: 'staging-1',
    firebaseProject: 'trotxi-501218',
    firebaseSender: '431341307838',
    firebaseApps: stagingFirebaseApps,
  ),
};

class MobileEnvironmentPolicy {
  const MobileEnvironmentPolicy(
      {required this.apiOrigin,
      required this.publicSiteOrigin,
      required this.realm,
      required this.firebaseProject,
      required this.firebaseSender,
      required this.firebaseApps});
  final String apiOrigin;
  final String publicSiteOrigin;
  final String realm;
  final String firebaseProject;
  final String firebaseSender;
  final Map<String, MobileFirebaseAppPolicy> firebaseApps;
}

/// Shared by the native build guards and startup. No Flutter imports so that
/// Gradle/Xcode can run the same validator before compiling an application.
class MobileBuildConfig {
  const MobileBuildConfig(this.values);

  static const fromEnvironment = MobileBuildConfig({
    'APP_ENVIRONMENT': String.fromEnvironment('APP_ENVIRONMENT'),
    'API_BASE_URL': String.fromEnvironment('API_BASE_URL'),
    'API_SESSION_REALM': String.fromEnvironment('API_SESSION_REALM'),
    'PUBLIC_SITE_URL': String.fromEnvironment('PUBLIC_SITE_URL'),
    'FIREBASE_PROJECT_ID': String.fromEnvironment('FIREBASE_PROJECT_ID'),
    'FIREBASE_SENDER_ID': String.fromEnvironment('FIREBASE_SENDER_ID'),
    'FIREBASE_ANDROID_APP_ID':
        String.fromEnvironment('FIREBASE_ANDROID_APP_ID'),
    'FIREBASE_ANDROID_API_KEY':
        String.fromEnvironment('FIREBASE_ANDROID_API_KEY'),
    'FIREBASE_IOS_APP_ID': String.fromEnvironment('FIREBASE_IOS_APP_ID'),
    'FIREBASE_IOS_API_KEY': String.fromEnvironment('FIREBASE_IOS_API_KEY'),
    'FIREBASE_IOS_BUNDLE_ID': String.fromEnvironment('FIREBASE_IOS_BUNDLE_ID'),
  });

  final Map<String, String> values;
  String get environment => values['APP_ENVIRONMENT'] ?? '';
  String get apiBaseUrl => values['API_BASE_URL'] ?? '';
  String get realm => values['API_SESSION_REALM'] ?? '';
  String get firebaseProject => values['FIREBASE_PROJECT_ID'] ?? '';
  String require(String key) {
    final value = values[key] ?? '';
    if (value.isEmpty || value.trim() != value) {
      throw FormatException('Missing or invalid $key.');
    }
    return value;
  }

  void validate(
      {required bool release,
      required String app,
      Map<String, MobileEnvironmentPolicy> policies =
          mobileEnvironmentPolicies}) {
    if (!{'local', 'staging', 'production'}.contains(environment)) {
      throw const FormatException(
          'Select APP_ENVIRONMENT: local, staging or production.');
    }
    final api = _origin(require('API_BASE_URL'));
    final site = _origin(require('PUBLIC_SITE_URL'));
    require('API_SESSION_REALM');
    require('FIREBASE_PROJECT_ID');
    final sender = require('FIREBASE_SENDER_ID');
    if (!RegExp(r'^\d+$').hasMatch(sender)) {
      throw const FormatException('Invalid Firebase sender.');
    }
    for (final platform in ['ANDROID', 'IOS']) {
      final appId = require('FIREBASE_${platform}_APP_ID');
      if (!appId.startsWith('1:$sender:${platform.toLowerCase()}:') ||
          appId.split(':').length != 4 ||
          appId.split(':').last.isEmpty) {
        throw const FormatException(
            'Firebase application and sender do not match.');
      }
      require('FIREBASE_${platform}_API_KEY');
    }
    require('FIREBASE_IOS_BUNDLE_ID');
    final providerPolicy =
        policies[environment == 'local' ? 'staging' : environment];
    final appPolicy = providerPolicy?.firebaseApps[app];
    if (appPolicy == null ||
        values['FIREBASE_IOS_BUNDLE_ID'] != appPolicy.iosBundleId ||
        values['FIREBASE_IOS_APP_ID'] != appPolicy.iosAppId ||
        values['FIREBASE_IOS_API_KEY'] != appPolicy.iosApiKey) {
      throw const FormatException(
          'Firebase iOS configuration does not match the approved application.');
    }
    if (environment == 'local') {
      if (release ||
          !{'localhost', '127.0.0.1', '10.0.2.2', '::1'}.contains(api.host) ||
          !realm.startsWith('local-') ||
          firebaseProject != policies['staging']?.firebaseProject ||
          sender != policies['staging']?.firebaseSender) {
        throw const FormatException(
            'Local builds require debug mode, a loopback API, a local realm and staging Firebase.');
      }
      if (site.scheme != 'https' &&
          !{'localhost', '127.0.0.1', '10.0.2.2', '::1'}.contains(site.host)) {
        throw const FormatException(
            'Local public site must use HTTPS or loopback.');
      }
      return;
    }
    final policy = policies[environment];
    if (policy == null) {
      throw const FormatException(
          'This environment has no approved mobile release configuration.');
    }
    if (api.scheme != 'https' ||
        site.scheme != 'https' ||
        api.origin != policy.apiOrigin ||
        site.origin != policy.publicSiteOrigin ||
        realm != policy.realm ||
        firebaseProject != policy.firebaseProject ||
        sender != policy.firebaseSender) {
      throw const FormatException(
          'Build configuration does not match the approved environment.');
    }
    if (environment == 'production') {
      final staging = policies['staging'];
      if (staging == null ||
          policy.apiOrigin == staging.apiOrigin ||
          policy.firebaseProject == staging.firebaseProject ||
          policy.firebaseSender == staging.firebaseSender ||
          policy.realm == staging.realm ||
          policy.publicSiteOrigin == staging.publicSiteOrigin) {
        throw const FormatException(
            'Production must be isolated from staging.');
      }
    }
  }

  static Uri _origin(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null ||
        !{'http', 'https'}.contains(uri.scheme) ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment ||
        (uri.path.isNotEmpty && uri.path != '/')) {
      throw const FormatException(
          'Use a bare API/public-site origin, without credentials, paths or queries.');
    }
    return uri;
  }
}
