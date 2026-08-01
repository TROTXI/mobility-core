// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'boarding_manifest_get200_response_riders_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const BoardingManifestGet200ResponseRidersInnerDirectionEnum
    _$boardingManifestGet200ResponseRidersInnerDirectionEnum_morning =
    const BoardingManifestGet200ResponseRidersInnerDirectionEnum._('morning');
const BoardingManifestGet200ResponseRidersInnerDirectionEnum
    _$boardingManifestGet200ResponseRidersInnerDirectionEnum_evening =
    const BoardingManifestGet200ResponseRidersInnerDirectionEnum._('evening');

BoardingManifestGet200ResponseRidersInnerDirectionEnum
    _$boardingManifestGet200ResponseRidersInnerDirectionEnumValueOf(
        String name) {
  switch (name) {
    case 'morning':
      return _$boardingManifestGet200ResponseRidersInnerDirectionEnum_morning;
    case 'evening':
      return _$boardingManifestGet200ResponseRidersInnerDirectionEnum_evening;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<BoardingManifestGet200ResponseRidersInnerDirectionEnum>
    _$boardingManifestGet200ResponseRidersInnerDirectionEnumValues = BuiltSet<
        BoardingManifestGet200ResponseRidersInnerDirectionEnum>(const <BoardingManifestGet200ResponseRidersInnerDirectionEnum>[
  _$boardingManifestGet200ResponseRidersInnerDirectionEnum_morning,
  _$boardingManifestGet200ResponseRidersInnerDirectionEnum_evening,
]);

Serializer<BoardingManifestGet200ResponseRidersInnerDirectionEnum>
    _$boardingManifestGet200ResponseRidersInnerDirectionEnumSerializer =
    _$BoardingManifestGet200ResponseRidersInnerDirectionEnumSerializer();

class _$BoardingManifestGet200ResponseRidersInnerDirectionEnumSerializer
    implements
        PrimitiveSerializer<
            BoardingManifestGet200ResponseRidersInnerDirectionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'morning': 'morning',
    'evening': 'evening',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'morning': 'morning',
    'evening': 'evening',
  };

  @override
  final Iterable<Type> types = const <Type>[
    BoardingManifestGet200ResponseRidersInnerDirectionEnum
  ];
  @override
  final String wireName =
      'BoardingManifestGet200ResponseRidersInnerDirectionEnum';

  @override
  Object serialize(Serializers serializers,
          BoardingManifestGet200ResponseRidersInnerDirectionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  BoardingManifestGet200ResponseRidersInnerDirectionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      BoardingManifestGet200ResponseRidersInnerDirectionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$BoardingManifestGet200ResponseRidersInner
    extends BoardingManifestGet200ResponseRidersInner {
  @override
  final String reservationId;
  @override
  final String userId;
  @override
  final String? name;
  @override
  final String? avatarUrl;
  @override
  final BoardingManifestGet200ResponseRidersInnerDirectionEnum direction;
  @override
  final bool boarded;

  factory _$BoardingManifestGet200ResponseRidersInner(
          [void Function(BoardingManifestGet200ResponseRidersInnerBuilder)?
              updates]) =>
      (BoardingManifestGet200ResponseRidersInnerBuilder()..update(updates))
          ._build();

  _$BoardingManifestGet200ResponseRidersInner._(
      {required this.reservationId,
      required this.userId,
      this.name,
      this.avatarUrl,
      required this.direction,
      required this.boarded})
      : super._();
  @override
  BoardingManifestGet200ResponseRidersInner rebuild(
          void Function(BoardingManifestGet200ResponseRidersInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BoardingManifestGet200ResponseRidersInnerBuilder toBuilder() =>
      BoardingManifestGet200ResponseRidersInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BoardingManifestGet200ResponseRidersInner &&
        reservationId == other.reservationId &&
        userId == other.userId &&
        name == other.name &&
        avatarUrl == other.avatarUrl &&
        direction == other.direction &&
        boarded == other.boarded;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, reservationId.hashCode);
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, avatarUrl.hashCode);
    _$hash = $jc(_$hash, direction.hashCode);
    _$hash = $jc(_$hash, boarded.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'BoardingManifestGet200ResponseRidersInner')
          ..add('reservationId', reservationId)
          ..add('userId', userId)
          ..add('name', name)
          ..add('avatarUrl', avatarUrl)
          ..add('direction', direction)
          ..add('boarded', boarded))
        .toString();
  }
}

class BoardingManifestGet200ResponseRidersInnerBuilder
    implements
        Builder<BoardingManifestGet200ResponseRidersInner,
            BoardingManifestGet200ResponseRidersInnerBuilder> {
  _$BoardingManifestGet200ResponseRidersInner? _$v;

  String? _reservationId;
  String? get reservationId => _$this._reservationId;
  set reservationId(String? reservationId) =>
      _$this._reservationId = reservationId;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _avatarUrl;
  String? get avatarUrl => _$this._avatarUrl;
  set avatarUrl(String? avatarUrl) => _$this._avatarUrl = avatarUrl;

  BoardingManifestGet200ResponseRidersInnerDirectionEnum? _direction;
  BoardingManifestGet200ResponseRidersInnerDirectionEnum? get direction =>
      _$this._direction;
  set direction(
          BoardingManifestGet200ResponseRidersInnerDirectionEnum? direction) =>
      _$this._direction = direction;

  bool? _boarded;
  bool? get boarded => _$this._boarded;
  set boarded(bool? boarded) => _$this._boarded = boarded;

  BoardingManifestGet200ResponseRidersInnerBuilder() {
    BoardingManifestGet200ResponseRidersInner._defaults(this);
  }

  BoardingManifestGet200ResponseRidersInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _reservationId = $v.reservationId;
      _userId = $v.userId;
      _name = $v.name;
      _avatarUrl = $v.avatarUrl;
      _direction = $v.direction;
      _boarded = $v.boarded;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BoardingManifestGet200ResponseRidersInner other) {
    _$v = other as _$BoardingManifestGet200ResponseRidersInner;
  }

  @override
  void update(
      void Function(BoardingManifestGet200ResponseRidersInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  BoardingManifestGet200ResponseRidersInner build() => _build();

  _$BoardingManifestGet200ResponseRidersInner _build() {
    final _$result = _$v ??
        _$BoardingManifestGet200ResponseRidersInner._(
          reservationId: BuiltValueNullFieldError.checkNotNull(reservationId,
              r'BoardingManifestGet200ResponseRidersInner', 'reservationId'),
          userId: BuiltValueNullFieldError.checkNotNull(
              userId, r'BoardingManifestGet200ResponseRidersInner', 'userId'),
          name: name,
          avatarUrl: avatarUrl,
          direction: BuiltValueNullFieldError.checkNotNull(direction,
              r'BoardingManifestGet200ResponseRidersInner', 'direction'),
          boarded: BuiltValueNullFieldError.checkNotNull(
              boarded, r'BoardingManifestGet200ResponseRidersInner', 'boarded'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
