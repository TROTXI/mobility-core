//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'minimum_version.g.dart';

/// MinimumVersion
///
/// Properties:
/// * [app] 
/// * [platform] 
/// * [minSupportedBuild] 
/// * [apiMajor] 
/// * [storeUrl] 
/// * [version] 
@BuiltValue()
abstract class MinimumVersion implements Built<MinimumVersion, MinimumVersionBuilder> {
  @BuiltValueField(wireName: r'app')
  MinimumVersionAppEnum get app;
  // enum appEnum {  commuter,  driver,  };

  @BuiltValueField(wireName: r'platform')
  MinimumVersionPlatformEnum get platform;
  // enum platformEnum {  ios,  android,  };

  @BuiltValueField(wireName: r'minSupportedBuild')
  int get minSupportedBuild;

  @BuiltValueField(wireName: r'apiMajor')
  MinimumVersionApiMajorEnum get apiMajor;
  // enum apiMajorEnum {  1,  };

  @BuiltValueField(wireName: r'storeUrl')
  String get storeUrl;

  @BuiltValueField(wireName: r'version')
  int get version;

  MinimumVersion._();

  factory MinimumVersion([void updates(MinimumVersionBuilder b)]) = _$MinimumVersion;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MinimumVersionBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MinimumVersion> get serializer => _$MinimumVersionSerializer();
}

class _$MinimumVersionSerializer implements PrimitiveSerializer<MinimumVersion> {
  @override
  final Iterable<Type> types = const [MinimumVersion, _$MinimumVersion];

  @override
  final String wireName = r'MinimumVersion';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MinimumVersion object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'app';
    yield serializers.serialize(
      object.app,
      specifiedType: const FullType(MinimumVersionAppEnum),
    );
    yield r'platform';
    yield serializers.serialize(
      object.platform,
      specifiedType: const FullType(MinimumVersionPlatformEnum),
    );
    yield r'minSupportedBuild';
    yield serializers.serialize(
      object.minSupportedBuild,
      specifiedType: const FullType(int),
    );
    yield r'apiMajor';
    yield serializers.serialize(
      object.apiMajor,
      specifiedType: const FullType(MinimumVersionApiMajorEnum),
    );
    yield r'storeUrl';
    yield serializers.serialize(
      object.storeUrl,
      specifiedType: const FullType(String),
    );
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MinimumVersion object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MinimumVersionBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'app':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MinimumVersionAppEnum),
          ) as MinimumVersionAppEnum;
          result.app = valueDes;
          break;
        case r'platform':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MinimumVersionPlatformEnum),
          ) as MinimumVersionPlatformEnum;
          result.platform = valueDes;
          break;
        case r'minSupportedBuild':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.minSupportedBuild = valueDes;
          break;
        case r'apiMajor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MinimumVersionApiMajorEnum),
          ) as MinimumVersionApiMajorEnum;
          result.apiMajor = valueDes;
          break;
        case r'storeUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.storeUrl = valueDes;
          break;
        case r'version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.version = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MinimumVersion deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MinimumVersionBuilder();
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

class MinimumVersionAppEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'commuter')
  static const MinimumVersionAppEnum commuter = _$minimumVersionAppEnum_commuter;
  @BuiltValueEnumConst(wireName: r'driver')
  static const MinimumVersionAppEnum driver = _$minimumVersionAppEnum_driver;

  static Serializer<MinimumVersionAppEnum> get serializer => _$minimumVersionAppEnumSerializer;

  const MinimumVersionAppEnum._(String name): super(name);

  static BuiltSet<MinimumVersionAppEnum> get values => _$minimumVersionAppEnumValues;
  static MinimumVersionAppEnum valueOf(String name) => _$minimumVersionAppEnumValueOf(name);
}

class MinimumVersionPlatformEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'ios')
  static const MinimumVersionPlatformEnum ios = _$minimumVersionPlatformEnum_ios;
  @BuiltValueEnumConst(wireName: r'android')
  static const MinimumVersionPlatformEnum android = _$minimumVersionPlatformEnum_android;

  static Serializer<MinimumVersionPlatformEnum> get serializer => _$minimumVersionPlatformEnumSerializer;

  const MinimumVersionPlatformEnum._(String name): super(name);

  static BuiltSet<MinimumVersionPlatformEnum> get values => _$minimumVersionPlatformEnumValues;
  static MinimumVersionPlatformEnum valueOf(String name) => _$minimumVersionPlatformEnumValueOf(name);
}

class MinimumVersionApiMajorEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 1)
  static const MinimumVersionApiMajorEnum number1 = _$minimumVersionApiMajorEnum_number1;

  static Serializer<MinimumVersionApiMajorEnum> get serializer => _$minimumVersionApiMajorEnumSerializer;

  const MinimumVersionApiMajorEnum._(String name): super(name);

  static BuiltSet<MinimumVersionApiMajorEnum> get values => _$minimumVersionApiMajorEnumValues;
  static MinimumVersionApiMajorEnum valueOf(String name) => _$minimumVersionApiMajorEnumValueOf(name);
}

