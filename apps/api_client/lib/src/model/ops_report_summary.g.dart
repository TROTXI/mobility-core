// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ops_report_summary.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OpsReportSummary extends OpsReportSummary {
  @override
  final DateTime generatedAt;
  @override
  final Date fromDate;
  @override
  final Date toDate;
  @override
  final OpsReportSummaryRiders riders;
  @override
  final OpsReportSummaryTrips trips;
  @override
  final OpsReportSummaryPayments payments;
  @override
  final OpsReportSummaryDelivery delivery;

  factory _$OpsReportSummary(
          [void Function(OpsReportSummaryBuilder)? updates]) =>
      (OpsReportSummaryBuilder()..update(updates))._build();

  _$OpsReportSummary._(
      {required this.generatedAt,
      required this.fromDate,
      required this.toDate,
      required this.riders,
      required this.trips,
      required this.payments,
      required this.delivery})
      : super._();
  @override
  OpsReportSummary rebuild(void Function(OpsReportSummaryBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OpsReportSummaryBuilder toBuilder() =>
      OpsReportSummaryBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OpsReportSummary &&
        generatedAt == other.generatedAt &&
        fromDate == other.fromDate &&
        toDate == other.toDate &&
        riders == other.riders &&
        trips == other.trips &&
        payments == other.payments &&
        delivery == other.delivery;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, generatedAt.hashCode);
    _$hash = $jc(_$hash, fromDate.hashCode);
    _$hash = $jc(_$hash, toDate.hashCode);
    _$hash = $jc(_$hash, riders.hashCode);
    _$hash = $jc(_$hash, trips.hashCode);
    _$hash = $jc(_$hash, payments.hashCode);
    _$hash = $jc(_$hash, delivery.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OpsReportSummary')
          ..add('generatedAt', generatedAt)
          ..add('fromDate', fromDate)
          ..add('toDate', toDate)
          ..add('riders', riders)
          ..add('trips', trips)
          ..add('payments', payments)
          ..add('delivery', delivery))
        .toString();
  }
}

class OpsReportSummaryBuilder
    implements Builder<OpsReportSummary, OpsReportSummaryBuilder> {
  _$OpsReportSummary? _$v;

  DateTime? _generatedAt;
  DateTime? get generatedAt => _$this._generatedAt;
  set generatedAt(DateTime? generatedAt) => _$this._generatedAt = generatedAt;

  Date? _fromDate;
  Date? get fromDate => _$this._fromDate;
  set fromDate(Date? fromDate) => _$this._fromDate = fromDate;

  Date? _toDate;
  Date? get toDate => _$this._toDate;
  set toDate(Date? toDate) => _$this._toDate = toDate;

  OpsReportSummaryRidersBuilder? _riders;
  OpsReportSummaryRidersBuilder get riders =>
      _$this._riders ??= OpsReportSummaryRidersBuilder();
  set riders(OpsReportSummaryRidersBuilder? riders) => _$this._riders = riders;

  OpsReportSummaryTripsBuilder? _trips;
  OpsReportSummaryTripsBuilder get trips =>
      _$this._trips ??= OpsReportSummaryTripsBuilder();
  set trips(OpsReportSummaryTripsBuilder? trips) => _$this._trips = trips;

  OpsReportSummaryPaymentsBuilder? _payments;
  OpsReportSummaryPaymentsBuilder get payments =>
      _$this._payments ??= OpsReportSummaryPaymentsBuilder();
  set payments(OpsReportSummaryPaymentsBuilder? payments) =>
      _$this._payments = payments;

  OpsReportSummaryDeliveryBuilder? _delivery;
  OpsReportSummaryDeliveryBuilder get delivery =>
      _$this._delivery ??= OpsReportSummaryDeliveryBuilder();
  set delivery(OpsReportSummaryDeliveryBuilder? delivery) =>
      _$this._delivery = delivery;

  OpsReportSummaryBuilder() {
    OpsReportSummary._defaults(this);
  }

  OpsReportSummaryBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _generatedAt = $v.generatedAt;
      _fromDate = $v.fromDate;
      _toDate = $v.toDate;
      _riders = $v.riders.toBuilder();
      _trips = $v.trips.toBuilder();
      _payments = $v.payments.toBuilder();
      _delivery = $v.delivery.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OpsReportSummary other) {
    _$v = other as _$OpsReportSummary;
  }

  @override
  void update(void Function(OpsReportSummaryBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OpsReportSummary build() => _build();

  _$OpsReportSummary _build() {
    _$OpsReportSummary _$result;
    try {
      _$result = _$v ??
          _$OpsReportSummary._(
            generatedAt: BuiltValueNullFieldError.checkNotNull(
                generatedAt, r'OpsReportSummary', 'generatedAt'),
            fromDate: BuiltValueNullFieldError.checkNotNull(
                fromDate, r'OpsReportSummary', 'fromDate'),
            toDate: BuiltValueNullFieldError.checkNotNull(
                toDate, r'OpsReportSummary', 'toDate'),
            riders: riders.build(),
            trips: trips.build(),
            payments: payments.build(),
            delivery: delivery.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'riders';
        riders.build();
        _$failedField = 'trips';
        trips.build();
        _$failedField = 'payments';
        payments.build();
        _$failedField = 'delivery';
        delivery.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'OpsReportSummary', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
