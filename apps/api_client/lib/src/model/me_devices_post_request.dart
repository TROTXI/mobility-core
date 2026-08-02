//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'me_devices_post_request.g.dart';

/// MeDevicesPostRequest
///
/// Properties:
/// * [fcmToken] 
/// * [platform] 
@BuiltValue()
abstract class MeDevicesPostRequest implements Built<MeDevicesPostRequest, MeDevicesPostRequestBuilder> {
  @BuiltValueField(wireName: r'fcmToken')
  String get fcmToken;

  @BuiltValueField(wireName: r'platform')
  MeDevicesPostRequestPlatformEnum get platform;
  // enum platformEnum {  android,  ios,  web,  };

  MeDevicesPostRequest._();

  factory MeDevicesPostRequest([void updates(MeDevicesPostRequestBuilder b)]) = _$MeDevicesPostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MeDevicesPostRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MeDevicesPostRequest> get serializer => _$MeDevicesPostRequestSerializer();
}

class _$MeDevicesPostRequestSerializer implements PrimitiveSerializer<MeDevicesPostRequest> {
  @override
  final Iterable<Type> types = const [MeDevicesPostRequest, _$MeDevicesPostRequest];

  @override
  final String wireName = r'MeDevicesPostRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MeDevicesPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'fcmToken';
    yield serializers.serialize(
      object.fcmToken,
      specifiedType: const FullType(String),
    );
    yield r'platform';
    yield serializers.serialize(
      object.platform,
      specifiedType: const FullType(MeDevicesPostRequestPlatformEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MeDevicesPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MeDevicesPostRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'fcmToken':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.fcmToken = valueDes;
          break;
        case r'platform':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MeDevicesPostRequestPlatformEnum),
          ) as MeDevicesPostRequestPlatformEnum;
          result.platform = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MeDevicesPostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MeDevicesPostRequestBuilder();
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

class MeDevicesPostRequestPlatformEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'android')
  static const MeDevicesPostRequestPlatformEnum android = _$meDevicesPostRequestPlatformEnum_android;
  @BuiltValueEnumConst(wireName: r'ios')
  static const MeDevicesPostRequestPlatformEnum ios = _$meDevicesPostRequestPlatformEnum_ios;
  @BuiltValueEnumConst(wireName: r'web')
  static const MeDevicesPostRequestPlatformEnum web = _$meDevicesPostRequestPlatformEnum_web;

  static Serializer<MeDevicesPostRequestPlatformEnum> get serializer => _$meDevicesPostRequestPlatformEnumSerializer;

  const MeDevicesPostRequestPlatformEnum._(String name): super(name);

  static BuiltSet<MeDevicesPostRequestPlatformEnum> get values => _$meDevicesPostRequestPlatformEnumValues;
  static MeDevicesPostRequestPlatformEnum valueOf(String name) => _$meDevicesPostRequestPlatformEnumValueOf(name);
}

