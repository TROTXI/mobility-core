// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'boarding_input_one_of2.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const BoardingInputOneOf2KindEnum _$boardingInputOneOf2KindEnum_photo =
    const BoardingInputOneOf2KindEnum._('photo');

BoardingInputOneOf2KindEnum _$boardingInputOneOf2KindEnumValueOf(String name) {
  switch (name) {
    case 'photo':
      return _$boardingInputOneOf2KindEnum_photo;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<BoardingInputOneOf2KindEnum>
    _$boardingInputOneOf2KindEnumValues =
    BuiltSet<BoardingInputOneOf2KindEnum>(const <BoardingInputOneOf2KindEnum>[
  _$boardingInputOneOf2KindEnum_photo,
]);

Serializer<BoardingInputOneOf2KindEnum>
    _$boardingInputOneOf2KindEnumSerializer =
    _$BoardingInputOneOf2KindEnumSerializer();

class _$BoardingInputOneOf2KindEnumSerializer
    implements PrimitiveSerializer<BoardingInputOneOf2KindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'photo': 'photo',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'photo': 'photo',
  };

  @override
  final Iterable<Type> types = const <Type>[BoardingInputOneOf2KindEnum];
  @override
  final String wireName = 'BoardingInputOneOf2KindEnum';

  @override
  Object serialize(Serializers serializers, BoardingInputOneOf2KindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  BoardingInputOneOf2KindEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      BoardingInputOneOf2KindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$BoardingInputOneOf2 extends BoardingInputOneOf2 {
  @override
  final BoardingInputOneOf2KindEnum kind;
  @override
  final String reservationId;

  factory _$BoardingInputOneOf2(
          [void Function(BoardingInputOneOf2Builder)? updates]) =>
      (BoardingInputOneOf2Builder()..update(updates))._build();

  _$BoardingInputOneOf2._({required this.kind, required this.reservationId})
      : super._();
  @override
  BoardingInputOneOf2 rebuild(
          void Function(BoardingInputOneOf2Builder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BoardingInputOneOf2Builder toBuilder() =>
      BoardingInputOneOf2Builder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BoardingInputOneOf2 &&
        kind == other.kind &&
        reservationId == other.reservationId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, reservationId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BoardingInputOneOf2')
          ..add('kind', kind)
          ..add('reservationId', reservationId))
        .toString();
  }
}

class BoardingInputOneOf2Builder
    implements Builder<BoardingInputOneOf2, BoardingInputOneOf2Builder> {
  _$BoardingInputOneOf2? _$v;

  BoardingInputOneOf2KindEnum? _kind;
  BoardingInputOneOf2KindEnum? get kind => _$this._kind;
  set kind(BoardingInputOneOf2KindEnum? kind) => _$this._kind = kind;

  String? _reservationId;
  String? get reservationId => _$this._reservationId;
  set reservationId(String? reservationId) =>
      _$this._reservationId = reservationId;

  BoardingInputOneOf2Builder() {
    BoardingInputOneOf2._defaults(this);
  }

  BoardingInputOneOf2Builder get _$this {
    final $v = _$v;
    if ($v != null) {
      _kind = $v.kind;
      _reservationId = $v.reservationId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BoardingInputOneOf2 other) {
    _$v = other as _$BoardingInputOneOf2;
  }

  @override
  void update(void Function(BoardingInputOneOf2Builder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BoardingInputOneOf2 build() => _build();

  _$BoardingInputOneOf2 _build() {
    final _$result = _$v ??
        _$BoardingInputOneOf2._(
          kind: BuiltValueNullFieldError.checkNotNull(
              kind, r'BoardingInputOneOf2', 'kind'),
          reservationId: BuiltValueNullFieldError.checkNotNull(
              reservationId, r'BoardingInputOneOf2', 'reservationId'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
