// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rider_notification_target.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const RiderNotificationTargetTypeEnum
    _$riderNotificationTargetTypeEnum_reservation =
    const RiderNotificationTargetTypeEnum._('reservation');
const RiderNotificationTargetTypeEnum _$riderNotificationTargetTypeEnum_credit =
    const RiderNotificationTargetTypeEnum._('credit');
const RiderNotificationTargetTypeEnum
    _$riderNotificationTargetTypeEnum_standby =
    const RiderNotificationTargetTypeEnum._('standby');

RiderNotificationTargetTypeEnum _$riderNotificationTargetTypeEnumValueOf(
    String name) {
  switch (name) {
    case 'reservation':
      return _$riderNotificationTargetTypeEnum_reservation;
    case 'credit':
      return _$riderNotificationTargetTypeEnum_credit;
    case 'standby':
      return _$riderNotificationTargetTypeEnum_standby;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<RiderNotificationTargetTypeEnum>
    _$riderNotificationTargetTypeEnumValues = BuiltSet<
        RiderNotificationTargetTypeEnum>(const <RiderNotificationTargetTypeEnum>[
  _$riderNotificationTargetTypeEnum_reservation,
  _$riderNotificationTargetTypeEnum_credit,
  _$riderNotificationTargetTypeEnum_standby,
]);

Serializer<RiderNotificationTargetTypeEnum>
    _$riderNotificationTargetTypeEnumSerializer =
    _$RiderNotificationTargetTypeEnumSerializer();

class _$RiderNotificationTargetTypeEnumSerializer
    implements PrimitiveSerializer<RiderNotificationTargetTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'reservation': 'reservation',
    'credit': 'credit',
    'standby': 'standby',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'reservation': 'reservation',
    'credit': 'credit',
    'standby': 'standby',
  };

  @override
  final Iterable<Type> types = const <Type>[RiderNotificationTargetTypeEnum];
  @override
  final String wireName = 'RiderNotificationTargetTypeEnum';

  @override
  Object serialize(
          Serializers serializers, RiderNotificationTargetTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  RiderNotificationTargetTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      RiderNotificationTargetTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$RiderNotificationTarget extends RiderNotificationTarget {
  @override
  final RiderNotificationTargetTypeEnum type;
  @override
  final String id;

  factory _$RiderNotificationTarget(
          [void Function(RiderNotificationTargetBuilder)? updates]) =>
      (RiderNotificationTargetBuilder()..update(updates))._build();

  _$RiderNotificationTarget._({required this.type, required this.id})
      : super._();
  @override
  RiderNotificationTarget rebuild(
          void Function(RiderNotificationTargetBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RiderNotificationTargetBuilder toBuilder() =>
      RiderNotificationTargetBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RiderNotificationTarget &&
        type == other.type &&
        id == other.id;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RiderNotificationTarget')
          ..add('type', type)
          ..add('id', id))
        .toString();
  }
}

class RiderNotificationTargetBuilder
    implements
        Builder<RiderNotificationTarget, RiderNotificationTargetBuilder> {
  _$RiderNotificationTarget? _$v;

  RiderNotificationTargetTypeEnum? _type;
  RiderNotificationTargetTypeEnum? get type => _$this._type;
  set type(RiderNotificationTargetTypeEnum? type) => _$this._type = type;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  RiderNotificationTargetBuilder() {
    RiderNotificationTarget._defaults(this);
  }

  RiderNotificationTargetBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _type = $v.type;
      _id = $v.id;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RiderNotificationTarget other) {
    _$v = other as _$RiderNotificationTarget;
  }

  @override
  void update(void Function(RiderNotificationTargetBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RiderNotificationTarget build() => _build();

  _$RiderNotificationTarget _build() {
    final _$result = _$v ??
        _$RiderNotificationTarget._(
          type: BuiltValueNullFieldError.checkNotNull(
              type, r'RiderNotificationTarget', 'type'),
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'RiderNotificationTarget', 'id'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
