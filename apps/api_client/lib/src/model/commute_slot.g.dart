// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commute_slot.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CommuteSlotStateEnum _$commuteSlotStateEnum_available =
    const CommuteSlotStateEnum._('available');
const CommuteSlotStateEnum _$commuteSlotStateEnum_held =
    const CommuteSlotStateEnum._('held');
const CommuteSlotStateEnum _$commuteSlotStateEnum_assigned =
    const CommuteSlotStateEnum._('assigned');
const CommuteSlotStateEnum _$commuteSlotStateEnum_retired =
    const CommuteSlotStateEnum._('retired');

CommuteSlotStateEnum _$commuteSlotStateEnumValueOf(String name) {
  switch (name) {
    case 'available':
      return _$commuteSlotStateEnum_available;
    case 'held':
      return _$commuteSlotStateEnum_held;
    case 'assigned':
      return _$commuteSlotStateEnum_assigned;
    case 'retired':
      return _$commuteSlotStateEnum_retired;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CommuteSlotStateEnum> _$commuteSlotStateEnumValues =
    BuiltSet<CommuteSlotStateEnum>(const <CommuteSlotStateEnum>[
  _$commuteSlotStateEnum_available,
  _$commuteSlotStateEnum_held,
  _$commuteSlotStateEnum_assigned,
  _$commuteSlotStateEnum_retired,
]);

Serializer<CommuteSlotStateEnum> _$commuteSlotStateEnumSerializer =
    _$CommuteSlotStateEnumSerializer();

class _$CommuteSlotStateEnumSerializer
    implements PrimitiveSerializer<CommuteSlotStateEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'available': 'available',
    'held': 'held',
    'assigned': 'assigned',
    'retired': 'retired',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'available': 'available',
    'held': 'held',
    'assigned': 'assigned',
    'retired': 'retired',
  };

  @override
  final Iterable<Type> types = const <Type>[CommuteSlotStateEnum];
  @override
  final String wireName = 'CommuteSlotStateEnum';

  @override
  Object serialize(Serializers serializers, CommuteSlotStateEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CommuteSlotStateEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CommuteSlotStateEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$CommuteSlot extends CommuteSlot {
  @override
  final String routeId;
  @override
  final BuiltList<CommuteLeg> legs;
  @override
  final Date availableFrom;
  @override
  final String id;
  @override
  final String editToken;
  @override
  final CommuteSlotStateEnum state;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final int version;

  factory _$CommuteSlot([void Function(CommuteSlotBuilder)? updates]) =>
      (CommuteSlotBuilder()..update(updates))._build();

  _$CommuteSlot._(
      {required this.routeId,
      required this.legs,
      required this.availableFrom,
      required this.id,
      required this.editToken,
      required this.state,
      required this.createdAt,
      required this.updatedAt,
      required this.version})
      : super._();
  @override
  CommuteSlot rebuild(void Function(CommuteSlotBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CommuteSlotBuilder toBuilder() => CommuteSlotBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CommuteSlot &&
        routeId == other.routeId &&
        legs == other.legs &&
        availableFrom == other.availableFrom &&
        id == other.id &&
        editToken == other.editToken &&
        state == other.state &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        version == other.version;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, routeId.hashCode);
    _$hash = $jc(_$hash, legs.hashCode);
    _$hash = $jc(_$hash, availableFrom.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, editToken.hashCode);
    _$hash = $jc(_$hash, state.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CommuteSlot')
          ..add('routeId', routeId)
          ..add('legs', legs)
          ..add('availableFrom', availableFrom)
          ..add('id', id)
          ..add('editToken', editToken)
          ..add('state', state)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt)
          ..add('version', version))
        .toString();
  }
}

class CommuteSlotBuilder implements Builder<CommuteSlot, CommuteSlotBuilder> {
  _$CommuteSlot? _$v;

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

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _editToken;
  String? get editToken => _$this._editToken;
  set editToken(String? editToken) => _$this._editToken = editToken;

  CommuteSlotStateEnum? _state;
  CommuteSlotStateEnum? get state => _$this._state;
  set state(CommuteSlotStateEnum? state) => _$this._state = state;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  int? _version;
  int? get version => _$this._version;
  set version(int? version) => _$this._version = version;

  CommuteSlotBuilder() {
    CommuteSlot._defaults(this);
  }

  CommuteSlotBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _routeId = $v.routeId;
      _legs = $v.legs.toBuilder();
      _availableFrom = $v.availableFrom;
      _id = $v.id;
      _editToken = $v.editToken;
      _state = $v.state;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _version = $v.version;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CommuteSlot other) {
    _$v = other as _$CommuteSlot;
  }

  @override
  void update(void Function(CommuteSlotBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CommuteSlot build() => _build();

  _$CommuteSlot _build() {
    _$CommuteSlot _$result;
    try {
      _$result = _$v ??
          _$CommuteSlot._(
            routeId: BuiltValueNullFieldError.checkNotNull(
                routeId, r'CommuteSlot', 'routeId'),
            legs: legs.build(),
            availableFrom: BuiltValueNullFieldError.checkNotNull(
                availableFrom, r'CommuteSlot', 'availableFrom'),
            id: BuiltValueNullFieldError.checkNotNull(id, r'CommuteSlot', 'id'),
            editToken: BuiltValueNullFieldError.checkNotNull(
                editToken, r'CommuteSlot', 'editToken'),
            state: BuiltValueNullFieldError.checkNotNull(
                state, r'CommuteSlot', 'state'),
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'CommuteSlot', 'createdAt'),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
                updatedAt, r'CommuteSlot', 'updatedAt'),
            version: BuiltValueNullFieldError.checkNotNull(
                version, r'CommuteSlot', 'version'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'legs';
        legs.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'CommuteSlot', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
