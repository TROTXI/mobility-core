// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ops_report_summary_trips.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OpsReportSummaryTrips extends OpsReportSummaryTrips {
  @override
  final int total;
  @override
  final int completed;
  @override
  final int cancelled;
  @override
  final int boarded;
  @override
  final int noShows;

  factory _$OpsReportSummaryTrips(
          [void Function(OpsReportSummaryTripsBuilder)? updates]) =>
      (OpsReportSummaryTripsBuilder()..update(updates))._build();

  _$OpsReportSummaryTrips._(
      {required this.total,
      required this.completed,
      required this.cancelled,
      required this.boarded,
      required this.noShows})
      : super._();
  @override
  OpsReportSummaryTrips rebuild(
          void Function(OpsReportSummaryTripsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OpsReportSummaryTripsBuilder toBuilder() =>
      OpsReportSummaryTripsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OpsReportSummaryTrips &&
        total == other.total &&
        completed == other.completed &&
        cancelled == other.cancelled &&
        boarded == other.boarded &&
        noShows == other.noShows;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, total.hashCode);
    _$hash = $jc(_$hash, completed.hashCode);
    _$hash = $jc(_$hash, cancelled.hashCode);
    _$hash = $jc(_$hash, boarded.hashCode);
    _$hash = $jc(_$hash, noShows.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OpsReportSummaryTrips')
          ..add('total', total)
          ..add('completed', completed)
          ..add('cancelled', cancelled)
          ..add('boarded', boarded)
          ..add('noShows', noShows))
        .toString();
  }
}

class OpsReportSummaryTripsBuilder
    implements Builder<OpsReportSummaryTrips, OpsReportSummaryTripsBuilder> {
  _$OpsReportSummaryTrips? _$v;

  int? _total;
  int? get total => _$this._total;
  set total(int? total) => _$this._total = total;

  int? _completed;
  int? get completed => _$this._completed;
  set completed(int? completed) => _$this._completed = completed;

  int? _cancelled;
  int? get cancelled => _$this._cancelled;
  set cancelled(int? cancelled) => _$this._cancelled = cancelled;

  int? _boarded;
  int? get boarded => _$this._boarded;
  set boarded(int? boarded) => _$this._boarded = boarded;

  int? _noShows;
  int? get noShows => _$this._noShows;
  set noShows(int? noShows) => _$this._noShows = noShows;

  OpsReportSummaryTripsBuilder() {
    OpsReportSummaryTrips._defaults(this);
  }

  OpsReportSummaryTripsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _total = $v.total;
      _completed = $v.completed;
      _cancelled = $v.cancelled;
      _boarded = $v.boarded;
      _noShows = $v.noShows;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OpsReportSummaryTrips other) {
    _$v = other as _$OpsReportSummaryTrips;
  }

  @override
  void update(void Function(OpsReportSummaryTripsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OpsReportSummaryTrips build() => _build();

  _$OpsReportSummaryTrips _build() {
    final _$result = _$v ??
        _$OpsReportSummaryTrips._(
          total: BuiltValueNullFieldError.checkNotNull(
              total, r'OpsReportSummaryTrips', 'total'),
          completed: BuiltValueNullFieldError.checkNotNull(
              completed, r'OpsReportSummaryTrips', 'completed'),
          cancelled: BuiltValueNullFieldError.checkNotNull(
              cancelled, r'OpsReportSummaryTrips', 'cancelled'),
          boarded: BuiltValueNullFieldError.checkNotNull(
              boarded, r'OpsReportSummaryTrips', 'boarded'),
          noShows: BuiltValueNullFieldError.checkNotNull(
              noShows, r'OpsReportSummaryTrips', 'noShows'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
