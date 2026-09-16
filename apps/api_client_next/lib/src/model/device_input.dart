//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'device_input.g.dart';

/// DeviceInput
///
/// Properties:
/// * [token] 
/// * [platform] 
@BuiltValue()
abstract class DeviceInput implements Built<DeviceInput, DeviceInputBuilder> {
  @BuiltValueField(wireName: r'token')
  String get token;

  @BuiltValueField(wireName: r'platform')
  DeviceInputPlatformEnum get platform;
  // enum platformEnum {  ios,  android,  };

  DeviceInput._();

  factory DeviceInput([void updates(DeviceInputBuilder b)]) = _$DeviceInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DeviceInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DeviceInput> get serializer => _$DeviceInputSerializer();
}

class _$DeviceInputSerializer implements PrimitiveSerializer<DeviceInput> {
  @override
  final Iterable<Type> types = const [DeviceInput, _$DeviceInput];

  @override
  final String wireName = r'DeviceInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DeviceInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'token';
    yield serializers.serialize(
      object.token,
      specifiedType: const FullType(String),
    );
    yield r'platform';
    yield serializers.serialize(
      object.platform,
      specifiedType: const FullType(DeviceInputPlatformEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DeviceInput object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DeviceInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'token':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.token = valueDes;
          break;
        case r'platform':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DeviceInputPlatformEnum),
          ) as DeviceInputPlatformEnum;
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
  DeviceInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DeviceInputBuilder();
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

class DeviceInputPlatformEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'ios')
  static const DeviceInputPlatformEnum ios = _$deviceInputPlatformEnum_ios;
  @BuiltValueEnumConst(wireName: r'android')
  static const DeviceInputPlatformEnum android = _$deviceInputPlatformEnum_android;

  static Serializer<DeviceInputPlatformEnum> get serializer => _$deviceInputPlatformEnumSerializer;

  const DeviceInputPlatformEnum._(String name): super(name);

  static BuiltSet<DeviceInputPlatformEnum> get values => _$deviceInputPlatformEnumValues;
  static DeviceInputPlatformEnum valueOf(String name) => _$deviceInputPlatformEnumValueOf(name);
}

