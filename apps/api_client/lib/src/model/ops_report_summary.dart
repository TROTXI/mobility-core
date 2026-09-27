//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/date.dart';
import 'package:trotxi_api_client/src/model/ops_report_summary_delivery.dart';
import 'package:trotxi_api_client/src/model/ops_report_summary_trips.dart';
import 'package:trotxi_api_client/src/model/ops_report_summary_payments.dart';
import 'package:trotxi_api_client/src/model/ops_report_summary_riders.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ops_report_summary.g.dart';

/// OpsReportSummary
///
/// Properties:
/// * [generatedAt] 
/// * [fromDate] 
/// * [toDate] 
/// * [riders] 
/// * [trips] 
/// * [payments] 
/// * [delivery] 
@BuiltValue()
abstract class OpsReportSummary implements Built<OpsReportSummary, OpsReportSummaryBuilder> {
  @BuiltValueField(wireName: r'generatedAt')
  DateTime get generatedAt;

  @BuiltValueField(wireName: r'fromDate')
  Date get fromDate;

  @BuiltValueField(wireName: r'toDate')
  Date get toDate;

  @BuiltValueField(wireName: r'riders')
  OpsReportSummaryRiders get riders;

  @BuiltValueField(wireName: r'trips')
  OpsReportSummaryTrips get trips;

  @BuiltValueField(wireName: r'payments')
  OpsReportSummaryPayments get payments;

  @BuiltValueField(wireName: r'delivery')
  OpsReportSummaryDelivery get delivery;

  OpsReportSummary._();

  factory OpsReportSummary([void updates(OpsReportSummaryBuilder b)]) = _$OpsReportSummary;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OpsReportSummaryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OpsReportSummary> get serializer => _$OpsReportSummarySerializer();
}

class _$OpsReportSummarySerializer implements PrimitiveSerializer<OpsReportSummary> {
  @override
  final Iterable<Type> types = const [OpsReportSummary, _$OpsReportSummary];

  @override
  final String wireName = r'OpsReportSummary';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OpsReportSummary object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'generatedAt';
    yield serializers.serialize(
      object.generatedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'fromDate';
    yield serializers.serialize(
      object.fromDate,
      specifiedType: const FullType(Date),
    );
    yield r'toDate';
    yield serializers.serialize(
      object.toDate,
      specifiedType: const FullType(Date),
    );
    yield r'riders';
    yield serializers.serialize(
      object.riders,
      specifiedType: const FullType(OpsReportSummaryRiders),
    );
    yield r'trips';
    yield serializers.serialize(
      object.trips,
      specifiedType: const FullType(OpsReportSummaryTrips),
    );
    yield r'payments';
    yield serializers.serialize(
      object.payments,
      specifiedType: const FullType(OpsReportSummaryPayments),
    );
    yield r'delivery';
    yield serializers.serialize(
      object.delivery,
      specifiedType: const FullType(OpsReportSummaryDelivery),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OpsReportSummary object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OpsReportSummaryBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'generatedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.generatedAt = valueDes;
          break;
        case r'fromDate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Date),
          ) as Date;
          result.fromDate = valueDes;
          break;
        case r'toDate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Date),
          ) as Date;
          result.toDate = valueDes;
          break;
        case r'riders':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OpsReportSummaryRiders),
          ) as OpsReportSummaryRiders;
          result.riders.replace(valueDes);
          break;
        case r'trips':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OpsReportSummaryTrips),
          ) as OpsReportSummaryTrips;
          result.trips.replace(valueDes);
          break;
        case r'payments':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OpsReportSummaryPayments),
          ) as OpsReportSummaryPayments;
          result.payments.replace(valueDes);
          break;
        case r'delivery':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OpsReportSummaryDelivery),
          ) as OpsReportSummaryDelivery;
          result.delivery.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OpsReportSummary deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OpsReportSummaryBuilder();
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

