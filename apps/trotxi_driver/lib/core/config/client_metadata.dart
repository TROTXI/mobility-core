import 'package:trotxi_client/trotxi_client.dart';

/// Build number sent as `X-Trotxi-Build`. Keep in step with the `+N` in
/// pubspec.yaml's `version`: the API answers 426 to unsupported builds.
const int _buildNumber = 1;

/// Client metadata the driver app sends on every `/v1` call.
final TrotxiClientMetadata driverMetadata =
    TrotxiClientMetadata.forCurrentPlatform(
      client: 'driver',
      build: _buildNumber,
    );
