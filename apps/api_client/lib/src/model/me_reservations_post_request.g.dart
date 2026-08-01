// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'me_reservations_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MeReservationsPostRequestDirectionEnum
    _$meReservationsPostRequestDirectionEnum_morning =
    const MeReservationsPostRequestDirectionEnum._('morning');
const MeReservationsPostRequestDirectionEnum
    _$meReservationsPostRequestDirectionEnum_evening =
    const MeReservationsPostRequestDirectionEnum._('evening');

MeReservationsPostRequestDirectionEnum
    _$meReservationsPostRequestDirectionEnumValueOf(String name) {
  switch (name) {
    case 'morning':
      return _$meReservationsPostRequestDirectionEnum_morning;
    case 'evening':
      return _$meReservationsPostRequestDirectionEnum_evening;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<MeReservationsPostRequestDirectionEnum>
    _$meReservationsPostRequestDirectionEnumValues = BuiltSet<
        MeReservationsPostRequestDirectionEnum>(const <MeReservationsPostRequestDirectionEnum>[
  _$meReservationsPostRequestDirectionEnum_morning,
  _$meReservationsPostRequestDirectionEnum_evening,
]);

Serializer<MeReservationsPostRequestDirectionEnum>
    _$meReservationsPostRequestDirectionEnumSerializer =
    _$MeReservationsPostRequestDirectionEnumSerializer();

class _$MeReservationsPostRequestDirectionEnumSerializer
    implements PrimitiveSerializer<MeReservationsPostRequestDirectionEnum> {
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
    MeReservationsPostRequestDirectionEnum
  ];
  @override
  final String wireName = 'MeReservationsPostRequestDirectionEnum';

  @override
  Object serialize(Serializers serializers,
          MeReservationsPostRequestDirectionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  MeReservationsPostRequestDirectionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      MeReservationsPostRequestDirectionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$MeReservationsPostRequest extends MeReservationsPostRequest {
  @override
  final String? tripId;
  @override
  final String travelDate;
  @override
  final MeReservationsPostRequestDirectionEnum direction;
  @override
  final bool travelling;

  factory _$MeReservationsPostRequest(
          [void Function(MeReservationsPostRequestBuilder)? updates]) =>
      (MeReservationsPostRequestBuilder()..update(updates))._build();

  _$MeReservationsPostRequest._(
      {this.tripId,
      required this.travelDate,
      required this.direction,
      required this.travelling})
      : super._();
  @override
  MeReservationsPostRequest rebuild(
          void Function(MeReservationsPostRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MeReservationsPostRequestBuilder toBuilder() =>
      MeReservationsPostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MeReservationsPostRequest &&
        tripId == other.tripId &&
        travelDate == other.travelDate &&
        direction == other.direction &&
        travelling == other.travelling;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, tripId.hashCode);
    _$hash = $jc(_$hash, travelDate.hashCode);
    _$hash = $jc(_$hash, direction.hashCode);
    _$hash = $jc(_$hash, travelling.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MeReservationsPostRequest')
          ..add('tripId', tripId)
          ..add('travelDate', travelDate)
          ..add('direction', direction)
          ..add('travelling', travelling))
        .toString();
  }
}

class MeReservationsPostRequestBuilder
    implements
        Builder<MeReservationsPostRequest, MeReservationsPostRequestBuilder> {
  _$MeReservationsPostRequest? _$v;

  String? _tripId;
  String? get tripId => _$this._tripId;
  set tripId(String? tripId) => _$this._tripId = tripId;

  String? _travelDate;
  String? get travelDate => _$this._travelDate;
  set travelDate(String? travelDate) => _$this._travelDate = travelDate;

  MeReservationsPostRequestDirectionEnum? _direction;
  MeReservationsPostRequestDirectionEnum? get direction => _$this._direction;
  set direction(MeReservationsPostRequestDirectionEnum? direction) =>
      _$this._direction = direction;

  bool? _travelling;
  bool? get travelling => _$this._travelling;
  set travelling(bool? travelling) => _$this._travelling = travelling;

  MeReservationsPostRequestBuilder() {
    MeReservationsPostRequest._defaults(this);
  }

  MeReservationsPostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _tripId = $v.tripId;
      _travelDate = $v.travelDate;
      _direction = $v.direction;
      _travelling = $v.travelling;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MeReservationsPostRequest other) {
    _$v = other as _$MeReservationsPostRequest;
  }

  @override
  void update(void Function(MeReservationsPostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MeReservationsPostRequest build() => _build();

  _$MeReservationsPostRequest _build() {
    final _$result = _$v ??
        _$MeReservationsPostRequest._(
          tripId: tripId,
          travelDate: BuiltValueNullFieldError.checkNotNull(
              travelDate, r'MeReservationsPostRequest', 'travelDate'),
          direction: BuiltValueNullFieldError.checkNotNull(
              direction, r'MeReservationsPostRequest', 'direction'),
          travelling: BuiltValueNullFieldError.checkNotNull(
              travelling, r'MeReservationsPostRequest', 'travelling'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
