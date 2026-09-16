// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'incident.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const IncidentCategoryEnum _$incidentCategoryEnum_vehicle =
    const IncidentCategoryEnum._('vehicle');
const IncidentCategoryEnum _$incidentCategoryEnum_collision =
    const IncidentCategoryEnum._('collision');
const IncidentCategoryEnum _$incidentCategoryEnum_passengerSafety =
    const IncidentCategoryEnum._('passengerSafety');
const IncidentCategoryEnum _$incidentCategoryEnum_routeBlocked =
    const IncidentCategoryEnum._('routeBlocked');
const IncidentCategoryEnum _$incidentCategoryEnum_other =
    const IncidentCategoryEnum._('other');

IncidentCategoryEnum _$incidentCategoryEnumValueOf(String name) {
  switch (name) {
    case 'vehicle':
      return _$incidentCategoryEnum_vehicle;
    case 'collision':
      return _$incidentCategoryEnum_collision;
    case 'passengerSafety':
      return _$incidentCategoryEnum_passengerSafety;
    case 'routeBlocked':
      return _$incidentCategoryEnum_routeBlocked;
    case 'other':
      return _$incidentCategoryEnum_other;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<IncidentCategoryEnum> _$incidentCategoryEnumValues =
    BuiltSet<IncidentCategoryEnum>(const <IncidentCategoryEnum>[
  _$incidentCategoryEnum_vehicle,
  _$incidentCategoryEnum_collision,
  _$incidentCategoryEnum_passengerSafety,
  _$incidentCategoryEnum_routeBlocked,
  _$incidentCategoryEnum_other,
]);

const IncidentStatusEnum _$incidentStatusEnum_open =
    const IncidentStatusEnum._('open');
const IncidentStatusEnum _$incidentStatusEnum_acknowledged =
    const IncidentStatusEnum._('acknowledged');
const IncidentStatusEnum _$incidentStatusEnum_resolved =
    const IncidentStatusEnum._('resolved');

IncidentStatusEnum _$incidentStatusEnumValueOf(String name) {
  switch (name) {
    case 'open':
      return _$incidentStatusEnum_open;
    case 'acknowledged':
      return _$incidentStatusEnum_acknowledged;
    case 'resolved':
      return _$incidentStatusEnum_resolved;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<IncidentStatusEnum> _$incidentStatusEnumValues =
    BuiltSet<IncidentStatusEnum>(const <IncidentStatusEnum>[
  _$incidentStatusEnum_open,
  _$incidentStatusEnum_acknowledged,
  _$incidentStatusEnum_resolved,
]);

Serializer<IncidentCategoryEnum> _$incidentCategoryEnumSerializer =
    _$IncidentCategoryEnumSerializer();
Serializer<IncidentStatusEnum> _$incidentStatusEnumSerializer =
    _$IncidentStatusEnumSerializer();

class _$IncidentCategoryEnumSerializer
    implements PrimitiveSerializer<IncidentCategoryEnum> {
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
  final Iterable<Type> types = const <Type>[IncidentCategoryEnum];
  @override
  final String wireName = 'IncidentCategoryEnum';

  @override
  Object serialize(Serializers serializers, IncidentCategoryEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  IncidentCategoryEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      IncidentCategoryEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$IncidentStatusEnumSerializer
    implements PrimitiveSerializer<IncidentStatusEnum> {
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
  final Iterable<Type> types = const <Type>[IncidentStatusEnum];
  @override
  final String wireName = 'IncidentStatusEnum';

  @override
  Object serialize(Serializers serializers, IncidentStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  IncidentStatusEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      IncidentStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$Incident extends Incident {
  @override
  final String id;
  @override
  final String? tripId;
  @override
  final String? vehicleId;
  @override
  final IncidentCategoryEnum category;
  @override
  final String? note;
  @override
  final IncidentLocation? location;
  @override
  final IncidentStatusEnum status;
  @override
  final String? resolution;
  @override
  final DateTime createdAt;

  factory _$Incident([void Function(IncidentBuilder)? updates]) =>
      (IncidentBuilder()..update(updates))._build();

  _$Incident._(
      {required this.id,
      this.tripId,
      this.vehicleId,
      required this.category,
      this.note,
      this.location,
      required this.status,
      this.resolution,
      required this.createdAt})
      : super._();
  @override
  Incident rebuild(void Function(IncidentBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  IncidentBuilder toBuilder() => IncidentBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Incident &&
        id == other.id &&
        tripId == other.tripId &&
        vehicleId == other.vehicleId &&
        category == other.category &&
        note == other.note &&
        location == other.location &&
        status == other.status &&
        resolution == other.resolution &&
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
    _$hash = $jc(_$hash, location.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, resolution.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Incident')
          ..add('id', id)
          ..add('tripId', tripId)
          ..add('vehicleId', vehicleId)
          ..add('category', category)
          ..add('note', note)
          ..add('location', location)
          ..add('status', status)
          ..add('resolution', resolution)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class IncidentBuilder implements Builder<Incident, IncidentBuilder> {
  _$Incident? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _tripId;
  String? get tripId => _$this._tripId;
  set tripId(String? tripId) => _$this._tripId = tripId;

  String? _vehicleId;
  String? get vehicleId => _$this._vehicleId;
  set vehicleId(String? vehicleId) => _$this._vehicleId = vehicleId;

  IncidentCategoryEnum? _category;
  IncidentCategoryEnum? get category => _$this._category;
  set category(IncidentCategoryEnum? category) => _$this._category = category;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  IncidentLocationBuilder? _location;
  IncidentLocationBuilder get location =>
      _$this._location ??= IncidentLocationBuilder();
  set location(IncidentLocationBuilder? location) =>
      _$this._location = location;

  IncidentStatusEnum? _status;
  IncidentStatusEnum? get status => _$this._status;
  set status(IncidentStatusEnum? status) => _$this._status = status;

  String? _resolution;
  String? get resolution => _$this._resolution;
  set resolution(String? resolution) => _$this._resolution = resolution;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  IncidentBuilder() {
    Incident._defaults(this);
  }

  IncidentBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _tripId = $v.tripId;
      _vehicleId = $v.vehicleId;
      _category = $v.category;
      _note = $v.note;
      _location = $v.location?.toBuilder();
      _status = $v.status;
      _resolution = $v.resolution;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Incident other) {
    _$v = other as _$Incident;
  }

  @override
  void update(void Function(IncidentBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Incident build() => _build();

  _$Incident _build() {
    _$Incident _$result;
    try {
      _$result = _$v ??
          _$Incident._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'Incident', 'id'),
            tripId: tripId,
            vehicleId: vehicleId,
            category: BuiltValueNullFieldError.checkNotNull(
                category, r'Incident', 'category'),
            note: note,
            location: _location?.build(),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'Incident', 'status'),
            resolution: resolution,
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'Incident', 'createdAt'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'location';
        _location?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'Incident', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
