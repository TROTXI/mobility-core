//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/manifest.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'manifest_response.g.dart';

/// ManifestResponse
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class ManifestResponse implements Built<ManifestResponse, ManifestResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  Manifest get data;

  ManifestResponse._();

  factory ManifestResponse([void updates(ManifestResponseBuilder b)]) = _$ManifestResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ManifestResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ManifestResponse> get serializer => _$ManifestResponseSerializer();
}

class _$ManifestResponseSerializer implements PrimitiveSerializer<ManifestResponse> {
  @override
  final Iterable<Type> types = const [ManifestResponse, _$ManifestResponse];

  @override
  final String wireName = r'ManifestResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ManifestResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(Manifest),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ManifestResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ManifestResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Manifest),
          ) as Manifest;
          result.data.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ManifestResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ManifestResponseBuilder();
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

