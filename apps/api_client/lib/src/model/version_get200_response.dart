//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'version_get200_response.g.dart';

/// VersionGet200Response
///
/// Properties:
/// * [name] 
/// * [version] 
/// * [commit] 
@BuiltValue()
abstract class VersionGet200Response implements Built<VersionGet200Response, VersionGet200ResponseBuilder> {
  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'version')
  String get version;

  @BuiltValueField(wireName: r'commit')
  String get commit;

  VersionGet200Response._();

  factory VersionGet200Response([void updates(VersionGet200ResponseBuilder b)]) = _$VersionGet200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(VersionGet200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<VersionGet200Response> get serializer => _$VersionGet200ResponseSerializer();
}

class _$VersionGet200ResponseSerializer implements PrimitiveSerializer<VersionGet200Response> {
  @override
  final Iterable<Type> types = const [VersionGet200Response, _$VersionGet200Response];

  @override
  final String wireName = r'VersionGet200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    VersionGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(String),
    );
    yield r'commit';
    yield serializers.serialize(
      object.commit,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    VersionGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required VersionGet200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.version = valueDes;
          break;
        case r'commit':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.commit = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  VersionGet200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = VersionGet200ResponseBuilder();
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

