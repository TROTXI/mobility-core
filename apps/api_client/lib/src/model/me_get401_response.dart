//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'me_get401_response.g.dart';

/// MeGet401Response
///
/// Properties:
/// * [error] 
/// * [message] 
@BuiltValue()
abstract class MeGet401Response implements Built<MeGet401Response, MeGet401ResponseBuilder> {
  @BuiltValueField(wireName: r'error')
  String get error;

  @BuiltValueField(wireName: r'message')
  String get message;

  MeGet401Response._();

  factory MeGet401Response([void updates(MeGet401ResponseBuilder b)]) = _$MeGet401Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MeGet401ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MeGet401Response> get serializer => _$MeGet401ResponseSerializer();
}

class _$MeGet401ResponseSerializer implements PrimitiveSerializer<MeGet401Response> {
  @override
  final Iterable<Type> types = const [MeGet401Response, _$MeGet401Response];

  @override
  final String wireName = r'MeGet401Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MeGet401Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'error';
    yield serializers.serialize(
      object.error,
      specifiedType: const FullType(String),
    );
    yield r'message';
    yield serializers.serialize(
      object.message,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MeGet401Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MeGet401ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'error':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.error = valueDes;
          break;
        case r'message':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.message = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MeGet401Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MeGet401ResponseBuilder();
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

