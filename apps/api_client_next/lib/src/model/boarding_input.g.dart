// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'boarding_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const BoardingInputKindEnum _$boardingInputKindEnum_photo =
    const BoardingInputKindEnum._('photo');

BoardingInputKindEnum _$boardingInputKindEnumValueOf(String name) {
  switch (name) {
    case 'photo':
      return _$boardingInputKindEnum_photo;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<BoardingInputKindEnum> _$boardingInputKindEnumValues =
    BuiltSet<BoardingInputKindEnum>(const <BoardingInputKindEnum>[
  _$boardingInputKindEnum_photo,
]);

Serializer<BoardingInputKindEnum> _$boardingInputKindEnumSerializer =
    _$BoardingInputKindEnumSerializer();

class _$BoardingInputKindEnumSerializer
    implements PrimitiveSerializer<BoardingInputKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'photo': 'photo',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'photo': 'photo',
  };

  @override
  final Iterable<Type> types = const <Type>[BoardingInputKindEnum];
  @override
  final String wireName = 'BoardingInputKindEnum';

  @override
  Object serialize(Serializers serializers, BoardingInputKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  BoardingInputKindEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      BoardingInputKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$BoardingInput extends BoardingInput {
  @override
  final OneOf oneOf;

  factory _$BoardingInput([void Function(BoardingInputBuilder)? updates]) =>
      (BoardingInputBuilder()..update(updates))._build();

  _$BoardingInput._({required this.oneOf}) : super._();
  @override
  BoardingInput rebuild(void Function(BoardingInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BoardingInputBuilder toBuilder() => BoardingInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BoardingInput && oneOf == other.oneOf;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, oneOf.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BoardingInput')..add('oneOf', oneOf))
        .toString();
  }
}

class BoardingInputBuilder
    implements Builder<BoardingInput, BoardingInputBuilder> {
  _$BoardingInput? _$v;

  OneOf? _oneOf;
  OneOf? get oneOf => _$this._oneOf;
  set oneOf(OneOf? oneOf) => _$this._oneOf = oneOf;

  BoardingInputBuilder() {
    BoardingInput._defaults(this);
  }

  BoardingInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _oneOf = $v.oneOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BoardingInput other) {
    _$v = other as _$BoardingInput;
  }

  @override
  void update(void Function(BoardingInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BoardingInput build() => _build();

  _$BoardingInput _build() {
    final _$result = _$v ??
        _$BoardingInput._(
          oneOf: BuiltValueNullFieldError.checkNotNull(
              oneOf, r'BoardingInput', 'oneOf'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
