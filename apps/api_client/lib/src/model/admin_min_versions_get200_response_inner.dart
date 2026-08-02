//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_min_versions_get200_response_inner.g.dart';

/// AdminMinVersionsGet200ResponseInner
///
/// Properties:
/// * [platform] 
/// * [version] 
/// * [updatedAt] 
@BuiltValue()
abstract class AdminMinVersionsGet200ResponseInner implements Built<AdminMinVersionsGet200ResponseInner, AdminMinVersionsGet200ResponseInnerBuilder> {
  @BuiltValueField(wireName: r'platform')
  AdminMinVersionsGet200ResponseInnerPlatformEnum get platform;
  // enum platformEnum {  ios,  android,  };

  @BuiltValueField(wireName: r'version')
  String get version;

  @BuiltValueField(wireName: r'updatedAt')
  DateTime get updatedAt;

  AdminMinVersionsGet200ResponseInner._();

  factory AdminMinVersionsGet200ResponseInner([void updates(AdminMinVersionsGet200ResponseInnerBuilder b)]) = _$AdminMinVersionsGet200ResponseInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminMinVersionsGet200ResponseInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminMinVersionsGet200ResponseInner> get serializer => _$AdminMinVersionsGet200ResponseInnerSerializer();
}

class _$AdminMinVersionsGet200ResponseInnerSerializer implements PrimitiveSerializer<AdminMinVersionsGet200ResponseInner> {
  @override
  final Iterable<Type> types = const [AdminMinVersionsGet200ResponseInner, _$AdminMinVersionsGet200ResponseInner];

  @override
  final String wireName = r'AdminMinVersionsGet200ResponseInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminMinVersionsGet200ResponseInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'platform';
    yield serializers.serialize(
      object.platform,
      specifiedType: const FullType(AdminMinVersionsGet200ResponseInnerPlatformEnum),
    );
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(String),
    );
    yield r'updatedAt';
    yield serializers.serialize(
      object.updatedAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminMinVersionsGet200ResponseInner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminMinVersionsGet200ResponseInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'platform':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdminMinVersionsGet200ResponseInnerPlatformEnum),
          ) as AdminMinVersionsGet200ResponseInnerPlatformEnum;
          result.platform = valueDes;
          break;
        case r'version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.version = valueDes;
          break;
        case r'updatedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.updatedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminMinVersionsGet200ResponseInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminMinVersionsGet200ResponseInnerBuilder();
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

class AdminMinVersionsGet200ResponseInnerPlatformEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'ios')
  static const AdminMinVersionsGet200ResponseInnerPlatformEnum ios = _$adminMinVersionsGet200ResponseInnerPlatformEnum_ios;
  @BuiltValueEnumConst(wireName: r'android')
  static const AdminMinVersionsGet200ResponseInnerPlatformEnum android = _$adminMinVersionsGet200ResponseInnerPlatformEnum_android;

  static Serializer<AdminMinVersionsGet200ResponseInnerPlatformEnum> get serializer => _$adminMinVersionsGet200ResponseInnerPlatformEnumSerializer;

  const AdminMinVersionsGet200ResponseInnerPlatformEnum._(String name): super(name);

  static BuiltSet<AdminMinVersionsGet200ResponseInnerPlatformEnum> get values => _$adminMinVersionsGet200ResponseInnerPlatformEnumValues;
  static AdminMinVersionsGet200ResponseInnerPlatformEnum valueOf(String name) => _$adminMinVersionsGet200ResponseInnerPlatformEnumValueOf(name);
}

