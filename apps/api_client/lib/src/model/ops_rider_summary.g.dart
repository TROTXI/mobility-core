// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ops_rider_summary.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OpsRiderSummary extends OpsRiderSummary {
  @override
  final DateTime generatedAt;
  @override
  final int active;
  @override
  final int paused;
  @override
  final int lapsed;
  @override
  final int monthly;
  @override
  final int annual;
  @override
  final Money creditOutstanding;
  @override
  final num? averageRidesUsed;

  factory _$OpsRiderSummary([void Function(OpsRiderSummaryBuilder)? updates]) =>
      (OpsRiderSummaryBuilder()..update(updates))._build();

  _$OpsRiderSummary._(
      {required this.generatedAt,
      required this.active,
      required this.paused,
      required this.lapsed,
      required this.monthly,
      required this.annual,
      required this.creditOutstanding,
      this.averageRidesUsed})
      : super._();
  @override
  OpsRiderSummary rebuild(void Function(OpsRiderSummaryBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OpsRiderSummaryBuilder toBuilder() => OpsRiderSummaryBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OpsRiderSummary &&
        generatedAt == other.generatedAt &&
        active == other.active &&
        paused == other.paused &&
        lapsed == other.lapsed &&
        monthly == other.monthly &&
        annual == other.annual &&
        creditOutstanding == other.creditOutstanding &&
        averageRidesUsed == other.averageRidesUsed;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, generatedAt.hashCode);
    _$hash = $jc(_$hash, active.hashCode);
    _$hash = $jc(_$hash, paused.hashCode);
    _$hash = $jc(_$hash, lapsed.hashCode);
    _$hash = $jc(_$hash, monthly.hashCode);
    _$hash = $jc(_$hash, annual.hashCode);
    _$hash = $jc(_$hash, creditOutstanding.hashCode);
    _$hash = $jc(_$hash, averageRidesUsed.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OpsRiderSummary')
          ..add('generatedAt', generatedAt)
          ..add('active', active)
          ..add('paused', paused)
          ..add('lapsed', lapsed)
          ..add('monthly', monthly)
          ..add('annual', annual)
          ..add('creditOutstanding', creditOutstanding)
          ..add('averageRidesUsed', averageRidesUsed))
        .toString();
  }
}

class OpsRiderSummaryBuilder
    implements Builder<OpsRiderSummary, OpsRiderSummaryBuilder> {
  _$OpsRiderSummary? _$v;

  DateTime? _generatedAt;
  DateTime? get generatedAt => _$this._generatedAt;
  set generatedAt(DateTime? generatedAt) => _$this._generatedAt = generatedAt;

  int? _active;
  int? get active => _$this._active;
  set active(int? active) => _$this._active = active;

  int? _paused;
  int? get paused => _$this._paused;
  set paused(int? paused) => _$this._paused = paused;

  int? _lapsed;
  int? get lapsed => _$this._lapsed;
  set lapsed(int? lapsed) => _$this._lapsed = lapsed;

  int? _monthly;
  int? get monthly => _$this._monthly;
  set monthly(int? monthly) => _$this._monthly = monthly;

  int? _annual;
  int? get annual => _$this._annual;
  set annual(int? annual) => _$this._annual = annual;

  MoneyBuilder? _creditOutstanding;
  MoneyBuilder get creditOutstanding =>
      _$this._creditOutstanding ??= MoneyBuilder();
  set creditOutstanding(MoneyBuilder? creditOutstanding) =>
      _$this._creditOutstanding = creditOutstanding;

  num? _averageRidesUsed;
  num? get averageRidesUsed => _$this._averageRidesUsed;
  set averageRidesUsed(num? averageRidesUsed) =>
      _$this._averageRidesUsed = averageRidesUsed;

  OpsRiderSummaryBuilder() {
    OpsRiderSummary._defaults(this);
  }

  OpsRiderSummaryBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _generatedAt = $v.generatedAt;
      _active = $v.active;
      _paused = $v.paused;
      _lapsed = $v.lapsed;
      _monthly = $v.monthly;
      _annual = $v.annual;
      _creditOutstanding = $v.creditOutstanding.toBuilder();
      _averageRidesUsed = $v.averageRidesUsed;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OpsRiderSummary other) {
    _$v = other as _$OpsRiderSummary;
  }

  @override
  void update(void Function(OpsRiderSummaryBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OpsRiderSummary build() => _build();

  _$OpsRiderSummary _build() {
    _$OpsRiderSummary _$result;
    try {
      _$result = _$v ??
          _$OpsRiderSummary._(
            generatedAt: BuiltValueNullFieldError.checkNotNull(
                generatedAt, r'OpsRiderSummary', 'generatedAt'),
            active: BuiltValueNullFieldError.checkNotNull(
                active, r'OpsRiderSummary', 'active'),
            paused: BuiltValueNullFieldError.checkNotNull(
                paused, r'OpsRiderSummary', 'paused'),
            lapsed: BuiltValueNullFieldError.checkNotNull(
                lapsed, r'OpsRiderSummary', 'lapsed'),
            monthly: BuiltValueNullFieldError.checkNotNull(
                monthly, r'OpsRiderSummary', 'monthly'),
            annual: BuiltValueNullFieldError.checkNotNull(
                annual, r'OpsRiderSummary', 'annual'),
            creditOutstanding: creditOutstanding.build(),
            averageRidesUsed: averageRidesUsed,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'creditOutstanding';
        creditOutstanding.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'OpsRiderSummary', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
