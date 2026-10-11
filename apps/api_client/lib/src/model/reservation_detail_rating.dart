//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'reservation_detail_rating.g.dart';

/// ReservationDetailRating
///
/// Properties:
/// * [stars]
/// * [ratedAt]
@BuiltValue()
abstract class ReservationDetailRating
    implements Built<ReservationDetailRating, ReservationDetailRatingBuilder> {
  @BuiltValueField(wireName: r'stars')
  int get stars;

  @BuiltValueField(wireName: r'ratedAt')
  DateTime get ratedAt;

  ReservationDetailRating._();

  factory ReservationDetailRating(
          [void updates(ReservationDetailRatingBuilder b)]) =
      _$ReservationDetailRating;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReservationDetailRatingBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReservationDetailRating> get serializer =>
      _$ReservationDetailRatingSerializer();
}

class _$ReservationDetailRatingSerializer
    implements PrimitiveSerializer<ReservationDetailRating> {
  @override
  final Iterable<Type> types = const [
    ReservationDetailRating,
    _$ReservationDetailRating
  ];

  @override
  final String wireName = r'ReservationDetailRating';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReservationDetailRating object, {
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
    ReservationDetailRating object, {
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
    required ReservationDetailRatingBuilder result,
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
  ReservationDetailRating deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReservationDetailRatingBuilder();
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
