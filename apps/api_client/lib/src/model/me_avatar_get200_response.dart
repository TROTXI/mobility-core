//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'me_avatar_get200_response.g.dart';

/// MeAvatarGet200Response
///
/// Properties:
/// * [avatarUrl] 
@BuiltValue()
abstract class MeAvatarGet200Response implements Built<MeAvatarGet200Response, MeAvatarGet200ResponseBuilder> {
  @BuiltValueField(wireName: r'avatarUrl')
  String get avatarUrl;

  MeAvatarGet200Response._();

  factory MeAvatarGet200Response([void updates(MeAvatarGet200ResponseBuilder b)]) = _$MeAvatarGet200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MeAvatarGet200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MeAvatarGet200Response> get serializer => _$MeAvatarGet200ResponseSerializer();
}

class _$MeAvatarGet200ResponseSerializer implements PrimitiveSerializer<MeAvatarGet200Response> {
  @override
  final Iterable<Type> types = const [MeAvatarGet200Response, _$MeAvatarGet200Response];

  @override
  final String wireName = r'MeAvatarGet200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MeAvatarGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'avatarUrl';
    yield serializers.serialize(
      object.avatarUrl,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MeAvatarGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MeAvatarGet200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'avatarUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.avatarUrl = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MeAvatarGet200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MeAvatarGet200ResponseBuilder();
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

