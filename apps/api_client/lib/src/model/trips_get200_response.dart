//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/trips_get200_response_trips_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'trips_get200_response.g.dart';

/// TripsGet200Response
///
/// Properties:
/// * [trips] 
@BuiltValue()
abstract class TripsGet200Response implements Built<TripsGet200Response, TripsGet200ResponseBuilder> {
  @BuiltValueField(wireName: r'trips')
  BuiltList<TripsGet200ResponseTripsInner> get trips;

  TripsGet200Response._();

  factory TripsGet200Response([void updates(TripsGet200ResponseBuilder b)]) = _$TripsGet200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TripsGet200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TripsGet200Response> get serializer => _$TripsGet200ResponseSerializer();
}

class _$TripsGet200ResponseSerializer implements PrimitiveSerializer<TripsGet200Response> {
  @override
  final Iterable<Type> types = const [TripsGet200Response, _$TripsGet200Response];

  @override
  final String wireName = r'TripsGet200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TripsGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'trips';
    yield serializers.serialize(
      object.trips,
      specifiedType: const FullType(BuiltList, [FullType(TripsGet200ResponseTripsInner)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TripsGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TripsGet200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'trips':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(TripsGet200ResponseTripsInner)]),
          ) as BuiltList<TripsGet200ResponseTripsInner>;
          result.trips.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TripsGet200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TripsGet200ResponseBuilder();
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

