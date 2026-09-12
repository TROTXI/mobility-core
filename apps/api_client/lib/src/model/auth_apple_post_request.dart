//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_apple_post_request.g.dart';

/// AuthApplePostRequest
///
/// Properties:
/// * [idToken] 
/// * [fullName] 
/// * [nonce] 
/// * [authorizationCode] 
@BuiltValue()
abstract class AuthApplePostRequest implements Built<AuthApplePostRequest, AuthApplePostRequestBuilder> {
  @BuiltValueField(wireName: r'idToken')
  String get idToken;

  @BuiltValueField(wireName: r'fullName')
  String? get fullName;

  @BuiltValueField(wireName: r'nonce')
  String? get nonce;

  @BuiltValueField(wireName: r'authorizationCode')
  String? get authorizationCode;

  AuthApplePostRequest._();

  factory AuthApplePostRequest([void updates(AuthApplePostRequestBuilder b)]) = _$AuthApplePostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthApplePostRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthApplePostRequest> get serializer => _$AuthApplePostRequestSerializer();
}

class _$AuthApplePostRequestSerializer implements PrimitiveSerializer<AuthApplePostRequest> {
  @override
  final Iterable<Type> types = const [AuthApplePostRequest, _$AuthApplePostRequest];

  @override
  final String wireName = r'AuthApplePostRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthApplePostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'idToken';
    yield serializers.serialize(
      object.idToken,
      specifiedType: const FullType(String),
    );
    if (object.fullName != null) {
      yield r'fullName';
      yield serializers.serialize(
        object.fullName,
        specifiedType: const FullType(String),
      );
    }
    if (object.nonce != null) {
      yield r'nonce';
      yield serializers.serialize(
        object.nonce,
        specifiedType: const FullType(String),
      );
    }
    if (object.authorizationCode != null) {
      yield r'authorizationCode';
      yield serializers.serialize(
        object.authorizationCode,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AuthApplePostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AuthApplePostRequestBuilder result,
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
        case r'fullName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.fullName = valueDes;
          break;
        case r'nonce':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.nonce = valueDes;
          break;
        case r'authorizationCode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.authorizationCode = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AuthApplePostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthApplePostRequestBuilder();
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

