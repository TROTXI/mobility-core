// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'standby_offer_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$StandbyOfferInput extends StandbyOfferInput {
  @override
  final DateTime expiresAt;
  @override
  final Date coverageStart;
  @override
  final Date coverageEnd;
  @override
  final Money price;
  @override
  final BuiltList<StandbyOfferInputCreditsInner> credits;
  @override
  final String reason;

  factory _$StandbyOfferInput(
          [void Function(StandbyOfferInputBuilder)? updates]) =>
      (StandbyOfferInputBuilder()..update(updates))._build();

  _$StandbyOfferInput._(
      {required this.expiresAt,
      required this.coverageStart,
      required this.coverageEnd,
      required this.price,
      required this.credits,
      required this.reason})
      : super._();
  @override
  StandbyOfferInput rebuild(void Function(StandbyOfferInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  StandbyOfferInputBuilder toBuilder() =>
      StandbyOfferInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is StandbyOfferInput &&
        expiresAt == other.expiresAt &&
        coverageStart == other.coverageStart &&
        coverageEnd == other.coverageEnd &&
        price == other.price &&
        credits == other.credits &&
        reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, expiresAt.hashCode);
    _$hash = $jc(_$hash, coverageStart.hashCode);
    _$hash = $jc(_$hash, coverageEnd.hashCode);
    _$hash = $jc(_$hash, price.hashCode);
    _$hash = $jc(_$hash, credits.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'StandbyOfferInput')
          ..add('expiresAt', expiresAt)
          ..add('coverageStart', coverageStart)
          ..add('coverageEnd', coverageEnd)
          ..add('price', price)
          ..add('credits', credits)
          ..add('reason', reason))
        .toString();
  }
}

class StandbyOfferInputBuilder
    implements Builder<StandbyOfferInput, StandbyOfferInputBuilder> {
  _$StandbyOfferInput? _$v;

  DateTime? _expiresAt;
  DateTime? get expiresAt => _$this._expiresAt;
  set expiresAt(DateTime? expiresAt) => _$this._expiresAt = expiresAt;

  Date? _coverageStart;
  Date? get coverageStart => _$this._coverageStart;
  set coverageStart(Date? coverageStart) =>
      _$this._coverageStart = coverageStart;

  Date? _coverageEnd;
  Date? get coverageEnd => _$this._coverageEnd;
  set coverageEnd(Date? coverageEnd) => _$this._coverageEnd = coverageEnd;

  MoneyBuilder? _price;
  MoneyBuilder get price => _$this._price ??= MoneyBuilder();
  set price(MoneyBuilder? price) => _$this._price = price;

  ListBuilder<StandbyOfferInputCreditsInner>? _credits;
  ListBuilder<StandbyOfferInputCreditsInner> get credits =>
      _$this._credits ??= ListBuilder<StandbyOfferInputCreditsInner>();
  set credits(ListBuilder<StandbyOfferInputCreditsInner>? credits) =>
      _$this._credits = credits;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  StandbyOfferInputBuilder() {
    StandbyOfferInput._defaults(this);
  }

  StandbyOfferInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _expiresAt = $v.expiresAt;
      _coverageStart = $v.coverageStart;
      _coverageEnd = $v.coverageEnd;
      _price = $v.price.toBuilder();
      _credits = $v.credits.toBuilder();
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(StandbyOfferInput other) {
    _$v = other as _$StandbyOfferInput;
  }

  @override
  void update(void Function(StandbyOfferInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  StandbyOfferInput build() => _build();

  _$StandbyOfferInput _build() {
    _$StandbyOfferInput _$result;
    try {
      _$result = _$v ??
          _$StandbyOfferInput._(
            expiresAt: BuiltValueNullFieldError.checkNotNull(
                expiresAt, r'StandbyOfferInput', 'expiresAt'),
            coverageStart: BuiltValueNullFieldError.checkNotNull(
                coverageStart, r'StandbyOfferInput', 'coverageStart'),
            coverageEnd: BuiltValueNullFieldError.checkNotNull(
                coverageEnd, r'StandbyOfferInput', 'coverageEnd'),
            price: price.build(),
            credits: credits.build(),
            reason: BuiltValueNullFieldError.checkNotNull(
                reason, r'StandbyOfferInput', 'reason'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'price';
        price.build();
        _$failedField = 'credits';
        credits.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'StandbyOfferInput', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
