//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client_next/src/model/payment_maintenance_result.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'payment_maintenance_result_response.g.dart';

/// PaymentMaintenanceResultResponse
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class PaymentMaintenanceResultResponse implements Built<PaymentMaintenanceResultResponse, PaymentMaintenanceResultResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  PaymentMaintenanceResult get data;

  PaymentMaintenanceResultResponse._();

  factory PaymentMaintenanceResultResponse([void updates(PaymentMaintenanceResultResponseBuilder b)]) = _$PaymentMaintenanceResultResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PaymentMaintenanceResultResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PaymentMaintenanceResultResponse> get serializer => _$PaymentMaintenanceResultResponseSerializer();
}

class _$PaymentMaintenanceResultResponseSerializer implements PrimitiveSerializer<PaymentMaintenanceResultResponse> {
  @override
  final Iterable<Type> types = const [PaymentMaintenanceResultResponse, _$PaymentMaintenanceResultResponse];

  @override
  final String wireName = r'PaymentMaintenanceResultResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PaymentMaintenanceResultResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(PaymentMaintenanceResult),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PaymentMaintenanceResultResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PaymentMaintenanceResultResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PaymentMaintenanceResult),
          ) as PaymentMaintenanceResult;
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
  PaymentMaintenanceResultResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PaymentMaintenanceResultResponseBuilder();
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

