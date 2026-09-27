//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ops_report_summary_delivery.g.dart';

/// OpsReportSummaryDelivery
///
/// Properties:
/// * [pending]
/// * [failed]
@BuiltValue()
abstract class OpsReportSummaryDelivery
    implements
        Built<OpsReportSummaryDelivery, OpsReportSummaryDeliveryBuilder> {
  @BuiltValueField(wireName: r'pending')
  int get pending;

  @BuiltValueField(wireName: r'failed')
  int get failed;

  OpsReportSummaryDelivery._();

  factory OpsReportSummaryDelivery(
          [void updates(OpsReportSummaryDeliveryBuilder b)]) =
      _$OpsReportSummaryDelivery;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OpsReportSummaryDeliveryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OpsReportSummaryDelivery> get serializer =>
      _$OpsReportSummaryDeliverySerializer();
}

class _$OpsReportSummaryDeliverySerializer
    implements PrimitiveSerializer<OpsReportSummaryDelivery> {
  @override
  final Iterable<Type> types = const [
    OpsReportSummaryDelivery,
    _$OpsReportSummaryDelivery
  ];

  @override
  final String wireName = r'OpsReportSummaryDelivery';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OpsReportSummaryDelivery object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'pending';
    yield serializers.serialize(
      object.pending,
      specifiedType: const FullType(int),
    );
    yield r'failed';
    yield serializers.serialize(
      object.failed,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OpsReportSummaryDelivery object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OpsReportSummaryDeliveryBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'pending':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.pending = valueDes;
          break;
        case r'failed':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.failed = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OpsReportSummaryDelivery deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OpsReportSummaryDeliveryBuilder();
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
