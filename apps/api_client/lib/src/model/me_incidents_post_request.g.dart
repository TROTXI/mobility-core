// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'me_incidents_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MeIncidentsPostRequestCategoryEnum
    _$meIncidentsPostRequestCategoryEnum_vehicle =
    const MeIncidentsPostRequestCategoryEnum._('vehicle');
const MeIncidentsPostRequestCategoryEnum
    _$meIncidentsPostRequestCategoryEnum_collision =
    const MeIncidentsPostRequestCategoryEnum._('collision');
const MeIncidentsPostRequestCategoryEnum
    _$meIncidentsPostRequestCategoryEnum_passengerSafety =
    const MeIncidentsPostRequestCategoryEnum._('passengerSafety');
const MeIncidentsPostRequestCategoryEnum
    _$meIncidentsPostRequestCategoryEnum_routeBlocked =
    const MeIncidentsPostRequestCategoryEnum._('routeBlocked');
const MeIncidentsPostRequestCategoryEnum
    _$meIncidentsPostRequestCategoryEnum_other =
    const MeIncidentsPostRequestCategoryEnum._('other');

MeIncidentsPostRequestCategoryEnum _$meIncidentsPostRequestCategoryEnumValueOf(
    String name) {
  switch (name) {
    case 'vehicle':
      return _$meIncidentsPostRequestCategoryEnum_vehicle;
    case 'collision':
      return _$meIncidentsPostRequestCategoryEnum_collision;
    case 'passengerSafety':
      return _$meIncidentsPostRequestCategoryEnum_passengerSafety;
    case 'routeBlocked':
      return _$meIncidentsPostRequestCategoryEnum_routeBlocked;
    case 'other':
      return _$meIncidentsPostRequestCategoryEnum_other;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<MeIncidentsPostRequestCategoryEnum>
    _$meIncidentsPostRequestCategoryEnumValues = BuiltSet<
        MeIncidentsPostRequestCategoryEnum>(const <MeIncidentsPostRequestCategoryEnum>[
  _$meIncidentsPostRequestCategoryEnum_vehicle,
  _$meIncidentsPostRequestCategoryEnum_collision,
  _$meIncidentsPostRequestCategoryEnum_passengerSafety,
  _$meIncidentsPostRequestCategoryEnum_routeBlocked,
  _$meIncidentsPostRequestCategoryEnum_other,
]);

Serializer<MeIncidentsPostRequestCategoryEnum>
    _$meIncidentsPostRequestCategoryEnumSerializer =
    _$MeIncidentsPostRequestCategoryEnumSerializer();

class _$MeIncidentsPostRequestCategoryEnumSerializer
    implements PrimitiveSerializer<MeIncidentsPostRequestCategoryEnum> {
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
  final Iterable<Type> types = const <Type>[MeIncidentsPostRequestCategoryEnum];
  @override
  final String wireName = 'MeIncidentsPostRequestCategoryEnum';

  @override
  Object serialize(
          Serializers serializers, MeIncidentsPostRequestCategoryEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  MeIncidentsPostRequestCategoryEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      MeIncidentsPostRequestCategoryEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$MeIncidentsPostRequest extends MeIncidentsPostRequest {
  @override
  final String? tripId;
  @override
  final MeIncidentsPostRequestCategoryEnum category;
  @override
  final String? note;
  @override
  final num? lat;
  @override
  final num? lng;

  factory _$MeIncidentsPostRequest(
          [void Function(MeIncidentsPostRequestBuilder)? updates]) =>
      (MeIncidentsPostRequestBuilder()..update(updates))._build();

  _$MeIncidentsPostRequest._(
      {this.tripId, required this.category, this.note, this.lat, this.lng})
      : super._();
  @override
  MeIncidentsPostRequest rebuild(
          void Function(MeIncidentsPostRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MeIncidentsPostRequestBuilder toBuilder() =>
      MeIncidentsPostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MeIncidentsPostRequest &&
        tripId == other.tripId &&
        category == other.category &&
        note == other.note &&
        lat == other.lat &&
        lng == other.lng;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, tripId.hashCode);
    _$hash = $jc(_$hash, category.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, lat.hashCode);
    _$hash = $jc(_$hash, lng.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MeIncidentsPostRequest')
          ..add('tripId', tripId)
          ..add('category', category)
          ..add('note', note)
          ..add('lat', lat)
          ..add('lng', lng))
        .toString();
  }
}

class MeIncidentsPostRequestBuilder
    implements Builder<MeIncidentsPostRequest, MeIncidentsPostRequestBuilder> {
  _$MeIncidentsPostRequest? _$v;

  String? _tripId;
  String? get tripId => _$this._tripId;
  set tripId(String? tripId) => _$this._tripId = tripId;

  MeIncidentsPostRequestCategoryEnum? _category;
  MeIncidentsPostRequestCategoryEnum? get category => _$this._category;
  set category(MeIncidentsPostRequestCategoryEnum? category) =>
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

  MeIncidentsPostRequestBuilder() {
    MeIncidentsPostRequest._defaults(this);
  }

  MeIncidentsPostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _tripId = $v.tripId;
      _category = $v.category;
      _note = $v.note;
      _lat = $v.lat;
      _lng = $v.lng;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MeIncidentsPostRequest other) {
    _$v = other as _$MeIncidentsPostRequest;
  }

  @override
  void update(void Function(MeIncidentsPostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MeIncidentsPostRequest build() => _build();

  _$MeIncidentsPostRequest _build() {
    final _$result = _$v ??
        _$MeIncidentsPostRequest._(
          tripId: tripId,
          category: BuiltValueNullFieldError.checkNotNull(
              category, r'MeIncidentsPostRequest', 'category'),
          note: note,
          lat: lat,
          lng: lng,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
