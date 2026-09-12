import 'package:flutter/foundation.dart';
import 'package:trotxi_driver/data/config_repository.dart';
import 'package:trotxi_map/trotxi_map.dart';

/// Client configuration, held for the life of the app.
///
/// Loaded once at start rather than per screen: `GET /flags` answers before
/// sign-in, three screens need the operations number, and a driver reaching for
/// support is not the moment to make a network call they have to wait on.
///
/// There is no error state. A config that will not load leaves
/// [AppConfig.empty], and the screens hide their contact controls — which is
/// the same thing an operator who has not set a number means. Showing a driver
/// "could not load configuration" would be true and useless.
class ConfigController extends ChangeNotifier {
  ConfigController({required this._config});

  final ConfigRepository _config;

  AppConfig _value = AppConfig.empty;
  AppConfig get value => _value;

  bool _loaded = false;

  /// Whether the first fetch has finished, successfully or not. Screens use it
  /// to tell "we have not asked yet" from "we asked and there is no number",
  /// which read very differently on a recovery screen.
  bool get isLoaded => _loaded;

  OperationsContact get operations => _value.operations;

  /// The basemap style, or [TrotxiMapStyle.none] when the operator has not
  /// configured one — in which case map surfaces draw blank and the screens
  /// around them keep working.
  TrotxiMapStyle get mapStyle => _value.mapStyle;

  /// Fetch the configuration. Safe to call again — a driver pulling to refresh
  /// the support screen after operations set a number should get it.
  Future<void> load() async {
    _value = await _config.load();
    _loaded = true;
    notifyListeners();
  }
}
