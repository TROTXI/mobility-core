// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commute_slot_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CommuteSlotInput extends CommuteSlotInput {
  @override
  final String routeId;
  @override
  final BuiltList<CommuteLeg> legs;
  @override
  final Date availableFrom;

  factory _$CommuteSlotInput(
          [void Function(CommuteSlotInputBuilder)? updates]) =>
      (CommuteSlotInputBuilder()..update(updates))._build();

  _$CommuteSlotInput._(
      {required this.routeId, required this.legs, required this.availableFrom})
      : super._();
  @override
  CommuteSlotInput rebuild(void Function(CommuteSlotInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CommuteSlotInputBuilder toBuilder() =>
      CommuteSlotInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CommuteSlotInput &&
        routeId == other.routeId &&
        legs == other.legs &&
        availableFrom == other.availableFrom;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, routeId.hashCode);
    _$hash = $jc(_$hash, legs.hashCode);
    _$hash = $jc(_$hash, availableFrom.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CommuteSlotInput')
          ..add('routeId', routeId)
          ..add('legs', legs)
          ..add('availableFrom', availableFrom))
        .toString();
  }
}

class CommuteSlotInputBuilder
    implements Builder<CommuteSlotInput, CommuteSlotInputBuilder> {
  _$CommuteSlotInput? _$v;

  String? _routeId;
  String? get routeId => _$this._routeId;
  set routeId(String? routeId) => _$this._routeId = routeId;

  ListBuilder<CommuteLeg>? _legs;
  ListBuilder<CommuteLeg> get legs =>
      _$this._legs ??= ListBuilder<CommuteLeg>();
  set legs(ListBuilder<CommuteLeg>? legs) => _$this._legs = legs;

  Date? _availableFrom;
  Date? get availableFrom => _$this._availableFrom;
  set availableFrom(Date? availableFrom) =>
      _$this._availableFrom = availableFrom;

  CommuteSlotInputBuilder() {
    CommuteSlotInput._defaults(this);
  }

  CommuteSlotInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _routeId = $v.routeId;
      _legs = $v.legs.toBuilder();
      _availableFrom = $v.availableFrom;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CommuteSlotInput other) {
    _$v = other as _$CommuteSlotInput;
  }

  @override
  void update(void Function(CommuteSlotInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CommuteSlotInput build() => _build();

  _$CommuteSlotInput _build() {
    _$CommuteSlotInput _$result;
    try {
      _$result = _$v ??
          _$CommuteSlotInput._(
            routeId: BuiltValueNullFieldError.checkNotNull(
                routeId, r'CommuteSlotInput', 'routeId'),
            legs: legs.build(),
            availableFrom: BuiltValueNullFieldError.checkNotNull(
                availableFrom, r'CommuteSlotInput', 'availableFrom'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'legs';
        legs.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'CommuteSlotInput', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
