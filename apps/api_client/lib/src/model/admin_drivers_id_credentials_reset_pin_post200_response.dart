//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_drivers_id_credentials_reset_pin_post200_response.g.dart';

/// AdminDriversIdCredentialsResetPinPost200Response
///
/// Properties:
/// * [pin] 
@BuiltValue()
abstract class AdminDriversIdCredentialsResetPinPost200Response implements Built<AdminDriversIdCredentialsResetPinPost200Response, AdminDriversIdCredentialsResetPinPost200ResponseBuilder> {
  @BuiltValueField(wireName: r'pin')
  String get pin;

  AdminDriversIdCredentialsResetPinPost200Response._();

  factory AdminDriversIdCredentialsResetPinPost200Response([void updates(AdminDriversIdCredentialsResetPinPost200ResponseBuilder b)]) = _$AdminDriversIdCredentialsResetPinPost200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminDriversIdCredentialsResetPinPost200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminDriversIdCredentialsResetPinPost200Response> get serializer => _$AdminDriversIdCredentialsResetPinPost200ResponseSerializer();
}

class _$AdminDriversIdCredentialsResetPinPost200ResponseSerializer implements PrimitiveSerializer<AdminDriversIdCredentialsResetPinPost200Response> {
  @override
  final Iterable<Type> types = const [AdminDriversIdCredentialsResetPinPost200Response, _$AdminDriversIdCredentialsResetPinPost200Response];

  @override
  final String wireName = r'AdminDriversIdCredentialsResetPinPost200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminDriversIdCredentialsResetPinPost200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'pin';
    yield serializers.serialize(
      object.pin,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminDriversIdCredentialsResetPinPost200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminDriversIdCredentialsResetPinPost200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
  AdminDriversIdCredentialsResetPinPost200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminDriversIdCredentialsResetPinPost200ResponseBuilder();
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

