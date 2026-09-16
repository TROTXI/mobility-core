// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ReservationDirectionEnum _$reservationDirectionEnum_outbound =
    const ReservationDirectionEnum._('outbound');
const ReservationDirectionEnum _$reservationDirectionEnum_return_ =
    const ReservationDirectionEnum._('return_');

ReservationDirectionEnum _$reservationDirectionEnumValueOf(String name) {
  switch (name) {
    case 'outbound':
      return _$reservationDirectionEnum_outbound;
    case 'return_':
      return _$reservationDirectionEnum_return_;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ReservationDirectionEnum> _$reservationDirectionEnumValues =
    BuiltSet<ReservationDirectionEnum>(const <ReservationDirectionEnum>[
  _$reservationDirectionEnum_outbound,
  _$reservationDirectionEnum_return_,
]);

const ReservationStatusEnum _$reservationStatusEnum_pending =
    const ReservationStatusEnum._('pending');
const ReservationStatusEnum _$reservationStatusEnum_reserved =
    const ReservationStatusEnum._('reserved');
const ReservationStatusEnum _$reservationStatusEnum_declined =
    const ReservationStatusEnum._('declined');
const ReservationStatusEnum _$reservationStatusEnum_unseated =
    const ReservationStatusEnum._('unseated');
const ReservationStatusEnum _$reservationStatusEnum_boarded =
    const ReservationStatusEnum._('boarded');
const ReservationStatusEnum _$reservationStatusEnum_noShow =
    const ReservationStatusEnum._('noShow');
const ReservationStatusEnum _$reservationStatusEnum_operatorCancelled =
    const ReservationStatusEnum._('operatorCancelled');

ReservationStatusEnum _$reservationStatusEnumValueOf(String name) {
  switch (name) {
    case 'pending':
      return _$reservationStatusEnum_pending;
    case 'reserved':
      return _$reservationStatusEnum_reserved;
    case 'declined':
      return _$reservationStatusEnum_declined;
    case 'unseated':
      return _$reservationStatusEnum_unseated;
    case 'boarded':
      return _$reservationStatusEnum_boarded;
    case 'noShow':
      return _$reservationStatusEnum_noShow;
    case 'operatorCancelled':
      return _$reservationStatusEnum_operatorCancelled;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ReservationStatusEnum> _$reservationStatusEnumValues =
    BuiltSet<ReservationStatusEnum>(const <ReservationStatusEnum>[
  _$reservationStatusEnum_pending,
  _$reservationStatusEnum_reserved,
  _$reservationStatusEnum_declined,
  _$reservationStatusEnum_unseated,
  _$reservationStatusEnum_boarded,
  _$reservationStatusEnum_noShow,
  _$reservationStatusEnum_operatorCancelled,
]);

const ReservationSource_Enum _$reservationSourceEnum_confirmation =
    const ReservationSource_Enum._('confirmation');
const ReservationSource_Enum _$reservationSourceEnum_default_ =
    const ReservationSource_Enum._('default_');

ReservationSource_Enum _$reservationSourceEnumValueOf(String name) {
  switch (name) {
    case 'confirmation':
      return _$reservationSourceEnum_confirmation;
    case 'default_':
      return _$reservationSourceEnum_default_;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ReservationSource_Enum> _$reservationSourceEnumValues =
    BuiltSet<ReservationSource_Enum>(const <ReservationSource_Enum>[
  _$reservationSourceEnum_confirmation,
  _$reservationSourceEnum_default_,
]);

Serializer<ReservationDirectionEnum> _$reservationDirectionEnumSerializer =
    _$ReservationDirectionEnumSerializer();
Serializer<ReservationStatusEnum> _$reservationStatusEnumSerializer =
    _$ReservationStatusEnumSerializer();
Serializer<ReservationSource_Enum> _$reservationSourceEnumSerializer =
    _$ReservationSource_EnumSerializer();

class _$ReservationDirectionEnumSerializer
    implements PrimitiveSerializer<ReservationDirectionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'outbound': 'outbound',
    'return_': 'return',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'outbound': 'outbound',
    'return': 'return_',
  };

  @override
  final Iterable<Type> types = const <Type>[ReservationDirectionEnum];
  @override
  final String wireName = 'ReservationDirectionEnum';

  @override
  Object serialize(Serializers serializers, ReservationDirectionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ReservationDirectionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ReservationDirectionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ReservationStatusEnumSerializer
    implements PrimitiveSerializer<ReservationStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'pending': 'pending',
    'reserved': 'reserved',
    'declined': 'declined',
    'unseated': 'unseated',
    'boarded': 'boarded',
    'noShow': 'no_show',
    'operatorCancelled': 'operator_cancelled',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'pending': 'pending',
    'reserved': 'reserved',
    'declined': 'declined',
    'unseated': 'unseated',
    'boarded': 'boarded',
    'no_show': 'noShow',
    'operator_cancelled': 'operatorCancelled',
  };

  @override
  final Iterable<Type> types = const <Type>[ReservationStatusEnum];
  @override
  final String wireName = 'ReservationStatusEnum';

  @override
  Object serialize(Serializers serializers, ReservationStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ReservationStatusEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ReservationStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ReservationSource_EnumSerializer
    implements PrimitiveSerializer<ReservationSource_Enum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'confirmation': 'confirmation',
    'default_': 'default',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'confirmation': 'confirmation',
    'default': 'default_',
  };

  @override
  final Iterable<Type> types = const <Type>[ReservationSource_Enum];
  @override
  final String wireName = 'ReservationSource_Enum';

  @override
  Object serialize(Serializers serializers, ReservationSource_Enum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ReservationSource_Enum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ReservationSource_Enum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$Reservation extends Reservation {
  @override
  final String id;
  @override
  final String? tripId;
  @override
  final Date travelDate;
  @override
  final ReservationDirectionEnum direction;
  @override
  final ReservationStatusEnum status;
  @override
  final String? pickupOccurrenceId;
  @override
  final String? dropoffOccurrenceId;
  @override
  final ReservationSource_Enum source_;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final int version;

  factory _$Reservation([void Function(ReservationBuilder)? updates]) =>
      (ReservationBuilder()..update(updates))._build();

  _$Reservation._(
      {required this.id,
      this.tripId,
      required this.travelDate,
      required this.direction,
      required this.status,
      this.pickupOccurrenceId,
      this.dropoffOccurrenceId,
      required this.source_,
      required this.createdAt,
      required this.updatedAt,
      required this.version})
      : super._();
  @override
  Reservation rebuild(void Function(ReservationBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReservationBuilder toBuilder() => ReservationBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Reservation &&
        id == other.id &&
        tripId == other.tripId &&
        travelDate == other.travelDate &&
        direction == other.direction &&
        status == other.status &&
        pickupOccurrenceId == other.pickupOccurrenceId &&
        dropoffOccurrenceId == other.dropoffOccurrenceId &&
        source_ == other.source_ &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        version == other.version;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, tripId.hashCode);
    _$hash = $jc(_$hash, travelDate.hashCode);
    _$hash = $jc(_$hash, direction.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, pickupOccurrenceId.hashCode);
    _$hash = $jc(_$hash, dropoffOccurrenceId.hashCode);
    _$hash = $jc(_$hash, source_.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Reservation')
          ..add('id', id)
          ..add('tripId', tripId)
          ..add('travelDate', travelDate)
          ..add('direction', direction)
          ..add('status', status)
          ..add('pickupOccurrenceId', pickupOccurrenceId)
          ..add('dropoffOccurrenceId', dropoffOccurrenceId)
          ..add('source_', source_)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt)
          ..add('version', version))
        .toString();
  }
}

class ReservationBuilder implements Builder<Reservation, ReservationBuilder> {
  _$Reservation? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _tripId;
  String? get tripId => _$this._tripId;
  set tripId(String? tripId) => _$this._tripId = tripId;

  Date? _travelDate;
  Date? get travelDate => _$this._travelDate;
  set travelDate(Date? travelDate) => _$this._travelDate = travelDate;

  ReservationDirectionEnum? _direction;
  ReservationDirectionEnum? get direction => _$this._direction;
  set direction(ReservationDirectionEnum? direction) =>
      _$this._direction = direction;

  ReservationStatusEnum? _status;
  ReservationStatusEnum? get status => _$this._status;
  set status(ReservationStatusEnum? status) => _$this._status = status;

  String? _pickupOccurrenceId;
  String? get pickupOccurrenceId => _$this._pickupOccurrenceId;
  set pickupOccurrenceId(String? pickupOccurrenceId) =>
      _$this._pickupOccurrenceId = pickupOccurrenceId;

  String? _dropoffOccurrenceId;
  String? get dropoffOccurrenceId => _$this._dropoffOccurrenceId;
  set dropoffOccurrenceId(String? dropoffOccurrenceId) =>
      _$this._dropoffOccurrenceId = dropoffOccurrenceId;

  ReservationSource_Enum? _source_;
  ReservationSource_Enum? get source_ => _$this._source_;
  set source_(ReservationSource_Enum? source_) => _$this._source_ = source_;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  int? _version;
  int? get version => _$this._version;
  set version(int? version) => _$this._version = version;

  ReservationBuilder() {
    Reservation._defaults(this);
  }

  ReservationBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _tripId = $v.tripId;
      _travelDate = $v.travelDate;
      _direction = $v.direction;
      _status = $v.status;
      _pickupOccurrenceId = $v.pickupOccurrenceId;
      _dropoffOccurrenceId = $v.dropoffOccurrenceId;
      _source_ = $v.source_;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _version = $v.version;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Reservation other) {
    _$v = other as _$Reservation;
  }

  @override
  void update(void Function(ReservationBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Reservation build() => _build();

  _$Reservation _build() {
    final _$result = _$v ??
        _$Reservation._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'Reservation', 'id'),
          tripId: tripId,
          travelDate: BuiltValueNullFieldError.checkNotNull(
              travelDate, r'Reservation', 'travelDate'),
          direction: BuiltValueNullFieldError.checkNotNull(
              direction, r'Reservation', 'direction'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'Reservation', 'status'),
          pickupOccurrenceId: pickupOccurrenceId,
          dropoffOccurrenceId: dropoffOccurrenceId,
          source_: BuiltValueNullFieldError.checkNotNull(
              source_, r'Reservation', 'source_'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'Reservation', 'createdAt'),
          updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt, r'Reservation', 'updatedAt'),
          version: BuiltValueNullFieldError.checkNotNull(
              version, r'Reservation', 'version'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
