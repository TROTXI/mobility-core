// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_maintenance_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PaymentMaintenanceResult extends PaymentMaintenanceResult {
  @override
  final MaintenanceResult inbox;
  @override
  final MaintenanceResult reconciliation;
  @override
  final MaintenanceResult periods;

  factory _$PaymentMaintenanceResult(
          [void Function(PaymentMaintenanceResultBuilder)? updates]) =>
      (PaymentMaintenanceResultBuilder()..update(updates))._build();

  _$PaymentMaintenanceResult._(
      {required this.inbox,
      required this.reconciliation,
      required this.periods})
      : super._();
  @override
  PaymentMaintenanceResult rebuild(
          void Function(PaymentMaintenanceResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PaymentMaintenanceResultBuilder toBuilder() =>
      PaymentMaintenanceResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PaymentMaintenanceResult &&
        inbox == other.inbox &&
        reconciliation == other.reconciliation &&
        periods == other.periods;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, inbox.hashCode);
    _$hash = $jc(_$hash, reconciliation.hashCode);
    _$hash = $jc(_$hash, periods.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PaymentMaintenanceResult')
          ..add('inbox', inbox)
          ..add('reconciliation', reconciliation)
          ..add('periods', periods))
        .toString();
  }
}

class PaymentMaintenanceResultBuilder
    implements
        Builder<PaymentMaintenanceResult, PaymentMaintenanceResultBuilder> {
  _$PaymentMaintenanceResult? _$v;

  MaintenanceResultBuilder? _inbox;
  MaintenanceResultBuilder get inbox =>
      _$this._inbox ??= MaintenanceResultBuilder();
  set inbox(MaintenanceResultBuilder? inbox) => _$this._inbox = inbox;

  MaintenanceResultBuilder? _reconciliation;
  MaintenanceResultBuilder get reconciliation =>
      _$this._reconciliation ??= MaintenanceResultBuilder();
  set reconciliation(MaintenanceResultBuilder? reconciliation) =>
      _$this._reconciliation = reconciliation;

  MaintenanceResultBuilder? _periods;
  MaintenanceResultBuilder get periods =>
      _$this._periods ??= MaintenanceResultBuilder();
  set periods(MaintenanceResultBuilder? periods) => _$this._periods = periods;

  PaymentMaintenanceResultBuilder() {
    PaymentMaintenanceResult._defaults(this);
  }

  PaymentMaintenanceResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _inbox = $v.inbox.toBuilder();
      _reconciliation = $v.reconciliation.toBuilder();
      _periods = $v.periods.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PaymentMaintenanceResult other) {
    _$v = other as _$PaymentMaintenanceResult;
  }

  @override
  void update(void Function(PaymentMaintenanceResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PaymentMaintenanceResult build() => _build();

  _$PaymentMaintenanceResult _build() {
    _$PaymentMaintenanceResult _$result;
    try {
      _$result = _$v ??
          _$PaymentMaintenanceResult._(
            inbox: inbox.build(),
            reconciliation: reconciliation.build(),
            periods: periods.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'inbox';
        inbox.build();
        _$failedField = 'reconciliation';
        reconciliation.build();
        _$failedField = 'periods';
        periods.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PaymentMaintenanceResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
