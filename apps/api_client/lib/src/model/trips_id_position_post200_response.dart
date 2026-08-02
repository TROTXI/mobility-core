//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/trips_id_position_get200_response_position.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'trips_id_position_post200_response.g.dart';

/// TripsIdPositionPost200Response
///
/// Properties:
/// * [tripId] 
/// * [position] 
@BuiltValue()
abstract class TripsIdPositionPost200Response implements Built<TripsIdPositionPost200Response, TripsIdPositionPost200ResponseBuilder> {
  @BuiltValueField(wireName: r'tripId')
  String get tripId;

  @BuiltValueField(wireName: r'position')
  TripsIdPositionGet200ResponsePosition get position;

  TripsIdPositionPost200Response._();

  factory TripsIdPositionPost200Response([void updates(TripsIdPositionPost200ResponseBuilder b)]) = _$TripsIdPositionPost200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TripsIdPositionPost200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TripsIdPositionPost200Response> get serializer => _$TripsIdPositionPost200ResponseSerializer();
}

class _$TripsIdPositionPost200ResponseSerializer implements PrimitiveSerializer<TripsIdPositionPost200Response> {
  @override
  final Iterable<Type> types = const [TripsIdPositionPost200Response, _$TripsIdPositionPost200Response];

  @override
  final String wireName = r'TripsIdPositionPost200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TripsIdPositionPost200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'tripId';
    yield serializers.serialize(
      object.tripId,
      specifiedType: const FullType(String),
    );
    yield r'position';
    yield serializers.serialize(
      object.position,
      specifiedType: const FullType(TripsIdPositionGet200ResponsePosition),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TripsIdPositionPost200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TripsIdPositionPost200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'tripId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.tripId = valueDes;
          break;
        case r'position':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(TripsIdPositionGet200ResponsePosition),
          ) as TripsIdPositionGet200ResponsePosition;
          result.position.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TripsIdPositionPost200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TripsIdPositionPost200ResponseBuilder();
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

