//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_driver_post200_response_driver.g.dart';

/// AuthDriverPost200ResponseDriver
///
/// Properties:
/// * [id] 
/// * [fullName] 
@BuiltValue()
abstract class AuthDriverPost200ResponseDriver implements Built<AuthDriverPost200ResponseDriver, AuthDriverPost200ResponseDriverBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'fullName')
  String get fullName;

  AuthDriverPost200ResponseDriver._();

  factory AuthDriverPost200ResponseDriver([void updates(AuthDriverPost200ResponseDriverBuilder b)]) = _$AuthDriverPost200ResponseDriver;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthDriverPost200ResponseDriverBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthDriverPost200ResponseDriver> get serializer => _$AuthDriverPost200ResponseDriverSerializer();
}

class _$AuthDriverPost200ResponseDriverSerializer implements PrimitiveSerializer<AuthDriverPost200ResponseDriver> {
  @override
  final Iterable<Type> types = const [AuthDriverPost200ResponseDriver, _$AuthDriverPost200ResponseDriver];

  @override
  final String wireName = r'AuthDriverPost200ResponseDriver';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthDriverPost200ResponseDriver object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'fullName';
    yield serializers.serialize(
      object.fullName,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AuthDriverPost200ResponseDriver object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AuthDriverPost200ResponseDriverBuilder result,
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
        case r'fullName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.fullName = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AuthDriverPost200ResponseDriver deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthDriverPost200ResponseDriverBuilder();
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

