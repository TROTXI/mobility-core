//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client_next/src/model/pattern_version.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pattern_version_response.g.dart';

/// PatternVersionResponse
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class PatternVersionResponse implements Built<PatternVersionResponse, PatternVersionResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  PatternVersion get data;

  PatternVersionResponse._();

  factory PatternVersionResponse([void updates(PatternVersionResponseBuilder b)]) = _$PatternVersionResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PatternVersionResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PatternVersionResponse> get serializer => _$PatternVersionResponseSerializer();
}

class _$PatternVersionResponseSerializer implements PrimitiveSerializer<PatternVersionResponse> {
  @override
  final Iterable<Type> types = const [PatternVersionResponse, _$PatternVersionResponse];

  @override
  final String wireName = r'PatternVersionResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PatternVersionResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(PatternVersion),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PatternVersionResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PatternVersionResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PatternVersion),
          ) as PatternVersion;
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
  PatternVersionResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PatternVersionResponseBuilder();
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

