//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ride_rating.g.dart';

/// RideRating
///
/// Properties:
/// * [stars]
/// * [ratedAt]
@BuiltValue()
abstract class RideRating implements Built<RideRating, RideRatingBuilder> {
  @BuiltValueField(wireName: r'stars')
  int get stars;

  @BuiltValueField(wireName: r'ratedAt')
  DateTime get ratedAt;

  RideRating._();

  factory RideRating([void updates(RideRatingBuilder b)]) = _$RideRating;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RideRatingBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RideRating> get serializer => _$RideRatingSerializer();
}

class _$RideRatingSerializer implements PrimitiveSerializer<RideRating> {
  @override
  final Iterable<Type> types = const [RideRating, _$RideRating];

  @override
  final String wireName = r'RideRating';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RideRating object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'stars';
    yield serializers.serialize(
      object.stars,
      specifiedType: const FullType(int),
    );
    yield r'ratedAt';
    yield serializers.serialize(
      object.ratedAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RideRating object, {
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
    required RideRatingBuilder result,
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
        case r'ratedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.ratedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RideRating deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RideRatingBuilder();
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
