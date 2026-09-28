import 'package:trotxi_client/trotxi_client.dart';

extension MoneyFormat on Money {
  /// e.g. `GHS 12.50`. The API sends amounts in minor units (pesewas).
  String get formatted =>
      '${currency.name} ${(amountMinor / 100).toStringAsFixed(2)}';
}
