//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/me_get200_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_google_post200_response.g.dart';

/// AuthGooglePost200Response
///
/// Properties:
/// * [accessToken] 
/// * [refreshToken] 
/// * [user] 
@BuiltValue()
abstract class AuthGooglePost200Response implements Built<AuthGooglePost200Response, AuthGooglePost200ResponseBuilder> {
  @BuiltValueField(wireName: r'accessToken')
  String get accessToken;

  @BuiltValueField(wireName: r'refreshToken')
  String get refreshToken;

  @BuiltValueField(wireName: r'user')
  MeGet200Response get user;

  AuthGooglePost200Response._();

  factory AuthGooglePost200Response([void updates(AuthGooglePost200ResponseBuilder b)]) = _$AuthGooglePost200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthGooglePost200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthGooglePost200Response> get serializer => _$AuthGooglePost200ResponseSerializer();
}

class _$AuthGooglePost200ResponseSerializer implements PrimitiveSerializer<AuthGooglePost200Response> {
  @override
  final Iterable<Type> types = const [AuthGooglePost200Response, _$AuthGooglePost200Response];

  @override
  final String wireName = r'AuthGooglePost200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthGooglePost200Response object, {
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
  }

  @override
  Object serialize(
    Serializers serializers,
    AuthGooglePost200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AuthGooglePost200ResponseBuilder result,
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AuthGooglePost200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthGooglePost200ResponseBuilder();
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

