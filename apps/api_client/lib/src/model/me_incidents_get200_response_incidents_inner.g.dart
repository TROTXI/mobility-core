// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'me_incidents_get200_response_incidents_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MeIncidentsGet200ResponseIncidentsInnerCategoryEnum
    _$meIncidentsGet200ResponseIncidentsInnerCategoryEnum_vehicle =
    const MeIncidentsGet200ResponseIncidentsInnerCategoryEnum._('vehicle');
const MeIncidentsGet200ResponseIncidentsInnerCategoryEnum
    _$meIncidentsGet200ResponseIncidentsInnerCategoryEnum_collision =
    const MeIncidentsGet200ResponseIncidentsInnerCategoryEnum._('collision');
const MeIncidentsGet200ResponseIncidentsInnerCategoryEnum
    _$meIncidentsGet200ResponseIncidentsInnerCategoryEnum_passengerSafety =
    const MeIncidentsGet200ResponseIncidentsInnerCategoryEnum._(
        'passengerSafety');
const MeIncidentsGet200ResponseIncidentsInnerCategoryEnum
    _$meIncidentsGet200ResponseIncidentsInnerCategoryEnum_routeBlocked =
    const MeIncidentsGet200ResponseIncidentsInnerCategoryEnum._('routeBlocked');
const MeIncidentsGet200ResponseIncidentsInnerCategoryEnum
    _$meIncidentsGet200ResponseIncidentsInnerCategoryEnum_other =
    const MeIncidentsGet200ResponseIncidentsInnerCategoryEnum._('other');

