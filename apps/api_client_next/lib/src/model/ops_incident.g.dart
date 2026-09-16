// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ops_incident.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const OpsIncidentCategoryEnum _$opsIncidentCategoryEnum_vehicle =
    const OpsIncidentCategoryEnum._('vehicle');
const OpsIncidentCategoryEnum _$opsIncidentCategoryEnum_collision =
    const OpsIncidentCategoryEnum._('collision');
const OpsIncidentCategoryEnum _$opsIncidentCategoryEnum_passengerSafety =
    const OpsIncidentCategoryEnum._('passengerSafety');
const OpsIncidentCategoryEnum _$opsIncidentCategoryEnum_routeBlocked =
    const OpsIncidentCategoryEnum._('routeBlocked');
const OpsIncidentCategoryEnum _$opsIncidentCategoryEnum_other =
    const OpsIncidentCategoryEnum._('other');

OpsIncidentCategoryEnum _$opsIncidentCategoryEnumValueOf(String name) {
  switch (name) {
    case 'vehicle':
      return _$opsIncidentCategoryEnum_vehicle;
    case 'collision':
      return _$opsIncidentCategoryEnum_collision;
    case 'passengerSafety':
      return _$opsIncidentCategoryEnum_passengerSafety;
    case 'routeBlocked':
      return _$opsIncidentCategoryEnum_routeBlocked;
    case 'other':
      return _$opsIncidentCategoryEnum_other;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<OpsIncidentCategoryEnum> _$opsIncidentCategoryEnumValues =
    BuiltSet<OpsIncidentCategoryEnum>(const <OpsIncidentCategoryEnum>[
  _$opsIncidentCategoryEnum_vehicle,
  _$opsIncidentCategoryEnum_collision,
  _$opsIncidentCategoryEnum_passengerSafety,
  _$opsIncidentCategoryEnum_routeBlocked,
  _$opsIncidentCategoryEnum_other,
]);

const OpsIncidentStatusEnum _$opsIncidentStatusEnum_open =
    const OpsIncidentStatusEnum._('open');
const OpsIncidentStatusEnum _$opsIncidentStatusEnum_acknowledged =
    const OpsIncidentStatusEnum._('acknowledged');
const OpsIncidentStatusEnum _$opsIncidentStatusEnum_resolved =
    const OpsIncidentStatusEnum._('resolved');

OpsIncidentStatusEnum _$opsIncidentStatusEnumValueOf(String name) {
  switch (name) {
    case 'open':
      return _$opsIncidentStatusEnum_open;
    case 'acknowledged':
      return _$opsIncidentStatusEnum_acknowledged;
    case 'resolved':
      return _$opsIncidentStatusEnum_resolved;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<OpsIncidentStatusEnum> _$opsIncidentStatusEnumValues =
    BuiltSet<OpsIncidentStatusEnum>(const <OpsIncidentStatusEnum>[
  _$opsIncidentStatusEnum_open,
  _$opsIncidentStatusEnum_acknowledged,
  _$opsIncidentStatusEnum_resolved,
]);

Serializer<OpsIncidentCategoryEnum> _$opsIncidentCategoryEnumSerializer =
    _$OpsIncidentCategoryEnumSerializer();
Serializer<OpsIncidentStatusEnum> _$opsIncidentStatusEnumSerializer =
    _$OpsIncidentStatusEnumSerializer();

class _$OpsIncidentCategoryEnumSerializer
    implements PrimitiveSerializer<OpsIncidentCategoryEnum> {
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
  final Iterable<Type> types = const <Type>[OpsIncidentCategoryEnum];
  @override
  final String wireName = 'OpsIncidentCategoryEnum';

  @override
  Object serialize(Serializers serializers, OpsIncidentCategoryEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  OpsIncidentCategoryEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      OpsIncidentCategoryEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$OpsIncidentStatusEnumSerializer
    implements PrimitiveSerializer<OpsIncidentStatusEnum> {
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
  final Iterable<Type> types = const <Type>[OpsIncidentStatusEnum];
  @override
  final String wireName = 'OpsIncidentStatusEnum';

  @override
  Object serialize(Serializers serializers, OpsIncidentStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  OpsIncidentStatusEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      OpsIncidentStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$OpsIncident extends OpsIncident {
  @override
  final String id;
  @override
  final String? tripId;
  @override
  final String? vehicleId;
  @override
  final OpsIncidentCategoryEnum category;
  @override
  final String? note;
  @override
  final IncidentLocation? location;
  @override
  final OpsIncidentStatusEnum status;
  @override
  final String? resolution;
  @override
  final DateTime createdAt;
  @override
  final String driverId;
  @override
  final String? handledBy;
  @override
  final DateTime? handledAt;
  @override
  final int version;
  @override
  final String editToken;

  factory _$OpsIncident([void Function(OpsIncidentBuilder)? updates]) =>
      (OpsIncidentBuilder()..update(updates))._build();

  _$OpsIncident._(
      {required this.id,
      this.tripId,
      this.vehicleId,
      required this.category,
      this.note,
      this.location,
      required this.status,
      this.resolution,
      required this.createdAt,
      required this.driverId,
      this.handledBy,
      this.handledAt,
      required this.version,
      required this.editToken})
      : super._();
  @override
  OpsIncident rebuild(void Function(OpsIncidentBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OpsIncidentBuilder toBuilder() => OpsIncidentBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OpsIncident &&
        id == other.id &&
        tripId == other.tripId &&
        vehicleId == other.vehicleId &&
        category == other.category &&
        note == other.note &&
        location == other.location &&
        status == other.status &&
        resolution == other.resolution &&
        createdAt == other.createdAt &&
        driverId == other.driverId &&
        handledBy == other.handledBy &&
        handledAt == other.handledAt &&
        version == other.version &&
        editToken == other.editToken;
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
    _$hash = $jc(_$hash, driverId.hashCode);
    _$hash = $jc(_$hash, handledBy.hashCode);
    _$hash = $jc(_$hash, handledAt.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jc(_$hash, editToken.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OpsIncident')
          ..add('id', id)
          ..add('tripId', tripId)
          ..add('vehicleId', vehicleId)
          ..add('category', category)
          ..add('note', note)
          ..add('location', location)
          ..add('status', status)
          ..add('resolution', resolution)
          ..add('createdAt', createdAt)
          ..add('driverId', driverId)
          ..add('handledBy', handledBy)
          ..add('handledAt', handledAt)
          ..add('version', version)
          ..add('editToken', editToken))
        .toString();
  }
}

class OpsIncidentBuilder implements Builder<OpsIncident, OpsIncidentBuilder> {
  _$OpsIncident? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _tripId;
  String? get tripId => _$this._tripId;
  set tripId(String? tripId) => _$this._tripId = tripId;

  String? _vehicleId;
  String? get vehicleId => _$this._vehicleId;
  set vehicleId(String? vehicleId) => _$this._vehicleId = vehicleId;

  OpsIncidentCategoryEnum? _category;
  OpsIncidentCategoryEnum? get category => _$this._category;
  set category(OpsIncidentCategoryEnum? category) =>
      _$this._category = category;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  IncidentLocationBuilder? _location;
  IncidentLocationBuilder get location =>
      _$this._location ??= IncidentLocationBuilder();
  set location(IncidentLocationBuilder? location) =>
      _$this._location = location;

  OpsIncidentStatusEnum? _status;
  OpsIncidentStatusEnum? get status => _$this._status;
  set status(OpsIncidentStatusEnum? status) => _$this._status = status;

  String? _resolution;
  String? get resolution => _$this._resolution;
  set resolution(String? resolution) => _$this._resolution = resolution;

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

  int? _version;
  int? get version => _$this._version;
  set version(int? version) => _$this._version = version;

  String? _editToken;
  String? get editToken => _$this._editToken;
  set editToken(String? editToken) => _$this._editToken = editToken;

  OpsIncidentBuilder() {
    OpsIncident._defaults(this);
  }

  OpsIncidentBuilder get _$this {
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
      _driverId = $v.driverId;
      _handledBy = $v.handledBy;
      _handledAt = $v.handledAt;
      _version = $v.version;
      _editToken = $v.editToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OpsIncident other) {
    _$v = other as _$OpsIncident;
  }

  @override
  void update(void Function(OpsIncidentBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OpsIncident build() => _build();

  _$OpsIncident _build() {
    _$OpsIncident _$result;
    try {
      _$result = _$v ??
          _$OpsIncident._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'OpsIncident', 'id'),
            tripId: tripId,
            vehicleId: vehicleId,
            category: BuiltValueNullFieldError.checkNotNull(
                category, r'OpsIncident', 'category'),
            note: note,
            location: _location?.build(),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'OpsIncident', 'status'),
            resolution: resolution,
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'OpsIncident', 'createdAt'),
            driverId: BuiltValueNullFieldError.checkNotNull(
                driverId, r'OpsIncident', 'driverId'),
            handledBy: handledBy,
            handledAt: handledAt,
            version: BuiltValueNullFieldError.checkNotNull(
                version, r'OpsIncident', 'version'),
            editToken: BuiltValueNullFieldError.checkNotNull(
                editToken, r'OpsIncident', 'editToken'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'location';
        _location?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'OpsIncident', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
