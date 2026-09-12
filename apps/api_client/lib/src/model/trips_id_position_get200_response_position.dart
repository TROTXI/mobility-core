//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'trips_id_position_get200_response_position.g.dart';

/// TripsIdPositionGet200ResponsePosition
///
/// Properties:
/// * [latitude] 
/// * [longitude] 
/// * [recordedAt] 
@BuiltValue()
abstract class TripsIdPositionGet200ResponsePosition implements Built<TripsIdPositionGet200ResponsePosition, TripsIdPositionGet200ResponsePositionBuilder> {
  @BuiltValueField(wireName: r'latitude')
  num get latitude;

  @BuiltValueField(wireName: r'longitude')
  num get longitude;

  @BuiltValueField(wireName: r'recordedAt')
  DateTime get recordedAt;

  TripsIdPositionGet200ResponsePosition._();

  factory TripsIdPositionGet200ResponsePosition([void updates(TripsIdPositionGet200ResponsePositionBuilder b)]) = _$TripsIdPositionGet200ResponsePosition;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TripsIdPositionGet200ResponsePositionBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TripsIdPositionGet200ResponsePosition> get serializer => _$TripsIdPositionGet200ResponsePositionSerializer();
}

class _$TripsIdPositionGet200ResponsePositionSerializer implements PrimitiveSerializer<TripsIdPositionGet200ResponsePosition> {
  @override
  final Iterable<Type> types = const [TripsIdPositionGet200ResponsePosition, _$TripsIdPositionGet200ResponsePosition];

  @override
  final String wireName = r'TripsIdPositionGet200ResponsePosition';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TripsIdPositionGet200ResponsePosition object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'latitude';
    yield serializers.serialize(
      object.latitude,
      specifiedType: const FullType(num),
    );
    yield r'longitude';
    yield serializers.serialize(
      object.longitude,
      specifiedType: const FullType(num),
    );
    yield r'recordedAt';
    yield serializers.serialize(
      object.recordedAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TripsIdPositionGet200ResponsePosition object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TripsIdPositionGet200ResponsePositionBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'latitude':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.latitude = valueDes;
          break;
        case r'longitude':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.longitude = valueDes;
          break;
        case r'recordedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.recordedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TripsIdPositionGet200ResponsePosition deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TripsIdPositionGet200ResponsePositionBuilder();
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

