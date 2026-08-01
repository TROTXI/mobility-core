//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/trips_id_position_get200_response_position.dart';
import 'package:trotxi_api_client/src/model/trips_id_position_get200_response_eta_to_stops_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'trips_id_position_get200_response.g.dart';

/// TripsIdPositionGet200Response
///
/// Properties:
/// * [tripId] 
/// * [position] 
/// * [etaToStops] 
@BuiltValue()
abstract class TripsIdPositionGet200Response implements Built<TripsIdPositionGet200Response, TripsIdPositionGet200ResponseBuilder> {
  @BuiltValueField(wireName: r'tripId')
  String get tripId;

  @BuiltValueField(wireName: r'position')
  TripsIdPositionGet200ResponsePosition get position;

  @BuiltValueField(wireName: r'etaToStops')
  BuiltList<TripsIdPositionGet200ResponseEtaToStopsInner> get etaToStops;

  TripsIdPositionGet200Response._();

  factory TripsIdPositionGet200Response([void updates(TripsIdPositionGet200ResponseBuilder b)]) = _$TripsIdPositionGet200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TripsIdPositionGet200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TripsIdPositionGet200Response> get serializer => _$TripsIdPositionGet200ResponseSerializer();
}

class _$TripsIdPositionGet200ResponseSerializer implements PrimitiveSerializer<TripsIdPositionGet200Response> {
  @override
  final Iterable<Type> types = const [TripsIdPositionGet200Response, _$TripsIdPositionGet200Response];

  @override
  final String wireName = r'TripsIdPositionGet200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TripsIdPositionGet200Response object, {
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
    yield r'etaToStops';
    yield serializers.serialize(
      object.etaToStops,
      specifiedType: const FullType(BuiltList, [FullType(TripsIdPositionGet200ResponseEtaToStopsInner)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TripsIdPositionGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TripsIdPositionGet200ResponseBuilder result,
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
        case r'etaToStops':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(TripsIdPositionGet200ResponseEtaToStopsInner)]),
          ) as BuiltList<TripsIdPositionGet200ResponseEtaToStopsInner>;
          result.etaToStops.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TripsIdPositionGet200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TripsIdPositionGet200ResponseBuilder();
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

