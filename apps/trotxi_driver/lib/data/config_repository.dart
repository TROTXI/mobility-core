import 'package:trotxi_client/trotxi_client.dart' as wire;
import 'package:trotxi_driver/core/api/driver_api.dart';
import 'package:trotxi_map/trotxi_map.dart';

/// How to reach the control room (#234).
///
/// Every field is nullable and every screen has to cope with that, because the
/// alternative was a number compiled into the build. Depots differ, and a
/// driver at a roadside dialling a line that no longer answers is the failure
/// this exists to prevent — so "we do not have a number" is a state worth
/// rendering honestly rather than papering over.
class OperationsContact {
  const OperationsContact({this.phone, this.whatsapp, this.email, this.hours});

  final String? phone;
  final String? whatsapp;
  final String? email;

  /// Free text, e.g. "05:00-22:00 daily". Shown beside the number so a driver
  /// knows whether anyone will pick up before they stand in the road dialling.
  final String? hours;

  /// Whether there is anything at all to show. False means the operator has not
  /// configured contact details, and the screens hide the controls rather than
  /// offering a dial that goes nowhere.
  bool get hasAny => phone != null || whatsapp != null || email != null;

  /// Whether a call can actually be placed.
  bool get canCall => phone != null && phone!.isNotEmpty;

  static const empty = OperationsContact();
}

/// The client configuration served before sign-in.
class AppConfig {
  const AppConfig({required this.operations, required this.mapStyle});

  final OperationsContact operations;

  /// Where the basemap comes from (#178, #180). Served rather than compiled in
  /// so moving the tile host is a config change instead of three app releases.
  final TrotxiMapStyle mapStyle;

  static const empty = AppConfig(
    operations: OperationsContact.empty,
    mapStyle: TrotxiMapStyle.none,
  );
}

/// Reads `GET /flags`, the one endpoint that answers without a session.
///
/// Public on purpose: the screen that needs the operations number most is
/// "Can't sign in?", which is reached while signed out.
class ConfigRepository {
  ConfigRepository({required this.client});
  final DriverApi client;
  Future<AppConfig> load() async {
    try {
      final config = await client.get('/flags', wire.Bootstrap.serializer);
      for (final app in config.applications) {
        if (app.app.name == 'driver' &&
            app.platform.name == client.metadata.platform &&
            client.metadata.build < app.minSupportedBuild) {
          client.upgradeRequired.value = true;
        }
      }
      return AppConfig(
        operations: OperationsContact(
          phone: _clean(config.operations.phone),
          whatsapp: _clean(config.operations.whatsapp),
          email: _clean(config.operations.email),
          hours: _clean(config.operations.hours),
        ),
        mapStyle: TrotxiMapStyle(
          lightUrl: _clean(config.mapTiles.styleUrl),
          darkUrl: _clean(config.mapTiles.darkStyleUrl),
          attribution: config.mapTiles.attribution,
        ),
      );
    } on TrotxiException {
      return AppConfig.empty;
    }
  }

  static String? _clean(String? value) =>
      value == null || value.trim().isEmpty ? null : value.trim();
}
