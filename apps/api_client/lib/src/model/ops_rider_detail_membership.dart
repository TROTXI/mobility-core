//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ops_rider_detail_membership.g.dart';

/// OpsRiderDetailMembership
///
/// Properties:
/// * [id]
/// * [lifecycle]
/// * [periodId]
/// * [startsAt]
/// * [endsAt]
@BuiltValue()
abstract class OpsRiderDetailMembership
    implements
        Built<OpsRiderDetailMembership, OpsRiderDetailMembershipBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'lifecycle')
  OpsRiderDetailMembershipLifecycleEnum get lifecycle;
  // enum lifecycleEnum {  open,  ended,  };

  @BuiltValueField(wireName: r'periodId')
  String? get periodId;

  @BuiltValueField(wireName: r'startsAt')
  DateTime? get startsAt;

  @BuiltValueField(wireName: r'endsAt')
  DateTime? get endsAt;

  OpsRiderDetailMembership._();

  factory OpsRiderDetailMembership(
          [void updates(OpsRiderDetailMembershipBuilder b)]) =
      _$OpsRiderDetailMembership;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OpsRiderDetailMembershipBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OpsRiderDetailMembership> get serializer =>
      _$OpsRiderDetailMembershipSerializer();
}

class _$OpsRiderDetailMembershipSerializer
    implements PrimitiveSerializer<OpsRiderDetailMembership> {
  @override
  final Iterable<Type> types = const [
    OpsRiderDetailMembership,
    _$OpsRiderDetailMembership
  ];

  @override
  final String wireName = r'OpsRiderDetailMembership';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OpsRiderDetailMembership object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'lifecycle';
    yield serializers.serialize(
      object.lifecycle,
      specifiedType: const FullType(OpsRiderDetailMembershipLifecycleEnum),
    );
    yield r'periodId';
    yield object.periodId == null
        ? null
        : serializers.serialize(
            object.periodId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'startsAt';
    yield object.startsAt == null
        ? null
        : serializers.serialize(
            object.startsAt,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'endsAt';
    yield object.endsAt == null
        ? null
        : serializers.serialize(
            object.endsAt,
            specifiedType: const FullType.nullable(DateTime),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    OpsRiderDetailMembership object, {
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
    required OpsRiderDetailMembershipBuilder result,
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
        case r'lifecycle':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(OpsRiderDetailMembershipLifecycleEnum),
          ) as OpsRiderDetailMembershipLifecycleEnum;
          result.lifecycle = valueDes;
          break;
        case r'periodId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.periodId = valueDes;
          break;
        case r'startsAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.startsAt = valueDes;
          break;
        case r'endsAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.endsAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OpsRiderDetailMembership deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OpsRiderDetailMembershipBuilder();
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

class OpsRiderDetailMembershipLifecycleEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'open')
  static const OpsRiderDetailMembershipLifecycleEnum open =
      _$opsRiderDetailMembershipLifecycleEnum_open;
  @BuiltValueEnumConst(wireName: r'ended')
  static const OpsRiderDetailMembershipLifecycleEnum ended =
      _$opsRiderDetailMembershipLifecycleEnum_ended;

  static Serializer<OpsRiderDetailMembershipLifecycleEnum> get serializer =>
      _$opsRiderDetailMembershipLifecycleEnumSerializer;

  const OpsRiderDetailMembershipLifecycleEnum._(String name) : super(name);

  static BuiltSet<OpsRiderDetailMembershipLifecycleEnum> get values =>
      _$opsRiderDetailMembershipLifecycleEnumValues;
  static OpsRiderDetailMembershipLifecycleEnum valueOf(String name) =>
      _$opsRiderDetailMembershipLifecycleEnumValueOf(name);
}
