//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'me_get200_response.g.dart';

/// MeGet200Response
///
/// Properties:
/// * [id] 
/// * [displayName] 
/// * [phone] 
/// * [avatarUrl] 
/// * [role] 
/// * [createdAt] 
@BuiltValue()
abstract class MeGet200Response implements Built<MeGet200Response, MeGet200ResponseBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'displayName')
  String get displayName;

  @BuiltValueField(wireName: r'phone')
  String? get phone;

  @BuiltValueField(wireName: r'avatarUrl')
  String? get avatarUrl;

  @BuiltValueField(wireName: r'role')
  MeGet200ResponseRoleEnum get role;
  // enum roleEnum {  commuter,  driver,  admin,  };

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  MeGet200Response._();

  factory MeGet200Response([void updates(MeGet200ResponseBuilder b)]) = _$MeGet200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MeGet200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MeGet200Response> get serializer => _$MeGet200ResponseSerializer();
}

class _$MeGet200ResponseSerializer implements PrimitiveSerializer<MeGet200Response> {
  @override
  final Iterable<Type> types = const [MeGet200Response, _$MeGet200Response];

  @override
  final String wireName = r'MeGet200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MeGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'displayName';
    yield serializers.serialize(
      object.displayName,
      specifiedType: const FullType(String),
    );
    yield r'phone';
    yield object.phone == null ? null : serializers.serialize(
      object.phone,
      specifiedType: const FullType.nullable(String),
    );
    yield r'avatarUrl';
    yield object.avatarUrl == null ? null : serializers.serialize(
      object.avatarUrl,
      specifiedType: const FullType.nullable(String),
    );
    yield r'role';
    yield serializers.serialize(
      object.role,
      specifiedType: const FullType(MeGet200ResponseRoleEnum),
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
    MeGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MeGet200ResponseBuilder result,
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
        case r'displayName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.displayName = valueDes;
          break;
        case r'phone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.phone = valueDes;
          break;
        case r'avatarUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.avatarUrl = valueDes;
          break;
        case r'role':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MeGet200ResponseRoleEnum),
          ) as MeGet200ResponseRoleEnum;
          result.role = valueDes;
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
  MeGet200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MeGet200ResponseBuilder();
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

class MeGet200ResponseRoleEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'commuter')
  static const MeGet200ResponseRoleEnum commuter = _$meGet200ResponseRoleEnum_commuter;
  @BuiltValueEnumConst(wireName: r'driver')
  static const MeGet200ResponseRoleEnum driver = _$meGet200ResponseRoleEnum_driver;
  @BuiltValueEnumConst(wireName: r'admin')
  static const MeGet200ResponseRoleEnum admin = _$meGet200ResponseRoleEnum_admin;

  static Serializer<MeGet200ResponseRoleEnum> get serializer => _$meGet200ResponseRoleEnumSerializer;

  const MeGet200ResponseRoleEnum._(String name): super(name);

  static BuiltSet<MeGet200ResponseRoleEnum> get values => _$meGet200ResponseRoleEnumValues;
  static MeGet200ResponseRoleEnum valueOf(String name) => _$meGet200ResponseRoleEnumValueOf(name);
}

