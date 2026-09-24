//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'google_sign_in.g.dart';

/// GoogleSignIn
///
/// Properties:
/// * [idToken] 
@BuiltValue()
abstract class GoogleSignIn implements Built<GoogleSignIn, GoogleSignInBuilder> {
  @BuiltValueField(wireName: r'idToken')
  String get idToken;

  GoogleSignIn._();

  factory GoogleSignIn([void updates(GoogleSignInBuilder b)]) = _$GoogleSignIn;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GoogleSignInBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GoogleSignIn> get serializer => _$GoogleSignInSerializer();
}

class _$GoogleSignInSerializer implements PrimitiveSerializer<GoogleSignIn> {
  @override
  final Iterable<Type> types = const [GoogleSignIn, _$GoogleSignIn];

  @override
  final String wireName = r'GoogleSignIn';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GoogleSignIn object, {
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
    GoogleSignIn object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GoogleSignInBuilder result,
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
  GoogleSignIn deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GoogleSignInBuilder();
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

