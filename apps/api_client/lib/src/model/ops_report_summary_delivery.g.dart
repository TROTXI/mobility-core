// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ops_report_summary_delivery.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OpsReportSummaryDelivery extends OpsReportSummaryDelivery {
  @override
  final int pending;
  @override
  final int failed;

  factory _$OpsReportSummaryDelivery(
          [void Function(OpsReportSummaryDeliveryBuilder)? updates]) =>
      (OpsReportSummaryDeliveryBuilder()..update(updates))._build();

  _$OpsReportSummaryDelivery._({required this.pending, required this.failed})
      : super._();
  @override
  OpsReportSummaryDelivery rebuild(
          void Function(OpsReportSummaryDeliveryBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OpsReportSummaryDeliveryBuilder toBuilder() =>
      OpsReportSummaryDeliveryBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OpsReportSummaryDelivery &&
        pending == other.pending &&
        failed == other.failed;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, pending.hashCode);
    _$hash = $jc(_$hash, failed.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OpsReportSummaryDelivery')
          ..add('pending', pending)
          ..add('failed', failed))
        .toString();
  }
}

class OpsReportSummaryDeliveryBuilder
    implements
        Builder<OpsReportSummaryDelivery, OpsReportSummaryDeliveryBuilder> {
  _$OpsReportSummaryDelivery? _$v;

  int? _pending;
  int? get pending => _$this._pending;
  set pending(int? pending) => _$this._pending = pending;

  int? _failed;
  int? get failed => _$this._failed;
  set failed(int? failed) => _$this._failed = failed;

  OpsReportSummaryDeliveryBuilder() {
    OpsReportSummaryDelivery._defaults(this);
  }

  OpsReportSummaryDeliveryBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _pending = $v.pending;
      _failed = $v.failed;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OpsReportSummaryDelivery other) {
    _$v = other as _$OpsReportSummaryDelivery;
  }

  @override
  void update(void Function(OpsReportSummaryDeliveryBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OpsReportSummaryDelivery build() => _build();

  _$OpsReportSummaryDelivery _build() {
    final _$result = _$v ??
        _$OpsReportSummaryDelivery._(
          pending: BuiltValueNullFieldError.checkNotNull(
              pending, r'OpsReportSummaryDelivery', 'pending'),
          failed: BuiltValueNullFieldError.checkNotNull(
              failed, r'OpsReportSummaryDelivery', 'failed'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
