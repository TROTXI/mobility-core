//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ops_audit_event.g.dart';

/// OpsAuditEvent
///
/// Properties:
/// * [id]
/// * [area]
/// * [action]
/// * [actorId]
/// * [actorName]
/// * [targetId]
/// * [reason]
/// * [occurredAt]
@BuiltValue()
abstract class OpsAuditEvent
    implements Built<OpsAuditEvent, OpsAuditEventBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'area')
  OpsAuditEventAreaEnum get area;
  // enum areaEnum {  catalog,  trip,  schedule,  fleet,  driver,  membership,  boarding,  pricing,  configuration,  security,  payments,  gps,  maintenance,  };

  @BuiltValueField(wireName: r'action')
  String get action;

  @BuiltValueField(wireName: r'actorId')
  String get actorId;

  @BuiltValueField(wireName: r'actorName')
  String get actorName;

  @BuiltValueField(wireName: r'targetId')
  String get targetId;

  @BuiltValueField(wireName: r'reason')
  String? get reason;

  @BuiltValueField(wireName: r'occurredAt')
  DateTime get occurredAt;

  OpsAuditEvent._();

  factory OpsAuditEvent([void updates(OpsAuditEventBuilder b)]) =
      _$OpsAuditEvent;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OpsAuditEventBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OpsAuditEvent> get serializer =>
      _$OpsAuditEventSerializer();
}

class _$OpsAuditEventSerializer implements PrimitiveSerializer<OpsAuditEvent> {
  @override
  final Iterable<Type> types = const [OpsAuditEvent, _$OpsAuditEvent];

  @override
  final String wireName = r'OpsAuditEvent';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OpsAuditEvent object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'area';
    yield serializers.serialize(
      object.area,
      specifiedType: const FullType(OpsAuditEventAreaEnum),
    );
    yield r'action';
    yield serializers.serialize(
      object.action,
      specifiedType: const FullType(String),
    );
    yield r'actorId';
    yield serializers.serialize(
      object.actorId,
      specifiedType: const FullType(String),
    );
    yield r'actorName';
    yield serializers.serialize(
      object.actorName,
      specifiedType: const FullType(String),
    );
    yield r'targetId';
    yield serializers.serialize(
      object.targetId,
      specifiedType: const FullType(String),
    );
    yield r'reason';
    yield object.reason == null
        ? null
        : serializers.serialize(
            object.reason,
            specifiedType: const FullType.nullable(String),
          );
    yield r'occurredAt';
    yield serializers.serialize(
      object.occurredAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OpsAuditEvent object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OpsAuditEventBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'area':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OpsAuditEventAreaEnum),
          ) as OpsAuditEventAreaEnum;
          result.area = valueDes;
          break;
        case r'action':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.action = valueDes;
          break;
        case r'actorId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.actorId = valueDes;
          break;
        case r'actorName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.actorName = valueDes;
          break;
        case r'targetId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.targetId = valueDes;
          break;
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.reason = valueDes;
          break;
        case r'occurredAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.occurredAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OpsAuditEvent deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OpsAuditEventBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}

class OpsAuditEventAreaEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'catalog')
  static const OpsAuditEventAreaEnum catalog = _$opsAuditEventAreaEnum_catalog;
  @BuiltValueEnumConst(wireName: r'trip')
  static const OpsAuditEventAreaEnum trip = _$opsAuditEventAreaEnum_trip;
  @BuiltValueEnumConst(wireName: r'schedule')
  static const OpsAuditEventAreaEnum schedule =
      _$opsAuditEventAreaEnum_schedule;
  @BuiltValueEnumConst(wireName: r'fleet')
  static const OpsAuditEventAreaEnum fleet = _$opsAuditEventAreaEnum_fleet;
  @BuiltValueEnumConst(wireName: r'driver')
  static const OpsAuditEventAreaEnum driver = _$opsAuditEventAreaEnum_driver;
  @BuiltValueEnumConst(wireName: r'membership')
  static const OpsAuditEventAreaEnum membership =
      _$opsAuditEventAreaEnum_membership;
  @BuiltValueEnumConst(wireName: r'boarding')
  static const OpsAuditEventAreaEnum boarding =
      _$opsAuditEventAreaEnum_boarding;
  @BuiltValueEnumConst(wireName: r'pricing')
  static const OpsAuditEventAreaEnum pricing = _$opsAuditEventAreaEnum_pricing;
  @BuiltValueEnumConst(wireName: r'configuration')
  static const OpsAuditEventAreaEnum configuration =
      _$opsAuditEventAreaEnum_configuration;
  @BuiltValueEnumConst(wireName: r'security')
  static const OpsAuditEventAreaEnum security =
      _$opsAuditEventAreaEnum_security;
  @BuiltValueEnumConst(wireName: r'payments')
  static const OpsAuditEventAreaEnum payments =
      _$opsAuditEventAreaEnum_payments;
  @BuiltValueEnumConst(wireName: r'gps')
  static const OpsAuditEventAreaEnum gps = _$opsAuditEventAreaEnum_gps;
  @BuiltValueEnumConst(wireName: r'maintenance')
  static const OpsAuditEventAreaEnum maintenance =
      _$opsAuditEventAreaEnum_maintenance;

  static Serializer<OpsAuditEventAreaEnum> get serializer =>
      _$opsAuditEventAreaEnumSerializer;

  const OpsAuditEventAreaEnum._(String name) : super(name);

  static BuiltSet<OpsAuditEventAreaEnum> get values =>
      _$opsAuditEventAreaEnumValues;
  static OpsAuditEventAreaEnum valueOf(String name) =>
      _$opsAuditEventAreaEnumValueOf(name);
}
