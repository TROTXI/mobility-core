//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'rider_notification_target.g.dart';

/// RiderNotificationTarget
///
/// Properties:
/// * [type]
/// * [id]
@BuiltValue()
abstract class RiderNotificationTarget
    implements Built<RiderNotificationTarget, RiderNotificationTargetBuilder> {
  @BuiltValueField(wireName: r'type')
  RiderNotificationTargetTypeEnum get type;
  // enum typeEnum {  reservation,  credit,  standby,  };

  @BuiltValueField(wireName: r'id')
  String get id;

  RiderNotificationTarget._();

  factory RiderNotificationTarget(
          [void updates(RiderNotificationTargetBuilder b)]) =
      _$RiderNotificationTarget;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RiderNotificationTargetBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RiderNotificationTarget> get serializer =>
      _$RiderNotificationTargetSerializer();
}

class _$RiderNotificationTargetSerializer
    implements PrimitiveSerializer<RiderNotificationTarget> {
  @override
  final Iterable<Type> types = const [
    RiderNotificationTarget,
    _$RiderNotificationTarget
  ];

  @override
  final String wireName = r'RiderNotificationTarget';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RiderNotificationTarget object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(RiderNotificationTargetTypeEnum),
    );
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RiderNotificationTarget object, {
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
    required RiderNotificationTargetBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(RiderNotificationTargetTypeEnum),
          ) as RiderNotificationTargetTypeEnum;
          result.type = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RiderNotificationTarget deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RiderNotificationTargetBuilder();
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

class RiderNotificationTargetTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'reservation')
  static const RiderNotificationTargetTypeEnum reservation =
      _$riderNotificationTargetTypeEnum_reservation;
  @BuiltValueEnumConst(wireName: r'credit')
  static const RiderNotificationTargetTypeEnum credit =
      _$riderNotificationTargetTypeEnum_credit;
  @BuiltValueEnumConst(wireName: r'standby')
  static const RiderNotificationTargetTypeEnum standby =
      _$riderNotificationTargetTypeEnum_standby;

  static Serializer<RiderNotificationTargetTypeEnum> get serializer =>
      _$riderNotificationTargetTypeEnumSerializer;

  const RiderNotificationTargetTypeEnum._(String name) : super(name);

  static BuiltSet<RiderNotificationTargetTypeEnum> get values =>
      _$riderNotificationTargetTypeEnumValues;
  static RiderNotificationTargetTypeEnum valueOf(String name) =>
      _$riderNotificationTargetTypeEnumValueOf(name);
}
