//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/money.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ops_report_summary_payments.g.dart';

/// OpsReportSummaryPayments
///
/// Properties:
/// * [collected]
/// * [refunded]
/// * [openReviews]
@BuiltValue()
abstract class OpsReportSummaryPayments
    implements
        Built<OpsReportSummaryPayments, OpsReportSummaryPaymentsBuilder> {
  @BuiltValueField(wireName: r'collected')
  Money get collected;

  @BuiltValueField(wireName: r'refunded')
  Money get refunded;

  @BuiltValueField(wireName: r'openReviews')
  int get openReviews;

  OpsReportSummaryPayments._();

  factory OpsReportSummaryPayments(
          [void updates(OpsReportSummaryPaymentsBuilder b)]) =
      _$OpsReportSummaryPayments;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OpsReportSummaryPaymentsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OpsReportSummaryPayments> get serializer =>
      _$OpsReportSummaryPaymentsSerializer();
}

class _$OpsReportSummaryPaymentsSerializer
    implements PrimitiveSerializer<OpsReportSummaryPayments> {
  @override
  final Iterable<Type> types = const [
    OpsReportSummaryPayments,
    _$OpsReportSummaryPayments
  ];

  @override
  final String wireName = r'OpsReportSummaryPayments';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OpsReportSummaryPayments object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'collected';
    yield serializers.serialize(
      object.collected,
      specifiedType: const FullType(Money),
    );
    yield r'refunded';
    yield serializers.serialize(
      object.refunded,
      specifiedType: const FullType(Money),
    );
    yield r'openReviews';
    yield serializers.serialize(
      object.openReviews,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OpsReportSummaryPayments object, {
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
    required OpsReportSummaryPaymentsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'collected':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Money),
          ) as Money;
          result.collected.replace(valueDes);
          break;
        case r'refunded':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Money),
          ) as Money;
          result.refunded.replace(valueDes);
          break;
        case r'openReviews':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.openReviews = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OpsReportSummaryPayments deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OpsReportSummaryPaymentsBuilder();
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
