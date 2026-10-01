// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rider_notification.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const RiderNotificationKindEnum _$riderNotificationKindEnum_seatAsk =
    const RiderNotificationKindEnum._('seatAsk');
const RiderNotificationKindEnum _$riderNotificationKindEnum_seatHeld =
    const RiderNotificationKindEnum._('seatHeld');
const RiderNotificationKindEnum _$riderNotificationKindEnum_seatUnseated =
    const RiderNotificationKindEnum._('seatUnseated');
const RiderNotificationKindEnum _$riderNotificationKindEnum_rideUsed =
    const RiderNotificationKindEnum._('rideUsed');
const RiderNotificationKindEnum _$riderNotificationKindEnum_creditConverted =
    const RiderNotificationKindEnum._('creditConverted');
const RiderNotificationKindEnum _$riderNotificationKindEnum_tripChanged =
    const RiderNotificationKindEnum._('tripChanged');
const RiderNotificationKindEnum _$riderNotificationKindEnum_tripCancelled =
    const RiderNotificationKindEnum._('tripCancelled');
const RiderNotificationKindEnum _$riderNotificationKindEnum_standbyOffered =
    const RiderNotificationKindEnum._('standbyOffered');

RiderNotificationKindEnum _$riderNotificationKindEnumValueOf(String name) {
  switch (name) {
    case 'seatAsk':
      return _$riderNotificationKindEnum_seatAsk;
    case 'seatHeld':
      return _$riderNotificationKindEnum_seatHeld;
    case 'seatUnseated':
      return _$riderNotificationKindEnum_seatUnseated;
    case 'rideUsed':
      return _$riderNotificationKindEnum_rideUsed;
    case 'creditConverted':
      return _$riderNotificationKindEnum_creditConverted;
    case 'tripChanged':
      return _$riderNotificationKindEnum_tripChanged;
    case 'tripCancelled':
      return _$riderNotificationKindEnum_tripCancelled;
    case 'standbyOffered':
      return _$riderNotificationKindEnum_standbyOffered;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<RiderNotificationKindEnum> _$riderNotificationKindEnumValues =
    BuiltSet<RiderNotificationKindEnum>(const <RiderNotificationKindEnum>[
  _$riderNotificationKindEnum_seatAsk,
  _$riderNotificationKindEnum_seatHeld,
  _$riderNotificationKindEnum_seatUnseated,
  _$riderNotificationKindEnum_rideUsed,
  _$riderNotificationKindEnum_creditConverted,
  _$riderNotificationKindEnum_tripChanged,
  _$riderNotificationKindEnum_tripCancelled,
  _$riderNotificationKindEnum_standbyOffered,
]);

Serializer<RiderNotificationKindEnum> _$riderNotificationKindEnumSerializer =
    _$RiderNotificationKindEnumSerializer();

class _$RiderNotificationKindEnumSerializer
    implements PrimitiveSerializer<RiderNotificationKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'seatAsk': 'seat_ask',
    'seatHeld': 'seat_held',
    'seatUnseated': 'seat_unseated',
    'rideUsed': 'ride_used',
    'creditConverted': 'credit_converted',
    'tripChanged': 'trip_changed',
    'tripCancelled': 'trip_cancelled',
    'standbyOffered': 'standby_offered',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'seat_ask': 'seatAsk',
    'seat_held': 'seatHeld',
    'seat_unseated': 'seatUnseated',
    'ride_used': 'rideUsed',
    'credit_converted': 'creditConverted',
    'trip_changed': 'tripChanged',
    'trip_cancelled': 'tripCancelled',
    'standby_offered': 'standbyOffered',
  };

  @override
  final Iterable<Type> types = const <Type>[RiderNotificationKindEnum];
  @override
  final String wireName = 'RiderNotificationKindEnum';

  @override
  Object serialize(Serializers serializers, RiderNotificationKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  RiderNotificationKindEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      RiderNotificationKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$RiderNotification extends RiderNotification {
  @override
  final String id;
  @override
  final RiderNotificationKindEnum kind;
  @override
  final RiderNotificationTarget target;
  @override
  final DateTime createdAt;
  @override
  final DateTime? readAt;

  factory _$RiderNotification(
          [void Function(RiderNotificationBuilder)? updates]) =>
      (RiderNotificationBuilder()..update(updates))._build();

  _$RiderNotification._(
      {required this.id,
      required this.kind,
      required this.target,
      required this.createdAt,
      this.readAt})
      : super._();
  @override
  RiderNotification rebuild(void Function(RiderNotificationBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RiderNotificationBuilder toBuilder() =>
      RiderNotificationBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RiderNotification &&
        id == other.id &&
        kind == other.kind &&
        target == other.target &&
        createdAt == other.createdAt &&
        readAt == other.readAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, target.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, readAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RiderNotification')
          ..add('id', id)
          ..add('kind', kind)
          ..add('target', target)
          ..add('createdAt', createdAt)
          ..add('readAt', readAt))
        .toString();
  }
}

class RiderNotificationBuilder
    implements Builder<RiderNotification, RiderNotificationBuilder> {
  _$RiderNotification? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  RiderNotificationKindEnum? _kind;
  RiderNotificationKindEnum? get kind => _$this._kind;
  set kind(RiderNotificationKindEnum? kind) => _$this._kind = kind;

  RiderNotificationTargetBuilder? _target;
  RiderNotificationTargetBuilder get target =>
      _$this._target ??= RiderNotificationTargetBuilder();
  set target(RiderNotificationTargetBuilder? target) => _$this._target = target;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _readAt;
  DateTime? get readAt => _$this._readAt;
  set readAt(DateTime? readAt) => _$this._readAt = readAt;

  RiderNotificationBuilder() {
    RiderNotification._defaults(this);
  }

  RiderNotificationBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _kind = $v.kind;
      _target = $v.target.toBuilder();
      _createdAt = $v.createdAt;
      _readAt = $v.readAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RiderNotification other) {
    _$v = other as _$RiderNotification;
  }

  @override
  void update(void Function(RiderNotificationBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RiderNotification build() => _build();

  _$RiderNotification _build() {
    _$RiderNotification _$result;
    try {
      _$result = _$v ??
          _$RiderNotification._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'RiderNotification', 'id'),
            kind: BuiltValueNullFieldError.checkNotNull(
                kind, r'RiderNotification', 'kind'),
            target: target.build(),
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'RiderNotification', 'createdAt'),
            readAt: readAt,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'target';
        target.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'RiderNotification', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
