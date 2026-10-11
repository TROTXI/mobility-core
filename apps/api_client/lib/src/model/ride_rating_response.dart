//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/ride_rating.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ride_rating_response.g.dart';

/// RideRatingResponse
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class RideRatingResponse
    implements Built<RideRatingResponse, RideRatingResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  RideRating get data;

  RideRatingResponse._();

  factory RideRatingResponse([void updates(RideRatingResponseBuilder b)]) =
      _$RideRatingResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RideRatingResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RideRatingResponse> get serializer =>
      _$RideRatingResponseSerializer();
}

class _$RideRatingResponseSerializer
    implements PrimitiveSerializer<RideRatingResponse> {
  @override
  final Iterable<Type> types = const [RideRatingResponse, _$RideRatingResponse];

  @override
  final String wireName = r'RideRatingResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RideRatingResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(RideRating),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RideRatingResponse object, {
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
    required RideRatingResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(RideRating),
          ) as RideRating;
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
  RideRatingResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RideRatingResponseBuilder();
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
