//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ops_report_summary_riders.g.dart';

/// OpsReportSummaryRiders
///
/// Properties:
/// * [total] 
/// * [active] 
/// * [paused] 
/// * [restricted] 
@BuiltValue()
abstract class OpsReportSummaryRiders implements Built<OpsReportSummaryRiders, OpsReportSummaryRidersBuilder> {
  @BuiltValueField(wireName: r'total')
  int get total;

  @BuiltValueField(wireName: r'active')
  int get active;

  @BuiltValueField(wireName: r'paused')
  int get paused;

  @BuiltValueField(wireName: r'restricted')
  int get restricted;

  OpsReportSummaryRiders._();

  factory OpsReportSummaryRiders([void updates(OpsReportSummaryRidersBuilder b)]) = _$OpsReportSummaryRiders;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OpsReportSummaryRidersBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OpsReportSummaryRiders> get serializer => _$OpsReportSummaryRidersSerializer();
}

class _$OpsReportSummaryRidersSerializer implements PrimitiveSerializer<OpsReportSummaryRiders> {
  @override
  final Iterable<Type> types = const [OpsReportSummaryRiders, _$OpsReportSummaryRiders];

  @override
  final String wireName = r'OpsReportSummaryRiders';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OpsReportSummaryRiders object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'total';
    yield serializers.serialize(
      object.total,
      specifiedType: const FullType(int),
    );
    yield r'active';
    yield serializers.serialize(
      object.active,
      specifiedType: const FullType(int),
    );
    yield r'paused';
    yield serializers.serialize(
      object.paused,
      specifiedType: const FullType(int),
    );
    yield r'restricted';
    yield serializers.serialize(
      object.restricted,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OpsReportSummaryRiders object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OpsReportSummaryRidersBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.total = valueDes;
          break;
        case r'active':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.active = valueDes;
          break;
        case r'paused':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.paused = valueDes;
          break;
        case r'restricted':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.restricted = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OpsReportSummaryRiders deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OpsReportSummaryRidersBuilder();
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

