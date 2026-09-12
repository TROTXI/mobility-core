//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_google_post_request.g.dart';

/// AuthGooglePostRequest
///
/// Properties:
/// * [idToken] 
@BuiltValue()
abstract class AuthGooglePostRequest implements Built<AuthGooglePostRequest, AuthGooglePostRequestBuilder> {
  @BuiltValueField(wireName: r'idToken')
  String get idToken;

  AuthGooglePostRequest._();

  factory AuthGooglePostRequest([void updates(AuthGooglePostRequestBuilder b)]) = _$AuthGooglePostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthGooglePostRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthGooglePostRequest> get serializer => _$AuthGooglePostRequestSerializer();
}

class _$AuthGooglePostRequestSerializer implements PrimitiveSerializer<AuthGooglePostRequest> {
  @override
  final Iterable<Type> types = const [AuthGooglePostRequest, _$AuthGooglePostRequest];

  @override
  final String wireName = r'AuthGooglePostRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthGooglePostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'idToken';
    yield serializers.serialize(
      object.idToken,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AuthGooglePostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AuthGooglePostRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'idToken':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.idToken = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AuthGooglePostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthGooglePostRequestBuilder();
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

