// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ops_audit_event.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const OpsAuditEventAreaEnum _$opsAuditEventAreaEnum_catalog =
    const OpsAuditEventAreaEnum._('catalog');
const OpsAuditEventAreaEnum _$opsAuditEventAreaEnum_trip =
    const OpsAuditEventAreaEnum._('trip');
const OpsAuditEventAreaEnum _$opsAuditEventAreaEnum_schedule =
    const OpsAuditEventAreaEnum._('schedule');
const OpsAuditEventAreaEnum _$opsAuditEventAreaEnum_fleet =
    const OpsAuditEventAreaEnum._('fleet');
const OpsAuditEventAreaEnum _$opsAuditEventAreaEnum_driver =
    const OpsAuditEventAreaEnum._('driver');
const OpsAuditEventAreaEnum _$opsAuditEventAreaEnum_membership =
    const OpsAuditEventAreaEnum._('membership');
const OpsAuditEventAreaEnum _$opsAuditEventAreaEnum_boarding =
    const OpsAuditEventAreaEnum._('boarding');
const OpsAuditEventAreaEnum _$opsAuditEventAreaEnum_pricing =
    const OpsAuditEventAreaEnum._('pricing');
const OpsAuditEventAreaEnum _$opsAuditEventAreaEnum_configuration =
    const OpsAuditEventAreaEnum._('configuration');
const OpsAuditEventAreaEnum _$opsAuditEventAreaEnum_security =
    const OpsAuditEventAreaEnum._('security');
const OpsAuditEventAreaEnum _$opsAuditEventAreaEnum_payments =
    const OpsAuditEventAreaEnum._('payments');
const OpsAuditEventAreaEnum _$opsAuditEventAreaEnum_gps =
    const OpsAuditEventAreaEnum._('gps');
const OpsAuditEventAreaEnum _$opsAuditEventAreaEnum_maintenance =
    const OpsAuditEventAreaEnum._('maintenance');

