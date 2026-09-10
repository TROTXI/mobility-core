//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_drivers_id_credentials_post201_response.g.dart';

/// AdminDriversIdCredentialsPost201Response
///
/// Properties:
/// * [driverCode] 
/// * [pin] 
@BuiltValue()
abstract class AdminDriversIdCredentialsPost201Response implements Built<AdminDriversIdCredentialsPost201Response, AdminDriversIdCredentialsPost201ResponseBuilder> {
  @BuiltValueField(wireName: r'driverCode')
  String get driverCode;

  @BuiltValueField(wireName: r'pin')
  String get pin;

  AdminDriversIdCredentialsPost201Response._();

  factory AdminDriversIdCredentialsPost201Response([void updates(AdminDriversIdCredentialsPost201ResponseBuilder b)]) = _$AdminDriversIdCredentialsPost201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminDriversIdCredentialsPost201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminDriversIdCredentialsPost201Response> get serializer => _$AdminDriversIdCredentialsPost201ResponseSerializer();
}

class _$AdminDriversIdCredentialsPost201ResponseSerializer implements PrimitiveSerializer<AdminDriversIdCredentialsPost201Response> {
  @override
  final Iterable<Type> types = const [AdminDriversIdCredentialsPost201Response, _$AdminDriversIdCredentialsPost201Response];

  @override
  final String wireName = r'AdminDriversIdCredentialsPost201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminDriversIdCredentialsPost201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'driverCode';
    yield serializers.serialize(
      object.driverCode,
      specifiedType: const FullType(String),
    );
    yield r'pin';
    yield serializers.serialize(
      object.pin,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminDriversIdCredentialsPost201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminDriversIdCredentialsPost201ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'driverCode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.driverCode = valueDes;
          break;
        case r'pin':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.pin = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminDriversIdCredentialsPost201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminDriversIdCredentialsPost201ResponseBuilder();
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

