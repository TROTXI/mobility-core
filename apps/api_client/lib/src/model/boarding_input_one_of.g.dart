// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'boarding_input_one_of.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const BoardingInputOneOfKindEnum _$boardingInputOneOfKindEnum_qr =
    const BoardingInputOneOfKindEnum._('qr');

BoardingInputOneOfKindEnum _$boardingInputOneOfKindEnumValueOf(String name) {
  switch (name) {
    case 'qr':
      return _$boardingInputOneOfKindEnum_qr;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<BoardingInputOneOfKindEnum> _$boardingInputOneOfKindEnumValues =
    BuiltSet<BoardingInputOneOfKindEnum>(const <BoardingInputOneOfKindEnum>[
  _$boardingInputOneOfKindEnum_qr,
]);

Serializer<BoardingInputOneOfKindEnum> _$boardingInputOneOfKindEnumSerializer =
    _$BoardingInputOneOfKindEnumSerializer();

class _$BoardingInputOneOfKindEnumSerializer
    implements PrimitiveSerializer<BoardingInputOneOfKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'qr': 'qr',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'qr': 'qr',
  };

  @override
  final Iterable<Type> types = const <Type>[BoardingInputOneOfKindEnum];
  @override
  final String wireName = 'BoardingInputOneOfKindEnum';

  @override
  Object serialize(Serializers serializers, BoardingInputOneOfKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  BoardingInputOneOfKindEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      BoardingInputOneOfKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$BoardingInputOneOf extends BoardingInputOneOf {
  @override
  final BoardingInputOneOfKindEnum kind;
  @override
  final String token;

  factory _$BoardingInputOneOf(
          [void Function(BoardingInputOneOfBuilder)? updates]) =>
      (BoardingInputOneOfBuilder()..update(updates))._build();

  _$BoardingInputOneOf._({required this.kind, required this.token}) : super._();
  @override
  BoardingInputOneOf rebuild(
          void Function(BoardingInputOneOfBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BoardingInputOneOfBuilder toBuilder() =>
      BoardingInputOneOfBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BoardingInputOneOf &&
        kind == other.kind &&
        token == other.token;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, token.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BoardingInputOneOf')
          ..add('kind', kind)
          ..add('token', token))
        .toString();
  }
}

class BoardingInputOneOfBuilder
    implements Builder<BoardingInputOneOf, BoardingInputOneOfBuilder> {
  _$BoardingInputOneOf? _$v;

  BoardingInputOneOfKindEnum? _kind;
  BoardingInputOneOfKindEnum? get kind => _$this._kind;
  set kind(BoardingInputOneOfKindEnum? kind) => _$this._kind = kind;

  String? _token;
  String? get token => _$this._token;
  set token(String? token) => _$this._token = token;

  BoardingInputOneOfBuilder() {
    BoardingInputOneOf._defaults(this);
  }

  BoardingInputOneOfBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _kind = $v.kind;
      _token = $v.token;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BoardingInputOneOf other) {
    _$v = other as _$BoardingInputOneOf;
  }

  @override
  void update(void Function(BoardingInputOneOfBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BoardingInputOneOf build() => _build();

  _$BoardingInputOneOf _build() {
    final _$result = _$v ??
        _$BoardingInputOneOf._(
          kind: BuiltValueNullFieldError.checkNotNull(
              kind, r'BoardingInputOneOf', 'kind'),
          token: BuiltValueNullFieldError.checkNotNull(
              token, r'BoardingInputOneOf', 'token'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
