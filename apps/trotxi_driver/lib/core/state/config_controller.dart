import 'package:flutter/foundation.dart';
import 'foreground_refresh.dart';
import 'package:trotxi_driver/data/config_repository.dart';
import 'package:trotxi_map/trotxi_map.dart';

/// Client configuration, held for the life of the app.
///
/// Loaded once at start rather than per screen: `GET /flags` answers before
/// sign-in, three screens need the operations number, and a driver reaching for
/// support is not the moment to make a network call they have to wait on.
///
/// A failed read preserves the last known configuration and is retryable.
class ConfigController extends ChangeNotifier {
  ConfigController({required this._config});

  final ConfigRepository _config;

  AppConfig _value = AppConfig.empty;
  AppConfig get value => _value;

  bool _loaded = false;
  bool _busy = false;
  bool _disposed = false;
  String? error;
  ForegroundRefresh? _retry;

  void startRecovery() {
    _retry ??= ForegroundRefresh(() async {
      if (error != null) await load();
    }, interval: const Duration(seconds: 30));
  }

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
    if (_busy || _disposed) return;
    _busy = true;
    try {
      if (!_loaded) {
        try {
          final cached = await _config.cached();
          if (cached != null && !_disposed) _value = cached;
        } catch (_) {
          /* An unreadable cache is never authoritative. */
        }
      }
      final next = await _config.load();
      if (!_disposed) {
        _value = next;
        error = null;
      }
    } catch (_) {
      if (!_disposed) {
        error =
            'Map and support settings could not refresh. Check your connection and retry.';
      }
    } finally {
      _busy = false;
      if (!_disposed) {
        _loaded = true;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _retry?.dispose();
    super.dispose();
  }
}
