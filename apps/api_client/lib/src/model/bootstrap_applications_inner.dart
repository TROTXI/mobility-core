//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'bootstrap_applications_inner.g.dart';

/// BootstrapApplicationsInner
///
/// Properties:
/// * [app] 
/// * [platform] 
/// * [minSupportedBuild] 
/// * [storeUrl] 
/// * [apiMajor] 
@BuiltValue()
abstract class BootstrapApplicationsInner implements Built<BootstrapApplicationsInner, BootstrapApplicationsInnerBuilder> {
  @BuiltValueField(wireName: r'app')
  BootstrapApplicationsInnerAppEnum get app;
  // enum appEnum {  commuter,  driver,  };

  @BuiltValueField(wireName: r'platform')
  BootstrapApplicationsInnerPlatformEnum get platform;
  // enum platformEnum {  ios,  android,  };

  @BuiltValueField(wireName: r'minSupportedBuild')
  int get minSupportedBuild;

  @BuiltValueField(wireName: r'storeUrl')
  String? get storeUrl;

  @BuiltValueField(wireName: r'apiMajor')
  BootstrapApplicationsInnerApiMajorEnum get apiMajor;
  // enum apiMajorEnum {  1,  };

  BootstrapApplicationsInner._();

  factory BootstrapApplicationsInner([void updates(BootstrapApplicationsInnerBuilder b)]) = _$BootstrapApplicationsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BootstrapApplicationsInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BootstrapApplicationsInner> get serializer => _$BootstrapApplicationsInnerSerializer();
}

class _$BootstrapApplicationsInnerSerializer implements PrimitiveSerializer<BootstrapApplicationsInner> {
  @override
  final Iterable<Type> types = const [BootstrapApplicationsInner, _$BootstrapApplicationsInner];

  @override
  final String wireName = r'BootstrapApplicationsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BootstrapApplicationsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'app';
    yield serializers.serialize(
      object.app,
      specifiedType: const FullType(BootstrapApplicationsInnerAppEnum),
    );
    yield r'platform';
    yield serializers.serialize(
      object.platform,
      specifiedType: const FullType(BootstrapApplicationsInnerPlatformEnum),
    );
    yield r'minSupportedBuild';
    yield serializers.serialize(
      object.minSupportedBuild,
      specifiedType: const FullType(int),
    );
    yield r'storeUrl';
    yield object.storeUrl == null ? null : serializers.serialize(
      object.storeUrl,
      specifiedType: const FullType.nullable(String),
    );
    yield r'apiMajor';
    yield serializers.serialize(
      object.apiMajor,
      specifiedType: const FullType(BootstrapApplicationsInnerApiMajorEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BootstrapApplicationsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BootstrapApplicationsInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'app':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BootstrapApplicationsInnerAppEnum),
          ) as BootstrapApplicationsInnerAppEnum;
          result.app = valueDes;
          break;
        case r'platform':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BootstrapApplicationsInnerPlatformEnum),
          ) as BootstrapApplicationsInnerPlatformEnum;
          result.platform = valueDes;
          break;
        case r'minSupportedBuild':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.minSupportedBuild = valueDes;
          break;
        case r'storeUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.storeUrl = valueDes;
          break;
        case r'apiMajor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BootstrapApplicationsInnerApiMajorEnum),
          ) as BootstrapApplicationsInnerApiMajorEnum;
          result.apiMajor = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BootstrapApplicationsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BootstrapApplicationsInnerBuilder();
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

class BootstrapApplicationsInnerAppEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'commuter')
  static const BootstrapApplicationsInnerAppEnum commuter = _$bootstrapApplicationsInnerAppEnum_commuter;
  @BuiltValueEnumConst(wireName: r'driver')
  static const BootstrapApplicationsInnerAppEnum driver = _$bootstrapApplicationsInnerAppEnum_driver;

  static Serializer<BootstrapApplicationsInnerAppEnum> get serializer => _$bootstrapApplicationsInnerAppEnumSerializer;

  const BootstrapApplicationsInnerAppEnum._(String name): super(name);

  static BuiltSet<BootstrapApplicationsInnerAppEnum> get values => _$bootstrapApplicationsInnerAppEnumValues;
  static BootstrapApplicationsInnerAppEnum valueOf(String name) => _$bootstrapApplicationsInnerAppEnumValueOf(name);
}

class BootstrapApplicationsInnerPlatformEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'ios')
  static const BootstrapApplicationsInnerPlatformEnum ios = _$bootstrapApplicationsInnerPlatformEnum_ios;
  @BuiltValueEnumConst(wireName: r'android')
  static const BootstrapApplicationsInnerPlatformEnum android = _$bootstrapApplicationsInnerPlatformEnum_android;

  static Serializer<BootstrapApplicationsInnerPlatformEnum> get serializer => _$bootstrapApplicationsInnerPlatformEnumSerializer;

  const BootstrapApplicationsInnerPlatformEnum._(String name): super(name);

  static BuiltSet<BootstrapApplicationsInnerPlatformEnum> get values => _$bootstrapApplicationsInnerPlatformEnumValues;
  static BootstrapApplicationsInnerPlatformEnum valueOf(String name) => _$bootstrapApplicationsInnerPlatformEnumValueOf(name);
}

class BootstrapApplicationsInnerApiMajorEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 1)
  static const BootstrapApplicationsInnerApiMajorEnum number1 = _$bootstrapApplicationsInnerApiMajorEnum_number1;

  static Serializer<BootstrapApplicationsInnerApiMajorEnum> get serializer => _$bootstrapApplicationsInnerApiMajorEnumSerializer;

  const BootstrapApplicationsInnerApiMajorEnum._(String name): super(name);

  static BuiltSet<BootstrapApplicationsInnerApiMajorEnum> get values => _$bootstrapApplicationsInnerApiMajorEnumValues;
  static BootstrapApplicationsInnerApiMajorEnum valueOf(String name) => _$bootstrapApplicationsInnerApiMajorEnumValueOf(name);
}

