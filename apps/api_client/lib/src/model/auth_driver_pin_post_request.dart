//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_driver_pin_post_request.g.dart';

/// AuthDriverPinPostRequest
///
/// Properties:
/// * [currentPin] 
/// * [newPin] 
@BuiltValue()
abstract class AuthDriverPinPostRequest implements Built<AuthDriverPinPostRequest, AuthDriverPinPostRequestBuilder> {
  @BuiltValueField(wireName: r'currentPin')
  String get currentPin;

  @BuiltValueField(wireName: r'newPin')
  String get newPin;

  AuthDriverPinPostRequest._();

  factory AuthDriverPinPostRequest([void updates(AuthDriverPinPostRequestBuilder b)]) = _$AuthDriverPinPostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthDriverPinPostRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthDriverPinPostRequest> get serializer => _$AuthDriverPinPostRequestSerializer();
}

class _$AuthDriverPinPostRequestSerializer implements PrimitiveSerializer<AuthDriverPinPostRequest> {
  @override
  final Iterable<Type> types = const [AuthDriverPinPostRequest, _$AuthDriverPinPostRequest];

  @override
  final String wireName = r'AuthDriverPinPostRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthDriverPinPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'currentPin';
    yield serializers.serialize(
      object.currentPin,
      specifiedType: const FullType(String),
    );
    yield r'newPin';
    yield serializers.serialize(
      object.newPin,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AuthDriverPinPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AuthDriverPinPostRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'currentPin':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.currentPin = valueDes;
          break;
        case r'newPin':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.newPin = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AuthDriverPinPostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthDriverPinPostRequestBuilder();
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

