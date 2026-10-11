//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ride_rating_input.g.dart';

/// RideRatingInput
///
/// Properties:
/// * [stars]
@BuiltValue()
abstract class RideRatingInput
    implements Built<RideRatingInput, RideRatingInputBuilder> {
  @BuiltValueField(wireName: r'stars')
  int get stars;

  RideRatingInput._();

  factory RideRatingInput([void updates(RideRatingInputBuilder b)]) =
      _$RideRatingInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RideRatingInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RideRatingInput> get serializer =>
      _$RideRatingInputSerializer();
}

class _$RideRatingInputSerializer
    implements PrimitiveSerializer<RideRatingInput> {
  @override
  final Iterable<Type> types = const [RideRatingInput, _$RideRatingInput];

  @override
  final String wireName = r'RideRatingInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RideRatingInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'stars';
    yield serializers.serialize(
      object.stars,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RideRatingInput object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RideRatingInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'stars':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.stars = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RideRatingInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RideRatingInputBuilder();
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