OpsAuditEventAreaEnum _$opsAuditEventAreaEnumValueOf(String name) {
  switch (name) {
    case 'catalog':
      return _$opsAuditEventAreaEnum_catalog;
    case 'trip':
      return _$opsAuditEventAreaEnum_trip;
    case 'schedule':
      return _$opsAuditEventAreaEnum_schedule;
    case 'fleet':
      return _$opsAuditEventAreaEnum_fleet;
    case 'driver':
      return _$opsAuditEventAreaEnum_driver;
    case 'membership':
      return _$opsAuditEventAreaEnum_membership;
    case 'boarding':
      return _$opsAuditEventAreaEnum_boarding;
    case 'pricing':
      return _$opsAuditEventAreaEnum_pricing;
    case 'configuration':
      return _$opsAuditEventAreaEnum_configuration;
    case 'security':
      return _$opsAuditEventAreaEnum_security;
    case 'payments':
      return _$opsAuditEventAreaEnum_payments;
    case 'gps':
      return _$opsAuditEventAreaEnum_gps;
    case 'maintenance':
      return _$opsAuditEventAreaEnum_maintenance;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<OpsAuditEventAreaEnum> _$opsAuditEventAreaEnumValues =
    BuiltSet<OpsAuditEventAreaEnum>(const <OpsAuditEventAreaEnum>[
  _$opsAuditEventAreaEnum_catalog,
  _$opsAuditEventAreaEnum_trip,
  _$opsAuditEventAreaEnum_schedule,
  _$opsAuditEventAreaEnum_fleet,
  _$opsAuditEventAreaEnum_driver,
  _$opsAuditEventAreaEnum_membership,
  _$opsAuditEventAreaEnum_boarding,
  _$opsAuditEventAreaEnum_pricing,
  _$opsAuditEventAreaEnum_configuration,
  _$opsAuditEventAreaEnum_security,
  _$opsAuditEventAreaEnum_payments,
  _$opsAuditEventAreaEnum_gps,
  _$opsAuditEventAreaEnum_maintenance,
]);

Serializer<OpsAuditEventAreaEnum> _$opsAuditEventAreaEnumSerializer =
    _$OpsAuditEventAreaEnumSerializer();

class _$OpsAuditEventAreaEnumSerializer
    implements PrimitiveSerializer<OpsAuditEventAreaEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'catalog': 'catalog',
    'trip': 'trip',
    'schedule': 'schedule',
    'fleet': 'fleet',
    'driver': 'driver',
    'membership': 'membership',
    'boarding': 'boarding',
    'pricing': 'pricing',
    'configuration': 'configuration',
    'security': 'security',
    'payments': 'payments',
    'gps': 'gps',
    'maintenance': 'maintenance',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'catalog': 'catalog',
    'trip': 'trip',
    'schedule': 'schedule',
    'fleet': 'fleet',
    'driver': 'driver',
    'membership': 'membership',
    'boarding': 'boarding',
    'pricing': 'pricing',
    'configuration': 'configuration',
    'security': 'security',
    'payments': 'payments',
    'gps': 'gps',
    'maintenance': 'maintenance',
  };

  @override
  final Iterable<Type> types = const <Type>[OpsAuditEventAreaEnum];
  @override
  final String wireName = 'OpsAuditEventAreaEnum';

  @override
  Object serialize(Serializers serializers, OpsAuditEventAreaEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  OpsAuditEventAreaEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      OpsAuditEventAreaEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$OpsAuditEvent extends OpsAuditEvent {
  @override
  final String id;
  @override
  final OpsAuditEventAreaEnum area;
  @override
  final String action;
  @override
  final String actorId;
  @override
  final String actorName;
  @override
  final String targetId;
  @override
  final String? reason;
  @override
  final DateTime occurredAt;

  factory _$OpsAuditEvent([void Function(OpsAuditEventBuilder)? updates]) =>
      (OpsAuditEventBuilder()..update(updates))._build();

  _$OpsAuditEvent._(
      {required this.id,
      required this.area,
      required this.action,
      required this.actorId,
      required this.actorName,
      required this.targetId,
      this.reason,
      required this.occurredAt})
      : super._();
  @override
  OpsAuditEvent rebuild(void Function(OpsAuditEventBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OpsAuditEventBuilder toBuilder() => OpsAuditEventBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OpsAuditEvent &&
        id == other.id &&
        area == other.area &&
        action == other.action &&
        actorId == other.actorId &&
        actorName == other.actorName &&
        targetId == other.targetId &&
        reason == other.reason &&
        occurredAt == other.occurredAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, area.hashCode);
    _$hash = $jc(_$hash, action.hashCode);
    _$hash = $jc(_$hash, actorId.hashCode);
    _$hash = $jc(_$hash, actorName.hashCode);
    _$hash = $jc(_$hash, targetId.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jc(_$hash, occurredAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OpsAuditEvent')
          ..add('id', id)
          ..add('area', area)
          ..add('action', action)
          ..add('actorId', actorId)
          ..add('actorName', actorName)
          ..add('targetId', targetId)
          ..add('reason', reason)
          ..add('occurredAt', occurredAt))
        .toString();
  }
}

class OpsAuditEventBuilder
    implements Builder<OpsAuditEvent, OpsAuditEventBuilder> {
  _$OpsAuditEvent? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  OpsAuditEventAreaEnum? _area;
  OpsAuditEventAreaEnum? get area => _$this._area;
  set area(OpsAuditEventAreaEnum? area) => _$this._area = area;

  String? _action;
  String? get action => _$this._action;
  set action(String? action) => _$this._action = action;

  String? _actorId;
  String? get actorId => _$this._actorId;
  set actorId(String? actorId) => _$this._actorId = actorId;

  String? _actorName;
  String? get actorName => _$this._actorName;
  set actorName(String? actorName) => _$this._actorName = actorName;

  String? _targetId;
  String? get targetId => _$this._targetId;
  set targetId(String? targetId) => _$this._targetId = targetId;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  DateTime? _occurredAt;
  DateTime? get occurredAt => _$this._occurredAt;
  set occurredAt(DateTime? occurredAt) => _$this._occurredAt = occurredAt;

  OpsAuditEventBuilder() {
    OpsAuditEvent._defaults(this);
  }

  OpsAuditEventBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _area = $v.area;
      _action = $v.action;
      _actorId = $v.actorId;
      _actorName = $v.actorName;
      _targetId = $v.targetId;
      _reason = $v.reason;
      _occurredAt = $v.occurredAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OpsAuditEvent other) {
    _$v = other as _$OpsAuditEvent;
  }

  @override
  void update(void Function(OpsAuditEventBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OpsAuditEvent build() => _build();

  _$OpsAuditEvent _build() {
    final _$result = _$v ??
        _$OpsAuditEvent._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'OpsAuditEvent', 'id'),
          area: BuiltValueNullFieldError.checkNotNull(
              area, r'OpsAuditEvent', 'area'),
          action: BuiltValueNullFieldError.checkNotNull(
              action, r'OpsAuditEvent', 'action'),
          actorId: BuiltValueNullFieldError.checkNotNull(
              actorId, r'OpsAuditEvent', 'actorId'),
          actorName: BuiltValueNullFieldError.checkNotNull(
              actorName, r'OpsAuditEvent', 'actorName'),
          targetId: BuiltValueNullFieldError.checkNotNull(
              targetId, r'OpsAuditEvent', 'targetId'),
          reason: reason,
          occurredAt: BuiltValueNullFieldError.checkNotNull(
              occurredAt, r'OpsAuditEvent', 'occurredAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
