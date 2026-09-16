//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/pattern_version_input_stops_inner.dart';
import 'package:trotxi_api_client/src/model/pattern_version_input_geometry.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pattern_version_input.g.dart';

/// PatternVersionInput
///
/// Properties:
/// * [stops] 
/// * [geometry] 
@BuiltValue()
abstract class PatternVersionInput implements Built<PatternVersionInput, PatternVersionInputBuilder> {
  @BuiltValueField(wireName: r'stops')
  BuiltList<PatternVersionInputStopsInner> get stops;

  @BuiltValueField(wireName: r'geometry')
  PatternVersionInputGeometry get geometry;

  PatternVersionInput._();

  factory PatternVersionInput([void updates(PatternVersionInputBuilder b)]) = _$PatternVersionInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PatternVersionInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PatternVersionInput> get serializer => _$PatternVersionInputSerializer();
}

class _$PatternVersionInputSerializer implements PrimitiveSerializer<PatternVersionInput> {
  @override
  final Iterable<Type> types = const [PatternVersionInput, _$PatternVersionInput];

  @override
  final String wireName = r'PatternVersionInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PatternVersionInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'stops';
    yield serializers.serialize(
      object.stops,
      specifiedType: const FullType(BuiltList, [FullType(PatternVersionInputStopsInner)]),
    );
    yield r'geometry';
    yield serializers.serialize(
      object.geometry,
      specifiedType: const FullType(PatternVersionInputGeometry),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PatternVersionInput object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PatternVersionInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'stops':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(PatternVersionInputStopsInner)]),
          ) as BuiltList<PatternVersionInputStopsInner>;
          result.stops.replace(valueDes);
          break;
        case r'geometry':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PatternVersionInputGeometry),
          ) as PatternVersionInputGeometry;
          result.geometry.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PatternVersionInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PatternVersionInputBuilder();
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

