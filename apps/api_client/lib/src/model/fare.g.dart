// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fare.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Fare extends Fare {
  @override
  final Money amount;
  @override
  final DateTime effectiveFrom;
  @override
  final String? note;
  @override
  final String id;
  @override
  final String routeId;
  @override
  final DateTime? effectiveTo;

  factory _$Fare([void Function(FareBuilder)? updates]) =>
      (FareBuilder()..update(updates))._build();

  _$Fare._(
      {required this.amount,
      required this.effectiveFrom,
      this.note,
      required this.id,
      required this.routeId,
      this.effectiveTo})
      : super._();
  @override
  Fare rebuild(void Function(FareBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FareBuilder toBuilder() => FareBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Fare &&
        amount == other.amount &&
        effectiveFrom == other.effectiveFrom &&
        note == other.note &&
        id == other.id &&
        routeId == other.routeId &&
        effectiveTo == other.effectiveTo;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, amount.hashCode);
    _$hash = $jc(_$hash, effectiveFrom.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, routeId.hashCode);
    _$hash = $jc(_$hash, effectiveTo.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Fare')
          ..add('amount', amount)
          ..add('effectiveFrom', effectiveFrom)
          ..add('note', note)
          ..add('id', id)
          ..add('routeId', routeId)
          ..add('effectiveTo', effectiveTo))
        .toString();
  }
}

class FareBuilder implements Builder<Fare, FareBuilder> {
  _$Fare? _$v;

  MoneyBuilder? _amount;
  MoneyBuilder get amount => _$this._amount ??= MoneyBuilder();
  set amount(MoneyBuilder? amount) => _$this._amount = amount;

  DateTime? _effectiveFrom;
  DateTime? get effectiveFrom => _$this._effectiveFrom;
  set effectiveFrom(DateTime? effectiveFrom) =>
      _$this._effectiveFrom = effectiveFrom;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _routeId;
  String? get routeId => _$this._routeId;
  set routeId(String? routeId) => _$this._routeId = routeId;

  DateTime? _effectiveTo;
  DateTime? get effectiveTo => _$this._effectiveTo;
  set effectiveTo(DateTime? effectiveTo) => _$this._effectiveTo = effectiveTo;

  FareBuilder() {
    Fare._defaults(this);
  }

  FareBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _amount = $v.amount.toBuilder();
      _effectiveFrom = $v.effectiveFrom;
      _note = $v.note;
      _id = $v.id;
      _routeId = $v.routeId;
      _effectiveTo = $v.effectiveTo;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Fare other) {
    _$v = other as _$Fare;
  }

  @override
  void update(void Function(FareBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Fare build() => _build();

  _$Fare _build() {
    _$Fare _$result;
    try {
      _$result = _$v ??
          _$Fare._(
            amount: amount.build(),
            effectiveFrom: BuiltValueNullFieldError.checkNotNull(
                effectiveFrom, r'Fare', 'effectiveFrom'),
            note: note,
            id: BuiltValueNullFieldError.checkNotNull(id, r'Fare', 'id'),
            routeId: BuiltValueNullFieldError.checkNotNull(
                routeId, r'Fare', 'routeId'),
            effectiveTo: effectiveTo,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'amount';
        amount.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(r'Fare', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
