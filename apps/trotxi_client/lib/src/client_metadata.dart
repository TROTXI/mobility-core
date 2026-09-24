import 'package:flutter/foundation.dart';

/// The `X-Trotxi-Client`, `X-Trotxi-Build` and `X-Trotxi-Platform` headers
/// every `/v1` call carries.
///
/// The API treats these as compatibility metadata only — they never grant a
/// role. Missing metadata is a 400 and an unsupported build is a 426, so an
/// app builds one of these once at startup and passes it to every call.
@immutable
class TrotxiClientMetadata {
  const TrotxiClientMetadata({
    required this.client,
    required this.build,
    this.platform,
  });

  /// Resolves [platform] from the handset the app is running on.
  ///
  /// The API only knows `ios` and `android`, and wants the header absent
  /// rather than invented anywhere else (desktop, web, tests), so anything
  /// else resolves to null.
  factory TrotxiClientMetadata.forCurrentPlatform({
    required String client,
    required int build,
  }) {
    String? platform;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      platform = 'ios';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      platform = 'android';
    }
    return TrotxiClientMetadata(
      client: client,
      build: build,
      platform: platform,
    );
  }

  /// `commuter`, `driver`, `ops` or `worker`.
  final String client;

  /// Build number; keep in step with the `+N` in the app's pubspec version.
  final int build;

  /// `ios` or `android`; null off a handset, where the API wants it absent.
  final String? platform;
}
