//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'me_pass_get200_response.g.dart';

/// MePassGet200Response
///
/// Properties:
/// * [pass] 
/// * [expiresInSeconds] 
@BuiltValue()
abstract class MePassGet200Response implements Built<MePassGet200Response, MePassGet200ResponseBuilder> {
  @BuiltValueField(wireName: r'pass')
  String get pass;

  @BuiltValueField(wireName: r'expiresInSeconds')
  int get expiresInSeconds;

  MePassGet200Response._();

  factory MePassGet200Response([void updates(MePassGet200ResponseBuilder b)]) = _$MePassGet200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MePassGet200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MePassGet200Response> get serializer => _$MePassGet200ResponseSerializer();
}

class _$MePassGet200ResponseSerializer implements PrimitiveSerializer<MePassGet200Response> {
  @override
  final Iterable<Type> types = const [MePassGet200Response, _$MePassGet200Response];

  @override
  final String wireName = r'MePassGet200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MePassGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'pass';
    yield serializers.serialize(
      object.pass,
      specifiedType: const FullType(String),
    );
    yield r'expiresInSeconds';
    yield serializers.serialize(
      object.expiresInSeconds,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MePassGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MePassGet200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'pass':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.pass = valueDes;
          break;
        case r'expiresInSeconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.expiresInSeconds = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MePassGet200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MePassGet200ResponseBuilder();
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

