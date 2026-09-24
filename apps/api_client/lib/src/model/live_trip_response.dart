//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/live_trip.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'live_trip_response.g.dart';

/// LiveTripResponse
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class LiveTripResponse implements Built<LiveTripResponse, LiveTripResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  LiveTrip get data;

  LiveTripResponse._();

  factory LiveTripResponse([void updates(LiveTripResponseBuilder b)]) = _$LiveTripResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(LiveTripResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<LiveTripResponse> get serializer => _$LiveTripResponseSerializer();
}

class _$LiveTripResponseSerializer implements PrimitiveSerializer<LiveTripResponse> {
  @override
  final Iterable<Type> types = const [LiveTripResponse, _$LiveTripResponse];

  @override
  final String wireName = r'LiveTripResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    LiveTripResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(LiveTrip),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    LiveTripResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required LiveTripResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(LiveTrip),
          ) as LiveTrip;
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
  LiveTripResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = LiveTripResponseBuilder();
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

