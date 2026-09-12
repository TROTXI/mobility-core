// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_incidents_get200_response_incidents_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminIncidentsGet200ResponseIncidentsInnerCategoryEnum
    _$adminIncidentsGet200ResponseIncidentsInnerCategoryEnum_vehicle =
    const AdminIncidentsGet200ResponseIncidentsInnerCategoryEnum._('vehicle');
const AdminIncidentsGet200ResponseIncidentsInnerCategoryEnum
    _$adminIncidentsGet200ResponseIncidentsInnerCategoryEnum_collision =
    const AdminIncidentsGet200ResponseIncidentsInnerCategoryEnum._('collision');
const AdminIncidentsGet200ResponseIncidentsInnerCategoryEnum
    _$adminIncidentsGet200ResponseIncidentsInnerCategoryEnum_passengerSafety =
    const AdminIncidentsGet200ResponseIncidentsInnerCategoryEnum._(
        'passengerSafety');
const AdminIncidentsGet200ResponseIncidentsInnerCategoryEnum
    _$adminIncidentsGet200ResponseIncidentsInnerCategoryEnum_routeBlocked =
    const AdminIncidentsGet200ResponseIncidentsInnerCategoryEnum._(
        'routeBlocked');
const AdminIncidentsGet200ResponseIncidentsInnerCategoryEnum
    _$adminIncidentsGet200ResponseIncidentsInnerCategoryEnum_other =
    const AdminIncidentsGet200ResponseIncidentsInnerCategoryEnum._('other');

