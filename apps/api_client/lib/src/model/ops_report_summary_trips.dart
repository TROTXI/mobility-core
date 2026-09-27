//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ops_report_summary_trips.g.dart';

/// OpsReportSummaryTrips
///
/// Properties:
/// * [total] 
/// * [completed] 
/// * [cancelled] 
/// * [boarded] 
/// * [noShows] 
@BuiltValue()
abstract class OpsReportSummaryTrips implements Built<OpsReportSummaryTrips, OpsReportSummaryTripsBuilder> {
  @BuiltValueField(wireName: r'total')
  int get total;

  @BuiltValueField(wireName: r'completed')
  int get completed;

  @BuiltValueField(wireName: r'cancelled')
  int get cancelled;

  @BuiltValueField(wireName: r'boarded')
  int get boarded;

  @BuiltValueField(wireName: r'noShows')
  int get noShows;

  OpsReportSummaryTrips._();

  factory OpsReportSummaryTrips([void updates(OpsReportSummaryTripsBuilder b)]) = _$OpsReportSummaryTrips;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OpsReportSummaryTripsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OpsReportSummaryTrips> get serializer => _$OpsReportSummaryTripsSerializer();
}

class _$OpsReportSummaryTripsSerializer implements PrimitiveSerializer<OpsReportSummaryTrips> {
  @override
  final Iterable<Type> types = const [OpsReportSummaryTrips, _$OpsReportSummaryTrips];

  @override
  final String wireName = r'OpsReportSummaryTrips';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OpsReportSummaryTrips object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'total';
    yield serializers.serialize(
      object.total,
      specifiedType: const FullType(int),
    );
    yield r'completed';
    yield serializers.serialize(
      object.completed,
      specifiedType: const FullType(int),
    );
    yield r'cancelled';
    yield serializers.serialize(
      object.cancelled,
      specifiedType: const FullType(int),
    );
    yield r'boarded';
    yield serializers.serialize(
      object.boarded,
      specifiedType: const FullType(int),
    );
    yield r'noShows';
    yield serializers.serialize(
      object.noShows,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OpsReportSummaryTrips object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OpsReportSummaryTripsBuilder result,
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
        case r'completed':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.completed = valueDes;
          break;
        case r'cancelled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.cancelled = valueDes;
          break;
        case r'boarded':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.boarded = valueDes;
          break;
        case r'noShows':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.noShows = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OpsReportSummaryTrips deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OpsReportSummaryTripsBuilder();
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

