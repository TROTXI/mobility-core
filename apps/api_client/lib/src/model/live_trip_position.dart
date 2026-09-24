//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/point.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'live_trip_position.g.dart';

/// LiveTripPosition
///
/// Properties:
/// * [location] 
/// * [capturedAt] 
/// * [receivedAt] 
/// * [ageSeconds] 
@BuiltValue()
abstract class LiveTripPosition implements Built<LiveTripPosition, LiveTripPositionBuilder> {
  @BuiltValueField(wireName: r'location')
  Point get location;

  @BuiltValueField(wireName: r'capturedAt')
  DateTime get capturedAt;

  @BuiltValueField(wireName: r'receivedAt')
  DateTime get receivedAt;

  @BuiltValueField(wireName: r'ageSeconds')
  int get ageSeconds;

  LiveTripPosition._();

  factory LiveTripPosition([void updates(LiveTripPositionBuilder b)]) = _$LiveTripPosition;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(LiveTripPositionBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<LiveTripPosition> get serializer => _$LiveTripPositionSerializer();
}

class _$LiveTripPositionSerializer implements PrimitiveSerializer<LiveTripPosition> {
  @override
  final Iterable<Type> types = const [LiveTripPosition, _$LiveTripPosition];

  @override
  final String wireName = r'LiveTripPosition';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    LiveTripPosition object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'location';
    yield serializers.serialize(
      object.location,
      specifiedType: const FullType(Point),
    );
    yield r'capturedAt';
    yield serializers.serialize(
      object.capturedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'receivedAt';
    yield serializers.serialize(
      object.receivedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'ageSeconds';
    yield serializers.serialize(
      object.ageSeconds,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    LiveTripPosition object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required LiveTripPositionBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'location':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Point),
          ) as Point;
          result.location.replace(valueDes);
          break;
        case r'capturedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.capturedAt = valueDes;
          break;
        case r'receivedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.receivedAt = valueDes;
          break;
        case r'ageSeconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.ageSeconds = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  LiveTripPosition deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = LiveTripPositionBuilder();
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

