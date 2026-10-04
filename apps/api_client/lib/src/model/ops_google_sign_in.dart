//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ops_google_sign_in.g.dart';

/// OpsGoogleSignIn
///
/// Properties:
/// * [idToken]
/// * [invitationToken]
@BuiltValue()
abstract class OpsGoogleSignIn
    implements Built<OpsGoogleSignIn, OpsGoogleSignInBuilder> {
  @BuiltValueField(wireName: r'idToken')
  String get idToken;

  @BuiltValueField(wireName: r'invitationToken')
  String? get invitationToken;

  OpsGoogleSignIn._();

  factory OpsGoogleSignIn([void updates(OpsGoogleSignInBuilder b)]) =
      _$OpsGoogleSignIn;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OpsGoogleSignInBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OpsGoogleSignIn> get serializer =>
      _$OpsGoogleSignInSerializer();
}

class _$OpsGoogleSignInSerializer
    implements PrimitiveSerializer<OpsGoogleSignIn> {
  @override
  final Iterable<Type> types = const [OpsGoogleSignIn, _$OpsGoogleSignIn];

  @override
  final String wireName = r'OpsGoogleSignIn';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OpsGoogleSignIn object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'idToken';
    yield serializers.serialize(
      object.idToken,
      specifiedType: const FullType(String),
    );
    if (object.invitationToken != null) {
      yield r'invitationToken';
      yield serializers.serialize(
        object.invitationToken,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    OpsGoogleSignIn object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OpsGoogleSignInBuilder result,
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
        case r'invitationToken':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.invitationToken = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OpsGoogleSignIn deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OpsGoogleSignInBuilder();
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
