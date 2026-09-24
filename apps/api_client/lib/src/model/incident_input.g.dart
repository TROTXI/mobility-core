// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'incident_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const IncidentInputCategoryEnum _$incidentInputCategoryEnum_vehicle =
    const IncidentInputCategoryEnum._('vehicle');
const IncidentInputCategoryEnum _$incidentInputCategoryEnum_collision =
    const IncidentInputCategoryEnum._('collision');
const IncidentInputCategoryEnum _$incidentInputCategoryEnum_passengerSafety =
    const IncidentInputCategoryEnum._('passengerSafety');
const IncidentInputCategoryEnum _$incidentInputCategoryEnum_routeBlocked =
    const IncidentInputCategoryEnum._('routeBlocked');
const IncidentInputCategoryEnum _$incidentInputCategoryEnum_other =
    const IncidentInputCategoryEnum._('other');

IncidentInputCategoryEnum _$incidentInputCategoryEnumValueOf(String name) {
  switch (name) {
    case 'vehicle':
      return _$incidentInputCategoryEnum_vehicle;
    case 'collision':
      return _$incidentInputCategoryEnum_collision;
    case 'passengerSafety':
      return _$incidentInputCategoryEnum_passengerSafety;
    case 'routeBlocked':
      return _$incidentInputCategoryEnum_routeBlocked;
    case 'other':
      return _$incidentInputCategoryEnum_other;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<IncidentInputCategoryEnum> _$incidentInputCategoryEnumValues =
    BuiltSet<IncidentInputCategoryEnum>(const <IncidentInputCategoryEnum>[
  _$incidentInputCategoryEnum_vehicle,
  _$incidentInputCategoryEnum_collision,
  _$incidentInputCategoryEnum_passengerSafety,
  _$incidentInputCategoryEnum_routeBlocked,
  _$incidentInputCategoryEnum_other,
]);

Serializer<IncidentInputCategoryEnum> _$incidentInputCategoryEnumSerializer =
    _$IncidentInputCategoryEnumSerializer();

class _$IncidentInputCategoryEnumSerializer
    implements PrimitiveSerializer<IncidentInputCategoryEnum> {
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
  final Iterable<Type> types = const <Type>[IncidentInputCategoryEnum];
  @override
  final String wireName = 'IncidentInputCategoryEnum';

  @override
  Object serialize(Serializers serializers, IncidentInputCategoryEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  IncidentInputCategoryEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      IncidentInputCategoryEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$IncidentInput extends IncidentInput {
  @override
  final String? tripId;
  @override
  final IncidentInputCategoryEnum category;
  @override
  final String? note;
  @override
  final Point? location;

  factory _$IncidentInput([void Function(IncidentInputBuilder)? updates]) =>
      (IncidentInputBuilder()..update(updates))._build();

  _$IncidentInput._(
      {this.tripId, required this.category, this.note, this.location})
      : super._();
  @override
  IncidentInput rebuild(void Function(IncidentInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  IncidentInputBuilder toBuilder() => IncidentInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is IncidentInput &&
        tripId == other.tripId &&
        category == other.category &&
        note == other.note &&
        location == other.location;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, tripId.hashCode);
    _$hash = $jc(_$hash, category.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, location.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'IncidentInput')
          ..add('tripId', tripId)
          ..add('category', category)
          ..add('note', note)
          ..add('location', location))
        .toString();
  }
}

class IncidentInputBuilder
    implements Builder<IncidentInput, IncidentInputBuilder> {
  _$IncidentInput? _$v;

  String? _tripId;
  String? get tripId => _$this._tripId;
  set tripId(String? tripId) => _$this._tripId = tripId;

  IncidentInputCategoryEnum? _category;
  IncidentInputCategoryEnum? get category => _$this._category;
  set category(IncidentInputCategoryEnum? category) =>
      _$this._category = category;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  PointBuilder? _location;
  PointBuilder get location => _$this._location ??= PointBuilder();
  set location(PointBuilder? location) => _$this._location = location;

  IncidentInputBuilder() {
    IncidentInput._defaults(this);
  }

  IncidentInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _tripId = $v.tripId;
      _category = $v.category;
      _note = $v.note;
      _location = $v.location?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(IncidentInput other) {
    _$v = other as _$IncidentInput;
  }

  @override
  void update(void Function(IncidentInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  IncidentInput build() => _build();

  _$IncidentInput _build() {
    _$IncidentInput _$result;
    try {
      _$result = _$v ??
          _$IncidentInput._(
            tripId: tripId,
            category: BuiltValueNullFieldError.checkNotNull(
                category, r'IncidentInput', 'category'),
            note: note,
            location: _location?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'location';
        _location?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'IncidentInput', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
