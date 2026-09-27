//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/ops_rider_summary.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ops_rider_summary_response.g.dart';

/// OpsRiderSummaryResponse
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class OpsRiderSummaryResponse implements Built<OpsRiderSummaryResponse, OpsRiderSummaryResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  OpsRiderSummary get data;

  OpsRiderSummaryResponse._();

  factory OpsRiderSummaryResponse([void updates(OpsRiderSummaryResponseBuilder b)]) = _$OpsRiderSummaryResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OpsRiderSummaryResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OpsRiderSummaryResponse> get serializer => _$OpsRiderSummaryResponseSerializer();
}

class _$OpsRiderSummaryResponseSerializer implements PrimitiveSerializer<OpsRiderSummaryResponse> {
  @override
  final Iterable<Type> types = const [OpsRiderSummaryResponse, _$OpsRiderSummaryResponse];

  @override
  final String wireName = r'OpsRiderSummaryResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OpsRiderSummaryResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(OpsRiderSummary),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OpsRiderSummaryResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OpsRiderSummaryResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OpsRiderSummary),
          ) as OpsRiderSummary;
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
  OpsRiderSummaryResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OpsRiderSummaryResponseBuilder();
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