AdminIncidentsGet200ResponseIncidentsInnerCategoryEnum
    _$adminIncidentsGet200ResponseIncidentsInnerCategoryEnumValueOf(
        String name) {
  switch (name) {
    case 'vehicle':
      return _$adminIncidentsGet200ResponseIncidentsInnerCategoryEnum_vehicle;
    case 'collision':
      return _$adminIncidentsGet200ResponseIncidentsInnerCategoryEnum_collision;
    case 'passengerSafety':
      return _$adminIncidentsGet200ResponseIncidentsInnerCategoryEnum_passengerSafety;
    case 'routeBlocked':
      return _$adminIncidentsGet200ResponseIncidentsInnerCategoryEnum_routeBlocked;
    case 'other':
      return _$adminIncidentsGet200ResponseIncidentsInnerCategoryEnum_other;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<AdminIncidentsGet200ResponseIncidentsInnerCategoryEnum>
    _$adminIncidentsGet200ResponseIncidentsInnerCategoryEnumValues = BuiltSet<
        AdminIncidentsGet200ResponseIncidentsInnerCategoryEnum>(const <AdminIncidentsGet200ResponseIncidentsInnerCategoryEnum>[
  _$adminIncidentsGet200ResponseIncidentsInnerCategoryEnum_vehicle,
  _$adminIncidentsGet200ResponseIncidentsInnerCategoryEnum_collision,
  _$adminIncidentsGet200ResponseIncidentsInnerCategoryEnum_passengerSafety,
  _$adminIncidentsGet200ResponseIncidentsInnerCategoryEnum_routeBlocked,
  _$adminIncidentsGet200ResponseIncidentsInnerCategoryEnum_other,
]);

const AdminIncidentsGet200ResponseIncidentsInnerStatusEnum
    _$adminIncidentsGet200ResponseIncidentsInnerStatusEnum_open =
    const AdminIncidentsGet200ResponseIncidentsInnerStatusEnum._('open');
const AdminIncidentsGet200ResponseIncidentsInnerStatusEnum
    _$adminIncidentsGet200ResponseIncidentsInnerStatusEnum_acknowledged =
    const AdminIncidentsGet200ResponseIncidentsInnerStatusEnum._(
        'acknowledged');
const AdminIncidentsGet200ResponseIncidentsInnerStatusEnum
    _$adminIncidentsGet200ResponseIncidentsInnerStatusEnum_resolved =
    const AdminIncidentsGet200ResponseIncidentsInnerStatusEnum._('resolved');

AdminIncidentsGet200ResponseIncidentsInnerStatusEnum
    _$adminIncidentsGet200ResponseIncidentsInnerStatusEnumValueOf(String name) {
  switch (name) {
    case 'open':
      return _$adminIncidentsGet200ResponseIncidentsInnerStatusEnum_open;
    case 'acknowledged':
      return _$adminIncidentsGet200ResponseIncidentsInnerStatusEnum_acknowledged;
    case 'resolved':
      return _$adminIncidentsGet200ResponseIncidentsInnerStatusEnum_resolved;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<AdminIncidentsGet200ResponseIncidentsInnerStatusEnum>
    _$adminIncidentsGet200ResponseIncidentsInnerStatusEnumValues = BuiltSet<
        AdminIncidentsGet200ResponseIncidentsInnerStatusEnum>(const <AdminIncidentsGet200ResponseIncidentsInnerStatusEnum>[
  _$adminIncidentsGet200ResponseIncidentsInnerStatusEnum_open,
  _$adminIncidentsGet200ResponseIncidentsInnerStatusEnum_acknowledged,
  _$adminIncidentsGet200ResponseIncidentsInnerStatusEnum_resolved,
]);

Serializer<AdminIncidentsGet200ResponseIncidentsInnerCategoryEnum>
    _$adminIncidentsGet200ResponseIncidentsInnerCategoryEnumSerializer =
    _$AdminIncidentsGet200ResponseIncidentsInnerCategoryEnumSerializer();
Serializer<AdminIncidentsGet200ResponseIncidentsInnerStatusEnum>
    _$adminIncidentsGet200ResponseIncidentsInnerStatusEnumSerializer =
    _$AdminIncidentsGet200ResponseIncidentsInnerStatusEnumSerializer();

class _$AdminIncidentsGet200ResponseIncidentsInnerCategoryEnumSerializer
    implements
        PrimitiveSerializer<
            AdminIncidentsGet200ResponseIncidentsInnerCategoryEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'vehicle': 'vehicle',
    'collision': 'collision',
    'passengerSafety': 'passenger_safety',
    'routeBlocked': 'route_blocked',
    'other': 'other',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'vehicle': 'vehicle',
    'collision': 'collision',
    'passenger_safety': 'passengerSafety',
    'route_blocked': 'routeBlocked',
    'other': 'other',
  };

  @override
  final Iterable<Type> types = const <Type>[
    AdminIncidentsGet200ResponseIncidentsInnerCategoryEnum
  ];
  @override
  final String wireName =
      'AdminIncidentsGet200ResponseIncidentsInnerCategoryEnum';

  @override
  Object serialize(Serializers serializers,
          AdminIncidentsGet200ResponseIncidentsInnerCategoryEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  AdminIncidentsGet200ResponseIncidentsInnerCategoryEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      AdminIncidentsGet200ResponseIncidentsInnerCategoryEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$AdminIncidentsGet200ResponseIncidentsInnerStatusEnumSerializer
    implements
        PrimitiveSerializer<
            AdminIncidentsGet200ResponseIncidentsInnerStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'open': 'open',
    'acknowledged': 'acknowledged',
    'resolved': 'resolved',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'open': 'open',
    'acknowledged': 'acknowledged',
    'resolved': 'resolved',
  };

  @override
  final Iterable<Type> types = const <Type>[
    AdminIncidentsGet200ResponseIncidentsInnerStatusEnum
  ];
  @override
  final String wireName =
      'AdminIncidentsGet200ResponseIncidentsInnerStatusEnum';

  @override
  Object serialize(Serializers serializers,
          AdminIncidentsGet200ResponseIncidentsInnerStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  AdminIncidentsGet200ResponseIncidentsInnerStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      AdminIncidentsGet200ResponseIncidentsInnerStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$AdminIncidentsGet200ResponseIncidentsInner
    extends AdminIncidentsGet200ResponseIncidentsInner {
  @override
  final String id;
  @override
  final String? tripId;
  @override
  final String? vehicleId;
  @override
  final AdminIncidentsGet200ResponseIncidentsInnerCategoryEnum category;
  @override
  final String? note;
  @override
  final num? lat;
  @override
  final num? lng;
  @override
  final AdminIncidentsGet200ResponseIncidentsInnerStatusEnum status;
  @override
  final String? resolution;
  @override
  final DateTime occurredAt;
  @override
  final DateTime createdAt;
  @override
  final String driverId;
  @override
  final String? handledBy;
  @override
  final DateTime? handledAt;

  factory _$AdminIncidentsGet200ResponseIncidentsInner(
          [void Function(AdminIncidentsGet200ResponseIncidentsInnerBuilder)?
              updates]) =>
      (AdminIncidentsGet200ResponseIncidentsInnerBuilder()..update(updates))
          ._build();

  _$AdminIncidentsGet200ResponseIncidentsInner._(
      {required this.id,
      this.tripId,
      this.vehicleId,
      required this.category,
      this.note,
      this.lat,
      this.lng,
      required this.status,
      this.resolution,
      required this.occurredAt,
      required this.createdAt,
      required this.driverId,
      this.handledBy,
      this.handledAt})
      : super._();
  @override
  AdminIncidentsGet200ResponseIncidentsInner rebuild(
          void Function(AdminIncidentsGet200ResponseIncidentsInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminIncidentsGet200ResponseIncidentsInnerBuilder toBuilder() =>
      AdminIncidentsGet200ResponseIncidentsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminIncidentsGet200ResponseIncidentsInner &&
        id == other.id &&
        tripId == other.tripId &&
        vehicleId == other.vehicleId &&
        category == other.category &&
        note == other.note &&
        lat == other.lat &&
        lng == other.lng &&
        status == other.status &&
        resolution == other.resolution &&
        occurredAt == other.occurredAt &&
        createdAt == other.createdAt &&
        driverId == other.driverId &&
        handledBy == other.handledBy &&
        handledAt == other.handledAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, tripId.hashCode);
    _$hash = $jc(_$hash, vehicleId.hashCode);
    _$hash = $jc(_$hash, category.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, lat.hashCode);
    _$hash = $jc(_$hash, lng.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, resolution.hashCode);
    _$hash = $jc(_$hash, occurredAt.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, driverId.hashCode);
    _$hash = $jc(_$hash, handledBy.hashCode);
    _$hash = $jc(_$hash, handledAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'AdminIncidentsGet200ResponseIncidentsInner')
          ..add('id', id)
          ..add('tripId', tripId)
          ..add('vehicleId', vehicleId)
          ..add('category', category)
          ..add('note', note)
          ..add('lat', lat)
          ..add('lng', lng)
          ..add('status', status)
          ..add('resolution', resolution)
          ..add('occurredAt', occurredAt)
          ..add('createdAt', createdAt)
          ..add('driverId', driverId)
          ..add('handledBy', handledBy)
          ..add('handledAt', handledAt))
        .toString();
  }
}

class AdminIncidentsGet200ResponseIncidentsInnerBuilder
    implements
        Builder<AdminIncidentsGet200ResponseIncidentsInner,
            AdminIncidentsGet200ResponseIncidentsInnerBuilder> {
  _$AdminIncidentsGet200ResponseIncidentsInner? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _tripId;
  String? get tripId => _$this._tripId;
  set tripId(String? tripId) => _$this._tripId = tripId;

  String? _vehicleId;
  String? get vehicleId => _$this._vehicleId;
  set vehicleId(String? vehicleId) => _$this._vehicleId = vehicleId;

  AdminIncidentsGet200ResponseIncidentsInnerCategoryEnum? _category;
  AdminIncidentsGet200ResponseIncidentsInnerCategoryEnum? get category =>
      _$this._category;
  set category(
          AdminIncidentsGet200ResponseIncidentsInnerCategoryEnum? category) =>
      _$this._category = category;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  num? _lat;
  num? get lat => _$this._lat;
  set lat(num? lat) => _$this._lat = lat;

  num? _lng;
  num? get lng => _$this._lng;
  set lng(num? lng) => _$this._lng = lng;

  AdminIncidentsGet200ResponseIncidentsInnerStatusEnum? _status;
  AdminIncidentsGet200ResponseIncidentsInnerStatusEnum? get status =>
      _$this._status;
  set status(AdminIncidentsGet200ResponseIncidentsInnerStatusEnum? status) =>
      _$this._status = status;

  String? _resolution;
  String? get resolution => _$this._resolution;
  set resolution(String? resolution) => _$this._resolution = resolution;

  DateTime? _occurredAt;
  DateTime? get occurredAt => _$this._occurredAt;
  set occurredAt(DateTime? occurredAt) => _$this._occurredAt = occurredAt;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  String? _driverId;
  String? get driverId => _$this._driverId;
  set driverId(String? driverId) => _$this._driverId = driverId;

  String? _handledBy;
  String? get handledBy => _$this._handledBy;
  set handledBy(String? handledBy) => _$this._handledBy = handledBy;

  DateTime? _handledAt;
  DateTime? get handledAt => _$this._handledAt;
  set handledAt(DateTime? handledAt) => _$this._handledAt = handledAt;

  AdminIncidentsGet200ResponseIncidentsInnerBuilder() {
    AdminIncidentsGet200ResponseIncidentsInner._defaults(this);
  }

  AdminIncidentsGet200ResponseIncidentsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _tripId = $v.tripId;
      _vehicleId = $v.vehicleId;
      _category = $v.category;
      _note = $v.note;
      _lat = $v.lat;
      _lng = $v.lng;
      _status = $v.status;
      _resolution = $v.resolution;
      _occurredAt = $v.occurredAt;
      _createdAt = $v.createdAt;
      _driverId = $v.driverId;
      _handledBy = $v.handledBy;
      _handledAt = $v.handledAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminIncidentsGet200ResponseIncidentsInner other) {
    _$v = other as _$AdminIncidentsGet200ResponseIncidentsInner;
  }

  @override
  void update(
      void Function(AdminIncidentsGet200ResponseIncidentsInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminIncidentsGet200ResponseIncidentsInner build() => _build();

  _$AdminIncidentsGet200ResponseIncidentsInner _build() {
    final _$result = _$v ??
        _$AdminIncidentsGet200ResponseIncidentsInner._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'AdminIncidentsGet200ResponseIncidentsInner', 'id'),
          tripId: tripId,
          vehicleId: vehicleId,
          category: BuiltValueNullFieldError.checkNotNull(category,
              r'AdminIncidentsGet200ResponseIncidentsInner', 'category'),
          note: note,
          lat: lat,
          lng: lng,
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'AdminIncidentsGet200ResponseIncidentsInner', 'status'),
          resolution: resolution,
          occurredAt: BuiltValueNullFieldError.checkNotNull(occurredAt,
              r'AdminIncidentsGet200ResponseIncidentsInner', 'occurredAt'),
          createdAt: BuiltValueNullFieldError.checkNotNull(createdAt,
              r'AdminIncidentsGet200ResponseIncidentsInner', 'createdAt'),
          driverId: BuiltValueNullFieldError.checkNotNull(driverId,
              r'AdminIncidentsGet200ResponseIncidentsInner', 'driverId'),
          handledBy: handledBy,
          handledAt: handledAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
