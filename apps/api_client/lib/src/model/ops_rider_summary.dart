//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/money.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ops_rider_summary.g.dart';

/// OpsRiderSummary
///
/// Properties:
/// * [generatedAt] 
/// * [active] 
/// * [paused] 
/// * [lapsed] 
/// * [monthly] 
/// * [annual] 
/// * [creditOutstanding] 
/// * [averageRidesUsed] 
@BuiltValue()
abstract class OpsRiderSummary implements Built<OpsRiderSummary, OpsRiderSummaryBuilder> {
  @BuiltValueField(wireName: r'generatedAt')
  DateTime get generatedAt;

  @BuiltValueField(wireName: r'active')
  int get active;

  @BuiltValueField(wireName: r'paused')
  int get paused;

  @BuiltValueField(wireName: r'lapsed')
  int get lapsed;

  @BuiltValueField(wireName: r'monthly')
  int get monthly;

  @BuiltValueField(wireName: r'annual')
  int get annual;

  @BuiltValueField(wireName: r'creditOutstanding')
  Money get creditOutstanding;

  @BuiltValueField(wireName: r'averageRidesUsed')
  num? get averageRidesUsed;

  OpsRiderSummary._();

  factory OpsRiderSummary([void updates(OpsRiderSummaryBuilder b)]) = _$OpsRiderSummary;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OpsRiderSummaryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OpsRiderSummary> get serializer => _$OpsRiderSummarySerializer();
}

class _$OpsRiderSummarySerializer implements PrimitiveSerializer<OpsRiderSummary> {
  @override
  final Iterable<Type> types = const [OpsRiderSummary, _$OpsRiderSummary];

  @override
  final String wireName = r'OpsRiderSummary';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OpsRiderSummary object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'generatedAt';
    yield serializers.serialize(
      object.generatedAt,
      specifiedType: const FullType(DateTime),
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
    yield r'lapsed';
    yield serializers.serialize(
      object.lapsed,
      specifiedType: const FullType(int),
    );
    yield r'monthly';
    yield serializers.serialize(
      object.monthly,
      specifiedType: const FullType(int),
    );
    yield r'annual';
    yield serializers.serialize(
      object.annual,
      specifiedType: const FullType(int),
    );
    yield r'creditOutstanding';
    yield serializers.serialize(
      object.creditOutstanding,
      specifiedType: const FullType(Money),
    );
    yield r'averageRidesUsed';
    yield object.averageRidesUsed == null ? null : serializers.serialize(
      object.averageRidesUsed,
      specifiedType: const FullType.nullable(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OpsRiderSummary object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OpsRiderSummaryBuilder result,
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
        case r'lapsed':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.lapsed = valueDes;
          break;
        case r'monthly':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.monthly = valueDes;
          break;
        case r'annual':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.annual = valueDes;
          break;
        case r'creditOutstanding':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Money),
          ) as Money;
          result.creditOutstanding.replace(valueDes);
          break;
        case r'averageRidesUsed':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.averageRidesUsed = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OpsRiderSummary deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OpsRiderSummaryBuilder();
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

