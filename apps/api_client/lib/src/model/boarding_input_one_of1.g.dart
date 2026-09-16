// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'boarding_input_one_of1.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const BoardingInputOneOf1KindEnum _$boardingInputOneOf1KindEnum_code =
    const BoardingInputOneOf1KindEnum._('code');

BoardingInputOneOf1KindEnum _$boardingInputOneOf1KindEnumValueOf(String name) {
  switch (name) {
    case 'code':
      return _$boardingInputOneOf1KindEnum_code;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<BoardingInputOneOf1KindEnum>
    _$boardingInputOneOf1KindEnumValues =
    BuiltSet<BoardingInputOneOf1KindEnum>(const <BoardingInputOneOf1KindEnum>[
  _$boardingInputOneOf1KindEnum_code,
]);

Serializer<BoardingInputOneOf1KindEnum>
    _$boardingInputOneOf1KindEnumSerializer =
    _$BoardingInputOneOf1KindEnumSerializer();

class _$BoardingInputOneOf1KindEnumSerializer
    implements PrimitiveSerializer<BoardingInputOneOf1KindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'code': 'code',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'code': 'code',
  };

  @override
  final Iterable<Type> types = const <Type>[BoardingInputOneOf1KindEnum];
  @override
  final String wireName = 'BoardingInputOneOf1KindEnum';

  @override
  Object serialize(Serializers serializers, BoardingInputOneOf1KindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  BoardingInputOneOf1KindEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      BoardingInputOneOf1KindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$BoardingInputOneOf1 extends BoardingInputOneOf1 {
  @override
  final BoardingInputOneOf1KindEnum kind;
  @override
  final String code;

  factory _$BoardingInputOneOf1(
          [void Function(BoardingInputOneOf1Builder)? updates]) =>
      (BoardingInputOneOf1Builder()..update(updates))._build();

  _$BoardingInputOneOf1._({required this.kind, required this.code}) : super._();
  @override
  BoardingInputOneOf1 rebuild(
          void Function(BoardingInputOneOf1Builder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BoardingInputOneOf1Builder toBuilder() =>
      BoardingInputOneOf1Builder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BoardingInputOneOf1 &&
        kind == other.kind &&
        code == other.code;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BoardingInputOneOf1')
          ..add('kind', kind)
          ..add('code', code))
        .toString();
  }
}

class BoardingInputOneOf1Builder
    implements Builder<BoardingInputOneOf1, BoardingInputOneOf1Builder> {
  _$BoardingInputOneOf1? _$v;

  BoardingInputOneOf1KindEnum? _kind;
  BoardingInputOneOf1KindEnum? get kind => _$this._kind;
  set kind(BoardingInputOneOf1KindEnum? kind) => _$this._kind = kind;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  BoardingInputOneOf1Builder() {
    BoardingInputOneOf1._defaults(this);
  }

  BoardingInputOneOf1Builder get _$this {
    final $v = _$v;
    if ($v != null) {
      _kind = $v.kind;
      _code = $v.code;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BoardingInputOneOf1 other) {
    _$v = other as _$BoardingInputOneOf1;
  }

  @override
  void update(void Function(BoardingInputOneOf1Builder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BoardingInputOneOf1 build() => _build();

  _$BoardingInputOneOf1 _build() {
    final _$result = _$v ??
        _$BoardingInputOneOf1._(
          kind: BuiltValueNullFieldError.checkNotNull(
              kind, r'BoardingInputOneOf1', 'kind'),
          code: BuiltValueNullFieldError.checkNotNull(
              code, r'BoardingInputOneOf1', 'code'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
