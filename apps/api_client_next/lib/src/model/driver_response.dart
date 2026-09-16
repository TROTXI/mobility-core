//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client_next/src/model/driver.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'driver_response.g.dart';

/// DriverResponse
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class DriverResponse implements Built<DriverResponse, DriverResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  Driver get data;

  DriverResponse._();

  factory DriverResponse([void updates(DriverResponseBuilder b)]) = _$DriverResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DriverResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DriverResponse> get serializer => _$DriverResponseSerializer();
}

class _$DriverResponseSerializer implements PrimitiveSerializer<DriverResponse> {
  @override
  final Iterable<Type> types = const [DriverResponse, _$DriverResponse];

  @override
  final String wireName = r'DriverResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DriverResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(Driver),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DriverResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DriverResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Driver),
          ) as Driver;
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
  DriverResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DriverResponseBuilder();
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

