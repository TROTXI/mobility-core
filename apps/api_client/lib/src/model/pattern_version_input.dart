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
<<<<<<< HEAD
/// * [stops] 
/// * [geometry] 
@BuiltValue()
abstract class PatternVersionInput implements Built<PatternVersionInput, PatternVersionInputBuilder> {
=======
/// * [stops]
/// * [geometry]
@BuiltValue()
abstract class PatternVersionInput
    implements Built<PatternVersionInput, PatternVersionInputBuilder> {
>>>>>>> origin/main
  @BuiltValueField(wireName: r'stops')
  BuiltList<PatternVersionInputStopsInner> get stops;

  @BuiltValueField(wireName: r'geometry')
  PatternVersionInputGeometry get geometry;

  PatternVersionInput._();

<<<<<<< HEAD
  factory PatternVersionInput([void updates(PatternVersionInputBuilder b)]) = _$PatternVersionInput;
=======
  factory PatternVersionInput([void updates(PatternVersionInputBuilder b)]) =
      _$PatternVersionInput;
>>>>>>> origin/main

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PatternVersionInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
<<<<<<< HEAD
  static Serializer<PatternVersionInput> get serializer => _$PatternVersionInputSerializer();
}

class _$PatternVersionInputSerializer implements PrimitiveSerializer<PatternVersionInput> {
  @override
  final Iterable<Type> types = const [PatternVersionInput, _$PatternVersionInput];
=======
  static Serializer<PatternVersionInput> get serializer =>
      _$PatternVersionInputSerializer();
}

class _$PatternVersionInputSerializer
    implements PrimitiveSerializer<PatternVersionInput> {
  @override
  final Iterable<Type> types = const [
    PatternVersionInput,
    _$PatternVersionInput
  ];
>>>>>>> origin/main

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
<<<<<<< HEAD
      specifiedType: const FullType(BuiltList, [FullType(PatternVersionInputStopsInner)]),
=======
      specifiedType:
          const FullType(BuiltList, [FullType(PatternVersionInputStopsInner)]),
>>>>>>> origin/main
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
<<<<<<< HEAD
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
=======
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
>>>>>>> origin/main
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
<<<<<<< HEAD
            specifiedType: const FullType(BuiltList, [FullType(PatternVersionInputStopsInner)]),
=======
            specifiedType: const FullType(
                BuiltList, [FullType(PatternVersionInputStopsInner)]),
>>>>>>> origin/main
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
<<<<<<< HEAD

=======
>>>>>>> origin/main
