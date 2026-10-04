// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fare_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$FareInput extends FareInput {
  @override
  final Money amount;
  @override
  final DateTime effectiveFrom;
  @override
  final String? note;
  @override
  final String? patternVersionId;
  @override
  final String? pickupOccurrenceId;
  @override
  final String? dropoffOccurrenceId;

  factory _$FareInput([void Function(FareInputBuilder)? updates]) =>
      (FareInputBuilder()..update(updates))._build();

  _$FareInput._(
      {required this.amount,
      required this.effectiveFrom,
      this.note,
      this.patternVersionId,
      this.pickupOccurrenceId,
      this.dropoffOccurrenceId})
      : super._();
  @override
  FareInput rebuild(void Function(FareInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FareInputBuilder toBuilder() => FareInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FareInput &&
        amount == other.amount &&
        effectiveFrom == other.effectiveFrom &&
        note == other.note &&
        patternVersionId == other.patternVersionId &&
        pickupOccurrenceId == other.pickupOccurrenceId &&
        dropoffOccurrenceId == other.dropoffOccurrenceId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, amount.hashCode);
    _$hash = $jc(_$hash, effectiveFrom.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, patternVersionId.hashCode);
    _$hash = $jc(_$hash, pickupOccurrenceId.hashCode);
    _$hash = $jc(_$hash, dropoffOccurrenceId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FareInput')
          ..add('amount', amount)
          ..add('effectiveFrom', effectiveFrom)
          ..add('note', note)
          ..add('patternVersionId', patternVersionId)
          ..add('pickupOccurrenceId', pickupOccurrenceId)
          ..add('dropoffOccurrenceId', dropoffOccurrenceId))
        .toString();
  }
}

class FareInputBuilder implements Builder<FareInput, FareInputBuilder> {
  _$FareInput? _$v;

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

  String? _patternVersionId;
  String? get patternVersionId => _$this._patternVersionId;
  set patternVersionId(String? patternVersionId) =>
      _$this._patternVersionId = patternVersionId;

  String? _pickupOccurrenceId;
  String? get pickupOccurrenceId => _$this._pickupOccurrenceId;
  set pickupOccurrenceId(String? pickupOccurrenceId) =>
      _$this._pickupOccurrenceId = pickupOccurrenceId;

  String? _dropoffOccurrenceId;
  String? get dropoffOccurrenceId => _$this._dropoffOccurrenceId;
  set dropoffOccurrenceId(String? dropoffOccurrenceId) =>
      _$this._dropoffOccurrenceId = dropoffOccurrenceId;

  FareInputBuilder() {
    FareInput._defaults(this);
  }

  FareInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _amount = $v.amount.toBuilder();
      _effectiveFrom = $v.effectiveFrom;
      _note = $v.note;
      _patternVersionId = $v.patternVersionId;
      _pickupOccurrenceId = $v.pickupOccurrenceId;
      _dropoffOccurrenceId = $v.dropoffOccurrenceId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FareInput other) {
    _$v = other as _$FareInput;
  }

  @override
  void update(void Function(FareInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FareInput build() => _build();

  _$FareInput _build() {
    _$FareInput _$result;
    try {
      _$result = _$v ??
          _$FareInput._(
            amount: amount.build(),
            effectiveFrom: BuiltValueNullFieldError.checkNotNull(
                effectiveFrom, r'FareInput', 'effectiveFrom'),
            note: note,
            patternVersionId: patternVersionId,
            pickupOccurrenceId: pickupOccurrenceId,
            dropoffOccurrenceId: dropoffOccurrenceId,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'amount';
        amount.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'FareInput', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
