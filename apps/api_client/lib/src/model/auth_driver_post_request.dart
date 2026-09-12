//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_driver_post_request.g.dart';

/// AuthDriverPostRequest
///
/// Properties:
/// * [driverCode] 
/// * [pin] 
/// * [rememberDevice] 
@BuiltValue()
abstract class AuthDriverPostRequest implements Built<AuthDriverPostRequest, AuthDriverPostRequestBuilder> {
  @BuiltValueField(wireName: r'driverCode')
  String get driverCode;

  @BuiltValueField(wireName: r'pin')
  String get pin;

  @BuiltValueField(wireName: r'rememberDevice')
  bool? get rememberDevice;

  AuthDriverPostRequest._();

  factory AuthDriverPostRequest([void updates(AuthDriverPostRequestBuilder b)]) = _$AuthDriverPostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthDriverPostRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthDriverPostRequest> get serializer => _$AuthDriverPostRequestSerializer();
}

class _$AuthDriverPostRequestSerializer implements PrimitiveSerializer<AuthDriverPostRequest> {
  @override
  final Iterable<Type> types = const [AuthDriverPostRequest, _$AuthDriverPostRequest];

  @override
  final String wireName = r'AuthDriverPostRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthDriverPostRequest object, {
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
    if (object.rememberDevice != null) {
      yield r'rememberDevice';
      yield serializers.serialize(
        object.rememberDevice,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AuthDriverPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AuthDriverPostRequestBuilder result,
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
        case r'rememberDevice':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.rememberDevice = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AuthDriverPostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthDriverPostRequestBuilder();
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

