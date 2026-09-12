//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'trips_id_get200_response_vehicle.g.dart';

/// TripsIdGet200ResponseVehicle
///
/// Properties:
/// * [registration] 
/// * [make] 
/// * [colour] 
@BuiltValue()
abstract class TripsIdGet200ResponseVehicle implements Built<TripsIdGet200ResponseVehicle, TripsIdGet200ResponseVehicleBuilder> {
  @BuiltValueField(wireName: r'registration')
  String get registration;

  @BuiltValueField(wireName: r'make')
  String? get make;

  @BuiltValueField(wireName: r'colour')
  String? get colour;

  TripsIdGet200ResponseVehicle._();

  factory TripsIdGet200ResponseVehicle([void updates(TripsIdGet200ResponseVehicleBuilder b)]) = _$TripsIdGet200ResponseVehicle;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TripsIdGet200ResponseVehicleBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TripsIdGet200ResponseVehicle> get serializer => _$TripsIdGet200ResponseVehicleSerializer();
}

class _$TripsIdGet200ResponseVehicleSerializer implements PrimitiveSerializer<TripsIdGet200ResponseVehicle> {
  @override
  final Iterable<Type> types = const [TripsIdGet200ResponseVehicle, _$TripsIdGet200ResponseVehicle];

  @override
  final String wireName = r'TripsIdGet200ResponseVehicle';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TripsIdGet200ResponseVehicle object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'registration';
    yield serializers.serialize(
      object.registration,
      specifiedType: const FullType(String),
    );
    yield r'make';
    yield object.make == null ? null : serializers.serialize(
      object.make,
      specifiedType: const FullType.nullable(String),
    );
    yield r'colour';
    yield object.colour == null ? null : serializers.serialize(
      object.colour,
      specifiedType: const FullType.nullable(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TripsIdGet200ResponseVehicle object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TripsIdGet200ResponseVehicleBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'registration':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.registration = valueDes;
          break;
        case r'make':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.make = valueDes;
          break;
        case r'colour':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.colour = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TripsIdGet200ResponseVehicle deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TripsIdGet200ResponseVehicleBuilder();
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


