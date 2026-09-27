//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/point.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pattern_version_input_stops_inner.g.dart';

/// PatternVersionInputStopsInner
///
/// Properties:
/// * [stopId] 
/// * [name] 
/// * [location] 
@BuiltValue()
abstract class PatternVersionInputStopsInner implements Built<PatternVersionInputStopsInner, PatternVersionInputStopsInnerBuilder> {
  @BuiltValueField(wireName: r'stopId')
  String get stopId;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'location')
  Point get location;

  PatternVersionInputStopsInner._();

  factory PatternVersionInputStopsInner([void updates(PatternVersionInputStopsInnerBuilder b)]) = _$PatternVersionInputStopsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PatternVersionInputStopsInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PatternVersionInputStopsInner> get serializer => _$PatternVersionInputStopsInnerSerializer();
}

class _$PatternVersionInputStopsInnerSerializer implements PrimitiveSerializer<PatternVersionInputStopsInner> {
  @override
  final Iterable<Type> types = const [PatternVersionInputStopsInner, _$PatternVersionInputStopsInner];

  @override
  final String wireName = r'PatternVersionInputStopsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PatternVersionInputStopsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'stopId';
    yield serializers.serialize(
      object.stopId,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'location';
    yield serializers.serialize(
      object.location,
      specifiedType: const FullType(Point),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PatternVersionInputStopsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PatternVersionInputStopsInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'stopId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.stopId = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'location':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Point),
          ) as Point;
          result.location.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PatternVersionInputStopsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PatternVersionInputStopsInnerBuilder();
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

