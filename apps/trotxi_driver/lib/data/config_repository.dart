import 'package:dio/dio.dart';
import 'package:trotxi_client/trotxi_client.dart';

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
  const AppConfig({required this.operations});

  final OperationsContact operations;

  static const empty = AppConfig(operations: OperationsContact.empty);
}

/// Reads `GET /flags`, the one endpoint that answers without a session.
///
/// Public on purpose: the screen that needs the operations number most is
/// "Can't sign in?", which is reached while signed out.
class ConfigRepository {
  ConfigRepository({required this._client});

  final TrotxiApiClient _client;

  /// Fetch the client configuration.
  ///
  /// @returns the configuration, or [AppConfig.empty] when it cannot be read.
  ///   Never throws: a driver who cannot reach the network still has to be able
  ///   to open the sign-in screen, and an empty config degrades to hiding the
  ///   contact controls rather than failing the page.
  Future<AppConfig> load() async {
    try {
      final response = await _client.getFlagsApi().flagsGet();
      final ops = response.data?.operations;
      return AppConfig(
        operations: OperationsContact(
          phone: _clean(ops?.phone),
          whatsapp: _clean(ops?.whatsapp),
          email: _clean(ops?.email),
          hours: _clean(ops?.hours),
        ),
      );
    } on DioException {
      return AppConfig.empty;
    }
  }

  /// Treat an empty string as absent — an operator who cleared a field in the
  /// dashboard means the same thing as one who never set it.
  ///
  /// @param value - the raw field.
  /// @returns the value, or null when there is nothing usable in it.
  static String? _clean(String? value) {
    final trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }
}
