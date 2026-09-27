//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/pattern.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pattern_response.g.dart';

/// PatternResponse
///
/// Properties:
<<<<<<< HEAD
/// * [data] 
@BuiltValue()
abstract class PatternResponse implements Built<PatternResponse, PatternResponseBuilder> {
=======
/// * [data]
@BuiltValue()
abstract class PatternResponse
    implements Built<PatternResponse, PatternResponseBuilder> {
>>>>>>> origin/main
  @BuiltValueField(wireName: r'data')
  Pattern get data;

  PatternResponse._();

<<<<<<< HEAD
  factory PatternResponse([void updates(PatternResponseBuilder b)]) = _$PatternResponse;
=======
  factory PatternResponse([void updates(PatternResponseBuilder b)]) =
      _$PatternResponse;
>>>>>>> origin/main

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PatternResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
<<<<<<< HEAD
  static Serializer<PatternResponse> get serializer => _$PatternResponseSerializer();
}

class _$PatternResponseSerializer implements PrimitiveSerializer<PatternResponse> {
=======
  static Serializer<PatternResponse> get serializer =>
      _$PatternResponseSerializer();
}

class _$PatternResponseSerializer
    implements PrimitiveSerializer<PatternResponse> {
>>>>>>> origin/main
  @override
  final Iterable<Type> types = const [PatternResponse, _$PatternResponse];

  @override
  final String wireName = r'PatternResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PatternResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(Pattern),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PatternResponse object, {
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
    required PatternResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Pattern),
          ) as Pattern;
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
  PatternResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PatternResponseBuilder();
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
