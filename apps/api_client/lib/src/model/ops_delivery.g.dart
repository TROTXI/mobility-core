// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ops_delivery.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const OpsDeliveryChannelEnum _$opsDeliveryChannelEnum_email =
    const OpsDeliveryChannelEnum._('email');
const OpsDeliveryChannelEnum _$opsDeliveryChannelEnum_push =
    const OpsDeliveryChannelEnum._('push');

OpsDeliveryChannelEnum _$opsDeliveryChannelEnumValueOf(String name) {
  switch (name) {
    case 'email':
      return _$opsDeliveryChannelEnum_email;
    case 'push':
      return _$opsDeliveryChannelEnum_push;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<OpsDeliveryChannelEnum> _$opsDeliveryChannelEnumValues =
    BuiltSet<OpsDeliveryChannelEnum>(const <OpsDeliveryChannelEnum>[
  _$opsDeliveryChannelEnum_email,
  _$opsDeliveryChannelEnum_push,
]);

Serializer<OpsDeliveryChannelEnum> _$opsDeliveryChannelEnumSerializer =
    _$OpsDeliveryChannelEnumSerializer();

class _$OpsDeliveryChannelEnumSerializer
    implements PrimitiveSerializer<OpsDeliveryChannelEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'email': 'email',
    'push': 'push',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'email': 'email',
    'push': 'push',
  };

  @override
  final Iterable<Type> types = const <Type>[OpsDeliveryChannelEnum];
  @override
  final String wireName = 'OpsDeliveryChannelEnum';

  @override
  Object serialize(Serializers serializers, OpsDeliveryChannelEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  OpsDeliveryChannelEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      OpsDeliveryChannelEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$OpsDelivery extends OpsDelivery {
  @override
  final String id;
  @override
  final OpsDeliveryChannelEnum channel;
  @override
  final String kind;
  @override
  final String userId;
  @override
  final String state;
  @override
  final int attempts;
  @override
  final String? providerId;
  @override
  final String? failureCode;
  @override
  final DateTime createdAt;

  factory _$OpsDelivery([void Function(OpsDeliveryBuilder)? updates]) =>
      (OpsDeliveryBuilder()..update(updates))._build();

  _$OpsDelivery._(
      {required this.id,
      required this.channel,
      required this.kind,
      required this.userId,
      required this.state,
      required this.attempts,
      this.providerId,
      this.failureCode,
      required this.createdAt})
      : super._();
  @override
  OpsDelivery rebuild(void Function(OpsDeliveryBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OpsDeliveryBuilder toBuilder() => OpsDeliveryBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OpsDelivery &&
        id == other.id &&
        channel == other.channel &&
        kind == other.kind &&
        userId == other.userId &&
        state == other.state &&
        attempts == other.attempts &&
        providerId == other.providerId &&
        failureCode == other.failureCode &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, channel.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, state.hashCode);
    _$hash = $jc(_$hash, attempts.hashCode);
    _$hash = $jc(_$hash, providerId.hashCode);
    _$hash = $jc(_$hash, failureCode.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OpsDelivery')
          ..add('id', id)
          ..add('channel', channel)
          ..add('kind', kind)
          ..add('userId', userId)
          ..add('state', state)
          ..add('attempts', attempts)
          ..add('providerId', providerId)
          ..add('failureCode', failureCode)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class OpsDeliveryBuilder implements Builder<OpsDelivery, OpsDeliveryBuilder> {
  _$OpsDelivery? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  OpsDeliveryChannelEnum? _channel;
  OpsDeliveryChannelEnum? get channel => _$this._channel;
  set channel(OpsDeliveryChannelEnum? channel) => _$this._channel = channel;

  String? _kind;
  String? get kind => _$this._kind;
  set kind(String? kind) => _$this._kind = kind;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

  String? _state;
  String? get state => _$this._state;
  set state(String? state) => _$this._state = state;

  int? _attempts;
  int? get attempts => _$this._attempts;
  set attempts(int? attempts) => _$this._attempts = attempts;

  String? _providerId;
  String? get providerId => _$this._providerId;
  set providerId(String? providerId) => _$this._providerId = providerId;

  String? _failureCode;
  String? get failureCode => _$this._failureCode;
  set failureCode(String? failureCode) => _$this._failureCode = failureCode;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  OpsDeliveryBuilder() {
    OpsDelivery._defaults(this);
  }

  OpsDeliveryBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _channel = $v.channel;
      _kind = $v.kind;
      _userId = $v.userId;
      _state = $v.state;
      _attempts = $v.attempts;
      _providerId = $v.providerId;
      _failureCode = $v.failureCode;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OpsDelivery other) {
    _$v = other as _$OpsDelivery;
  }

  @override
  void update(void Function(OpsDeliveryBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OpsDelivery build() => _build();

  _$OpsDelivery _build() {
    final _$result = _$v ??
        _$OpsDelivery._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'OpsDelivery', 'id'),
          channel: BuiltValueNullFieldError.checkNotNull(
              channel, r'OpsDelivery', 'channel'),
          kind: BuiltValueNullFieldError.checkNotNull(
              kind, r'OpsDelivery', 'kind'),
          userId: BuiltValueNullFieldError.checkNotNull(
              userId, r'OpsDelivery', 'userId'),
          state: BuiltValueNullFieldError.checkNotNull(
              state, r'OpsDelivery', 'state'),
          attempts: BuiltValueNullFieldError.checkNotNull(
              attempts, r'OpsDelivery', 'attempts'),
          providerId: providerId,
          failureCode: failureCode,
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'OpsDelivery', 'createdAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