MeIncidentsGet200ResponseIncidentsInnerCategoryEnum
    _$meIncidentsGet200ResponseIncidentsInnerCategoryEnumValueOf(String name) {
  switch (name) {
    case 'vehicle':
      return _$meIncidentsGet200ResponseIncidentsInnerCategoryEnum_vehicle;
    case 'collision':
      return _$meIncidentsGet200ResponseIncidentsInnerCategoryEnum_collision;
    case 'passengerSafety':
      return _$meIncidentsGet200ResponseIncidentsInnerCategoryEnum_passengerSafety;
    case 'routeBlocked':
      return _$meIncidentsGet200ResponseIncidentsInnerCategoryEnum_routeBlocked;
    case 'other':
      return _$meIncidentsGet200ResponseIncidentsInnerCategoryEnum_other;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<MeIncidentsGet200ResponseIncidentsInnerCategoryEnum>
    _$meIncidentsGet200ResponseIncidentsInnerCategoryEnumValues = BuiltSet<
        MeIncidentsGet200ResponseIncidentsInnerCategoryEnum>(const <MeIncidentsGet200ResponseIncidentsInnerCategoryEnum>[
  _$meIncidentsGet200ResponseIncidentsInnerCategoryEnum_vehicle,
  _$meIncidentsGet200ResponseIncidentsInnerCategoryEnum_collision,
  _$meIncidentsGet200ResponseIncidentsInnerCategoryEnum_passengerSafety,
  _$meIncidentsGet200ResponseIncidentsInnerCategoryEnum_routeBlocked,
  _$meIncidentsGet200ResponseIncidentsInnerCategoryEnum_other,
]);

const MeIncidentsGet200ResponseIncidentsInnerStatusEnum
    _$meIncidentsGet200ResponseIncidentsInnerStatusEnum_open =
    const MeIncidentsGet200ResponseIncidentsInnerStatusEnum._('open');
const MeIncidentsGet200ResponseIncidentsInnerStatusEnum
    _$meIncidentsGet200ResponseIncidentsInnerStatusEnum_acknowledged =
    const MeIncidentsGet200ResponseIncidentsInnerStatusEnum._('acknowledged');
const MeIncidentsGet200ResponseIncidentsInnerStatusEnum
    _$meIncidentsGet200ResponseIncidentsInnerStatusEnum_resolved =
    const MeIncidentsGet200ResponseIncidentsInnerStatusEnum._('resolved');

MeIncidentsGet200ResponseIncidentsInnerStatusEnum
    _$meIncidentsGet200ResponseIncidentsInnerStatusEnumValueOf(String name) {
  switch (name) {
    case 'open':
      return _$meIncidentsGet200ResponseIncidentsInnerStatusEnum_open;
    case 'acknowledged':
      return _$meIncidentsGet200ResponseIncidentsInnerStatusEnum_acknowledged;
    case 'resolved':
      return _$meIncidentsGet200ResponseIncidentsInnerStatusEnum_resolved;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<MeIncidentsGet200ResponseIncidentsInnerStatusEnum>
    _$meIncidentsGet200ResponseIncidentsInnerStatusEnumValues = BuiltSet<
        MeIncidentsGet200ResponseIncidentsInnerStatusEnum>(const <MeIncidentsGet200ResponseIncidentsInnerStatusEnum>[
  _$meIncidentsGet200ResponseIncidentsInnerStatusEnum_open,
  _$meIncidentsGet200ResponseIncidentsInnerStatusEnum_acknowledged,
  _$meIncidentsGet200ResponseIncidentsInnerStatusEnum_resolved,
]);

Serializer<MeIncidentsGet200ResponseIncidentsInnerCategoryEnum>
    _$meIncidentsGet200ResponseIncidentsInnerCategoryEnumSerializer =
    _$MeIncidentsGet200ResponseIncidentsInnerCategoryEnumSerializer();
Serializer<MeIncidentsGet200ResponseIncidentsInnerStatusEnum>
    _$meIncidentsGet200ResponseIncidentsInnerStatusEnumSerializer =
    _$MeIncidentsGet200ResponseIncidentsInnerStatusEnumSerializer();

class _$MeIncidentsGet200ResponseIncidentsInnerCategoryEnumSerializer
    implements
        PrimitiveSerializer<
            MeIncidentsGet200ResponseIncidentsInnerCategoryEnum> {
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
    MeIncidentsGet200ResponseIncidentsInnerCategoryEnum
  ];
  @override
  final String wireName = 'MeIncidentsGet200ResponseIncidentsInnerCategoryEnum';

  @override
  Object serialize(Serializers serializers,
          MeIncidentsGet200ResponseIncidentsInnerCategoryEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  MeIncidentsGet200ResponseIncidentsInnerCategoryEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      MeIncidentsGet200ResponseIncidentsInnerCategoryEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$MeIncidentsGet200ResponseIncidentsInnerStatusEnumSerializer
    implements
        PrimitiveSerializer<MeIncidentsGet200ResponseIncidentsInnerStatusEnum> {
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
    MeIncidentsGet200ResponseIncidentsInnerStatusEnum
  ];
  @override
  final String wireName = 'MeIncidentsGet200ResponseIncidentsInnerStatusEnum';

  @override
  Object serialize(Serializers serializers,
          MeIncidentsGet200ResponseIncidentsInnerStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  MeIncidentsGet200ResponseIncidentsInnerStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      MeIncidentsGet200ResponseIncidentsInnerStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$MeIncidentsGet200ResponseIncidentsInner
    extends MeIncidentsGet200ResponseIncidentsInner {
  @override
  final String id;
  @override
  final String? tripId;
  @override
  final String? vehicleId;
  @override
  final MeIncidentsGet200ResponseIncidentsInnerCategoryEnum category;
  @override
  final String? note;
  @override
  final num? lat;
  @override
  final num? lng;
  @override
  final MeIncidentsGet200ResponseIncidentsInnerStatusEnum status;
  @override
  final String? resolution;
  @override
  final DateTime occurredAt;
  @override
  final DateTime createdAt;

  factory _$MeIncidentsGet200ResponseIncidentsInner(
          [void Function(MeIncidentsGet200ResponseIncidentsInnerBuilder)?
              updates]) =>
      (MeIncidentsGet200ResponseIncidentsInnerBuilder()..update(updates))
          ._build();

  _$MeIncidentsGet200ResponseIncidentsInner._(
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
      required this.createdAt})
      : super._();
  @override
  MeIncidentsGet200ResponseIncidentsInner rebuild(
          void Function(MeIncidentsGet200ResponseIncidentsInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MeIncidentsGet200ResponseIncidentsInnerBuilder toBuilder() =>
      MeIncidentsGet200ResponseIncidentsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MeIncidentsGet200ResponseIncidentsInner &&
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
        createdAt == other.createdAt;
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
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'MeIncidentsGet200ResponseIncidentsInner')
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
          ..add('createdAt', createdAt))
        .toString();
  }
}

class MeIncidentsGet200ResponseIncidentsInnerBuilder
    implements
        Builder<MeIncidentsGet200ResponseIncidentsInner,
            MeIncidentsGet200ResponseIncidentsInnerBuilder> {
  _$MeIncidentsGet200ResponseIncidentsInner? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _tripId;
  String? get tripId => _$this._tripId;
  set tripId(String? tripId) => _$this._tripId = tripId;

  String? _vehicleId;
  String? get vehicleId => _$this._vehicleId;
  set vehicleId(String? vehicleId) => _$this._vehicleId = vehicleId;

  MeIncidentsGet200ResponseIncidentsInnerCategoryEnum? _category;
  MeIncidentsGet200ResponseIncidentsInnerCategoryEnum? get category =>
      _$this._category;
  set category(MeIncidentsGet200ResponseIncidentsInnerCategoryEnum? category) =>
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

  MeIncidentsGet200ResponseIncidentsInnerStatusEnum? _status;
  MeIncidentsGet200ResponseIncidentsInnerStatusEnum? get status =>
      _$this._status;
  set status(MeIncidentsGet200ResponseIncidentsInnerStatusEnum? status) =>
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

  MeIncidentsGet200ResponseIncidentsInnerBuilder() {
    MeIncidentsGet200ResponseIncidentsInner._defaults(this);
  }

  MeIncidentsGet200ResponseIncidentsInnerBuilder get _$this {
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
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MeIncidentsGet200ResponseIncidentsInner other) {
    _$v = other as _$MeIncidentsGet200ResponseIncidentsInner;
  }

  @override
  void update(
      void Function(MeIncidentsGet200ResponseIncidentsInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MeIncidentsGet200ResponseIncidentsInner build() => _build();

  _$MeIncidentsGet200ResponseIncidentsInner _build() {
    final _$result = _$v ??
        _$MeIncidentsGet200ResponseIncidentsInner._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'MeIncidentsGet200ResponseIncidentsInner', 'id'),
          tripId: tripId,
          vehicleId: vehicleId,
          category: BuiltValueNullFieldError.checkNotNull(
              category, r'MeIncidentsGet200ResponseIncidentsInner', 'category'),
          note: note,
          lat: lat,
          lng: lng,
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'MeIncidentsGet200ResponseIncidentsInner', 'status'),
          resolution: resolution,
          occurredAt: BuiltValueNullFieldError.checkNotNull(occurredAt,
              r'MeIncidentsGet200ResponseIncidentsInner', 'occurredAt'),
          createdAt: BuiltValueNullFieldError.checkNotNull(createdAt,
              r'MeIncidentsGet200ResponseIncidentsInner', 'createdAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
