//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client_next/src/model/driver_trip.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'driver_trip_response.g.dart';

/// DriverTripResponse
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class DriverTripResponse implements Built<DriverTripResponse, DriverTripResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  DriverTrip get data;

  DriverTripResponse._();

  factory DriverTripResponse([void updates(DriverTripResponseBuilder b)]) = _$DriverTripResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DriverTripResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DriverTripResponse> get serializer => _$DriverTripResponseSerializer();
}

class _$DriverTripResponseSerializer implements PrimitiveSerializer<DriverTripResponse> {
  @override
  final Iterable<Type> types = const [DriverTripResponse, _$DriverTripResponse];

  @override
  final String wireName = r'DriverTripResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DriverTripResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(DriverTrip),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DriverTripResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DriverTripResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DriverTrip),
          ) as DriverTrip;
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
  DriverTripResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DriverTripResponseBuilder();
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

