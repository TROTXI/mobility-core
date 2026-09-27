// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ops_report_summary_riders.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OpsReportSummaryRiders extends OpsReportSummaryRiders {
  @override
  final int total;
  @override
  final int active;
  @override
  final int paused;
  @override
  final int restricted;

  factory _$OpsReportSummaryRiders(
          [void Function(OpsReportSummaryRidersBuilder)? updates]) =>
      (OpsReportSummaryRidersBuilder()..update(updates))._build();

  _$OpsReportSummaryRiders._(
      {required this.total,
      required this.active,
      required this.paused,
      required this.restricted})
      : super._();
  @override
  OpsReportSummaryRiders rebuild(
          void Function(OpsReportSummaryRidersBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OpsReportSummaryRidersBuilder toBuilder() =>
      OpsReportSummaryRidersBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OpsReportSummaryRiders &&
        total == other.total &&
        active == other.active &&
        paused == other.paused &&
        restricted == other.restricted;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, total.hashCode);
    _$hash = $jc(_$hash, active.hashCode);
    _$hash = $jc(_$hash, paused.hashCode);
    _$hash = $jc(_$hash, restricted.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OpsReportSummaryRiders')
          ..add('total', total)
          ..add('active', active)
          ..add('paused', paused)
          ..add('restricted', restricted))
        .toString();
  }
}

class OpsReportSummaryRidersBuilder
    implements Builder<OpsReportSummaryRiders, OpsReportSummaryRidersBuilder> {
  _$OpsReportSummaryRiders? _$v;

  int? _total;
  int? get total => _$this._total;
  set total(int? total) => _$this._total = total;

  int? _active;
  int? get active => _$this._active;
  set active(int? active) => _$this._active = active;

  int? _paused;
  int? get paused => _$this._paused;
  set paused(int? paused) => _$this._paused = paused;

  int? _restricted;
  int? get restricted => _$this._restricted;
  set restricted(int? restricted) => _$this._restricted = restricted;

  OpsReportSummaryRidersBuilder() {
    OpsReportSummaryRiders._defaults(this);
  }

  OpsReportSummaryRidersBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _total = $v.total;
      _active = $v.active;
      _paused = $v.paused;
      _restricted = $v.restricted;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OpsReportSummaryRiders other) {
    _$v = other as _$OpsReportSummaryRiders;
  }

  @override
  void update(void Function(OpsReportSummaryRidersBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OpsReportSummaryRiders build() => _build();

  _$OpsReportSummaryRiders _build() {
    final _$result = _$v ??
        _$OpsReportSummaryRiders._(
          total: BuiltValueNullFieldError.checkNotNull(
              total, r'OpsReportSummaryRiders', 'total'),
          active: BuiltValueNullFieldError.checkNotNull(
              active, r'OpsReportSummaryRiders', 'active'),
          paused: BuiltValueNullFieldError.checkNotNull(
              paused, r'OpsReportSummaryRiders', 'paused'),
          restricted: BuiltValueNullFieldError.checkNotNull(
              restricted, r'OpsReportSummaryRiders', 'restricted'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
