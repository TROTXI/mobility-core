//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/ops_report_summary.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ops_report_summary_response.g.dart';

/// OpsReportSummaryResponse
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class OpsReportSummaryResponse
    implements
        Built<OpsReportSummaryResponse, OpsReportSummaryResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  OpsReportSummary get data;

  OpsReportSummaryResponse._();

  factory OpsReportSummaryResponse(
          [void updates(OpsReportSummaryResponseBuilder b)]) =
      _$OpsReportSummaryResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OpsReportSummaryResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OpsReportSummaryResponse> get serializer =>
      _$OpsReportSummaryResponseSerializer();
}

class _$OpsReportSummaryResponseSerializer
    implements PrimitiveSerializer<OpsReportSummaryResponse> {
  @override
  final Iterable<Type> types = const [
    OpsReportSummaryResponse,
    _$OpsReportSummaryResponse
  ];

  @override
  final String wireName = r'OpsReportSummaryResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OpsReportSummaryResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(OpsReportSummary),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OpsReportSummaryResponse object, {
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
    required OpsReportSummaryResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OpsReportSummary),
          ) as OpsReportSummary;
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
  OpsReportSummaryResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OpsReportSummaryResponseBuilder();
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
