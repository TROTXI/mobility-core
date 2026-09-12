//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get200_response.g.dart';

/// Get200Response
///
/// Properties:
/// * [service] 
/// * [version] 
/// * [docs] 
/// * [health] 
@BuiltValue()
abstract class Get200Response implements Built<Get200Response, Get200ResponseBuilder> {
  @BuiltValueField(wireName: r'service')
  String get service;

  @BuiltValueField(wireName: r'version')
  String get version;

  @BuiltValueField(wireName: r'docs')
  String get docs;

  @BuiltValueField(wireName: r'health')
  String get health;

  Get200Response._();

  factory Get200Response([void updates(Get200ResponseBuilder b)]) = _$Get200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(Get200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Get200Response> get serializer => _$Get200ResponseSerializer();
}

class _$Get200ResponseSerializer implements PrimitiveSerializer<Get200Response> {
  @override
  final Iterable<Type> types = const [Get200Response, _$Get200Response];

  @override
  final String wireName = r'Get200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Get200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'service';
    yield serializers.serialize(
      object.service,
      specifiedType: const FullType(String),
    );
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(String),
    );
    yield r'docs';
    yield serializers.serialize(
      object.docs,
      specifiedType: const FullType(String),
    );
    yield r'health';
    yield serializers.serialize(
      object.health,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    Get200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required Get200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'service':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.service = valueDes;
          break;
        case r'version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.version = valueDes;
          break;
        case r'docs':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.docs = valueDes;
          break;
        case r'health':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.health = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Get200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = Get200ResponseBuilder();
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

