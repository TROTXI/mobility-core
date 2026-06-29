//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_refresh_post200_response.g.dart';

/// AuthRefreshPost200Response
///
/// Properties:
/// * [accessToken] 
/// * [refreshToken] 
@BuiltValue()
abstract class AuthRefreshPost200Response implements Built<AuthRefreshPost200Response, AuthRefreshPost200ResponseBuilder> {
  @BuiltValueField(wireName: r'accessToken')
  String get accessToken;

  @BuiltValueField(wireName: r'refreshToken')
  String get refreshToken;

  AuthRefreshPost200Response._();

  factory AuthRefreshPost200Response([void updates(AuthRefreshPost200ResponseBuilder b)]) = _$AuthRefreshPost200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthRefreshPost200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthRefreshPost200Response> get serializer => _$AuthRefreshPost200ResponseSerializer();
}

class _$AuthRefreshPost200ResponseSerializer implements PrimitiveSerializer<AuthRefreshPost200Response> {
  @override
  final Iterable<Type> types = const [AuthRefreshPost200Response, _$AuthRefreshPost200Response];

  @override
  final String wireName = r'AuthRefreshPost200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthRefreshPost200Response object, {
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
  }

  @override
  Object serialize(
    Serializers serializers,
    AuthRefreshPost200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AuthRefreshPost200ResponseBuilder result,
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AuthRefreshPost200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthRefreshPost200ResponseBuilder();
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

