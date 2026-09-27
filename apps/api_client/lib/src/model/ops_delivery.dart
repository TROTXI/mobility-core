//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ops_delivery.g.dart';

/// OpsDelivery
///
/// Properties:
/// * [id]
/// * [channel]
/// * [kind]
/// * [userId]
/// * [state]
/// * [attempts]
/// * [providerId]
/// * [failureCode]
/// * [createdAt]
@BuiltValue()
abstract class OpsDelivery implements Built<OpsDelivery, OpsDeliveryBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'channel')
  OpsDeliveryChannelEnum get channel;
  // enum channelEnum {  email,  push,  };

  @BuiltValueField(wireName: r'kind')
  String get kind;

  @BuiltValueField(wireName: r'userId')
  String get userId;

  @BuiltValueField(wireName: r'state')
  String get state;

  @BuiltValueField(wireName: r'attempts')
  int get attempts;

  @BuiltValueField(wireName: r'providerId')
  String? get providerId;

  @BuiltValueField(wireName: r'failureCode')
  String? get failureCode;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  OpsDelivery._();

  factory OpsDelivery([void updates(OpsDeliveryBuilder b)]) = _$OpsDelivery;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OpsDeliveryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OpsDelivery> get serializer => _$OpsDeliverySerializer();
}

class _$OpsDeliverySerializer implements PrimitiveSerializer<OpsDelivery> {
  @override
  final Iterable<Type> types = const [OpsDelivery, _$OpsDelivery];

  @override
  final String wireName = r'OpsDelivery';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OpsDelivery object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'channel';
    yield serializers.serialize(
      object.channel,
      specifiedType: const FullType(OpsDeliveryChannelEnum),
    );
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(String),
    );
    yield r'userId';
    yield serializers.serialize(
      object.userId,
      specifiedType: const FullType(String),
    );
    yield r'state';
    yield serializers.serialize(
      object.state,
      specifiedType: const FullType(String),
    );
    yield r'attempts';
    yield serializers.serialize(
      object.attempts,
      specifiedType: const FullType(int),
    );
    yield r'providerId';
    yield object.providerId == null
        ? null
        : serializers.serialize(
            object.providerId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'failureCode';
    yield object.failureCode == null
        ? null
        : serializers.serialize(
            object.failureCode,
            specifiedType: const FullType.nullable(String),
          );
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OpsDelivery object, {
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
    required OpsDeliveryBuilder result,
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
        case r'channel':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OpsDeliveryChannelEnum),
          ) as OpsDeliveryChannelEnum;
          result.channel = valueDes;
          break;
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.kind = valueDes;
          break;
        case r'userId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.userId = valueDes;
          break;
        case r'state':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.state = valueDes;
          break;
        case r'attempts':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.attempts = valueDes;
          break;
        case r'providerId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.providerId = valueDes;
          break;
        case r'failureCode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.failureCode = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OpsDelivery deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OpsDeliveryBuilder();
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

class OpsDeliveryChannelEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'email')
  static const OpsDeliveryChannelEnum email = _$opsDeliveryChannelEnum_email;
  @BuiltValueEnumConst(wireName: r'push')
  static const OpsDeliveryChannelEnum push = _$opsDeliveryChannelEnum_push;

  static Serializer<OpsDeliveryChannelEnum> get serializer =>
      _$opsDeliveryChannelEnumSerializer;

  const OpsDeliveryChannelEnum._(String name) : super(name);

  static BuiltSet<OpsDeliveryChannelEnum> get values =>
      _$opsDeliveryChannelEnumValues;
  static OpsDeliveryChannelEnum valueOf(String name) =>
      _$opsDeliveryChannelEnumValueOf(name);
}
