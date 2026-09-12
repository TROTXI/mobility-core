//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/me_get200_response.dart';
import 'package:trotxi_api_client/src/model/auth_driver_post200_response_driver.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_driver_post200_response.g.dart';

/// AuthDriverPost200Response
///
/// Properties:
/// * [accessToken] 
/// * [refreshToken] 
/// * [user] 
/// * [driver] 
/// * [mustChangePin] 
@BuiltValue()
abstract class AuthDriverPost200Response implements Built<AuthDriverPost200Response, AuthDriverPost200ResponseBuilder> {
  @BuiltValueField(wireName: r'accessToken')
  String get accessToken;

  @BuiltValueField(wireName: r'refreshToken')
  String get refreshToken;

  @BuiltValueField(wireName: r'user')
  MeGet200Response get user;

  @BuiltValueField(wireName: r'driver')
  AuthDriverPost200ResponseDriver get driver;

  @BuiltValueField(wireName: r'mustChangePin')
  bool get mustChangePin;

  AuthDriverPost200Response._();

  factory AuthDriverPost200Response([void updates(AuthDriverPost200ResponseBuilder b)]) = _$AuthDriverPost200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthDriverPost200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthDriverPost200Response> get serializer => _$AuthDriverPost200ResponseSerializer();
}

class _$AuthDriverPost200ResponseSerializer implements PrimitiveSerializer<AuthDriverPost200Response> {
  @override
  final Iterable<Type> types = const [AuthDriverPost200Response, _$AuthDriverPost200Response];

  @override
  final String wireName = r'AuthDriverPost200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthDriverPost200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'accessToken';
    yield serializers.serialize(
      object.accessToken,
      specifiedType: const FullType(String),
    );
    yield r'refreshToken';
    yield serializers.serialize(
      object.refreshToken,
      specifiedType: const FullType(String),
    );
    yield r'user';
    yield serializers.serialize(
      object.user,
      specifiedType: const FullType(MeGet200Response),
    );
    yield r'driver';
    yield serializers.serialize(
      object.driver,
      specifiedType: const FullType(AuthDriverPost200ResponseDriver),
    );
    yield r'mustChangePin';
    yield serializers.serialize(
      object.mustChangePin,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AuthDriverPost200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AuthDriverPost200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'accessToken':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.accessToken = valueDes;
          break;
        case r'refreshToken':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.refreshToken = valueDes;
          break;
        case r'user':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MeGet200Response),
          ) as MeGet200Response;
          result.user.replace(valueDes);
          break;
        case r'driver':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AuthDriverPost200ResponseDriver),
          ) as AuthDriverPost200ResponseDriver;
          result.driver.replace(valueDes);
          break;
        case r'mustChangePin':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.mustChangePin = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AuthDriverPost200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthDriverPost200ResponseBuilder();
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

