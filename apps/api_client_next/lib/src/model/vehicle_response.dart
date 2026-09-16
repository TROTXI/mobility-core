//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client_next/src/model/vehicle.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'vehicle_response.g.dart';

/// VehicleResponse
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class VehicleResponse implements Built<VehicleResponse, VehicleResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  Vehicle get data;

  VehicleResponse._();

  factory VehicleResponse([void updates(VehicleResponseBuilder b)]) = _$VehicleResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(VehicleResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<VehicleResponse> get serializer => _$VehicleResponseSerializer();
}

class _$VehicleResponseSerializer implements PrimitiveSerializer<VehicleResponse> {
  @override
  final Iterable<Type> types = const [VehicleResponse, _$VehicleResponse];

  @override
  final String wireName = r'VehicleResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    VehicleResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(Vehicle),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    VehicleResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required VehicleResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Vehicle),
          ) as Vehicle;
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
  VehicleResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = VehicleResponseBuilder();
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

