//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/driver_trip.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'driver_trip_response.g.dart';

/// DriverTripResponse
///
/// Properties:
<<<<<<< HEAD
/// * [data] 
@BuiltValue()
abstract class DriverTripResponse implements Built<DriverTripResponse, DriverTripResponseBuilder> {
=======
/// * [data]
@BuiltValue()
abstract class DriverTripResponse
    implements Built<DriverTripResponse, DriverTripResponseBuilder> {
>>>>>>> origin/main
  @BuiltValueField(wireName: r'data')
  DriverTrip get data;

  DriverTripResponse._();

<<<<<<< HEAD
  factory DriverTripResponse([void updates(DriverTripResponseBuilder b)]) = _$DriverTripResponse;
=======
  factory DriverTripResponse([void updates(DriverTripResponseBuilder b)]) =
      _$DriverTripResponse;
>>>>>>> origin/main

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DriverTripResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
<<<<<<< HEAD
  static Serializer<DriverTripResponse> get serializer => _$DriverTripResponseSerializer();
}

class _$DriverTripResponseSerializer implements PrimitiveSerializer<DriverTripResponse> {
=======
  static Serializer<DriverTripResponse> get serializer =>
      _$DriverTripResponseSerializer();
}

class _$DriverTripResponseSerializer
    implements PrimitiveSerializer<DriverTripResponse> {
>>>>>>> origin/main
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
<<<<<<< HEAD
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
=======
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
>>>>>>> origin/main
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
<<<<<<< HEAD

=======
>>>>>>> origin/main
