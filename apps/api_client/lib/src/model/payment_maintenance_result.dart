//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/maintenance_result.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'payment_maintenance_result.g.dart';

/// PaymentMaintenanceResult
///
/// Properties:
/// * [inbox] 
/// * [reconciliation] 
/// * [periods] 
@BuiltValue()
abstract class PaymentMaintenanceResult implements Built<PaymentMaintenanceResult, PaymentMaintenanceResultBuilder> {
  @BuiltValueField(wireName: r'inbox')
  MaintenanceResult get inbox;

  @BuiltValueField(wireName: r'reconciliation')
  MaintenanceResult get reconciliation;

  @BuiltValueField(wireName: r'periods')
  MaintenanceResult get periods;

  PaymentMaintenanceResult._();

  factory PaymentMaintenanceResult([void updates(PaymentMaintenanceResultBuilder b)]) = _$PaymentMaintenanceResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PaymentMaintenanceResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PaymentMaintenanceResult> get serializer => _$PaymentMaintenanceResultSerializer();
}

class _$PaymentMaintenanceResultSerializer implements PrimitiveSerializer<PaymentMaintenanceResult> {
  @override
  final Iterable<Type> types = const [PaymentMaintenanceResult, _$PaymentMaintenanceResult];

  @override
  final String wireName = r'PaymentMaintenanceResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PaymentMaintenanceResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'inbox';
    yield serializers.serialize(
      object.inbox,
      specifiedType: const FullType(MaintenanceResult),
    );
    yield r'reconciliation';
    yield serializers.serialize(
      object.reconciliation,
      specifiedType: const FullType(MaintenanceResult),
    );
    yield r'periods';
    yield serializers.serialize(
      object.periods,
      specifiedType: const FullType(MaintenanceResult),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PaymentMaintenanceResult object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PaymentMaintenanceResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'inbox':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MaintenanceResult),
          ) as MaintenanceResult;
          result.inbox.replace(valueDes);
          break;
        case r'reconciliation':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MaintenanceResult),
          ) as MaintenanceResult;
          result.reconciliation.replace(valueDes);
          break;
        case r'periods':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MaintenanceResult),
          ) as MaintenanceResult;
          result.periods.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PaymentMaintenanceResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PaymentMaintenanceResultBuilder();
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

