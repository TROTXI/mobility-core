//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/date.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'reservation_decision.g.dart';

/// ReservationDecision
///
/// Properties:
/// * [travelDate] 
/// * [direction] 
/// * [decision] 
/// * [tripId] 
@BuiltValue()
abstract class ReservationDecision implements Built<ReservationDecision, ReservationDecisionBuilder> {
  @BuiltValueField(wireName: r'travelDate')
  Date get travelDate;

  @BuiltValueField(wireName: r'direction')
  ReservationDecisionDirectionEnum get direction;
  // enum directionEnum {  outbound,  return,  };

  @BuiltValueField(wireName: r'decision')
  ReservationDecisionDecisionEnum get decision;
  // enum decisionEnum {  confirm,  decline,  };

  @BuiltValueField(wireName: r'tripId')
  String? get tripId;

  ReservationDecision._();

  factory ReservationDecision([void updates(ReservationDecisionBuilder b)]) = _$ReservationDecision;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReservationDecisionBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReservationDecision> get serializer => _$ReservationDecisionSerializer();
}

class _$ReservationDecisionSerializer implements PrimitiveSerializer<ReservationDecision> {
  @override
  final Iterable<Type> types = const [ReservationDecision, _$ReservationDecision];

  @override
  final String wireName = r'ReservationDecision';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReservationDecision object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'travelDate';
    yield serializers.serialize(
      object.travelDate,
      specifiedType: const FullType(Date),
    );
    yield r'direction';
    yield serializers.serialize(
      object.direction,
      specifiedType: const FullType(ReservationDecisionDirectionEnum),
    );
    yield r'decision';
    yield serializers.serialize(
      object.decision,
      specifiedType: const FullType(ReservationDecisionDecisionEnum),
    );
    if (object.tripId != null) {
      yield r'tripId';
      yield serializers.serialize(
        object.tripId,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ReservationDecision object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ReservationDecisionBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'travelDate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Date),
          ) as Date;
          result.travelDate = valueDes;
          break;
        case r'direction':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ReservationDecisionDirectionEnum),
          ) as ReservationDecisionDirectionEnum;
          result.direction = valueDes;
          break;
        case r'decision':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ReservationDecisionDecisionEnum),
          ) as ReservationDecisionDecisionEnum;
          result.decision = valueDes;
          break;
        case r'tripId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.tripId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ReservationDecision deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReservationDecisionBuilder();
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

class ReservationDecisionDirectionEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'outbound')
  static const ReservationDecisionDirectionEnum outbound = _$reservationDecisionDirectionEnum_outbound;
  @BuiltValueEnumConst(wireName: r'return')
  static const ReservationDecisionDirectionEnum return_ = _$reservationDecisionDirectionEnum_return_;

  static Serializer<ReservationDecisionDirectionEnum> get serializer => _$reservationDecisionDirectionEnumSerializer;

  const ReservationDecisionDirectionEnum._(String name): super(name);

  static BuiltSet<ReservationDecisionDirectionEnum> get values => _$reservationDecisionDirectionEnumValues;
  static ReservationDecisionDirectionEnum valueOf(String name) => _$reservationDecisionDirectionEnumValueOf(name);
}

class ReservationDecisionDecisionEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'confirm')
  static const ReservationDecisionDecisionEnum confirm = _$reservationDecisionDecisionEnum_confirm;
  @BuiltValueEnumConst(wireName: r'decline')
  static const ReservationDecisionDecisionEnum decline = _$reservationDecisionDecisionEnum_decline;

  static Serializer<ReservationDecisionDecisionEnum> get serializer => _$reservationDecisionDecisionEnumSerializer;

  const ReservationDecisionDecisionEnum._(String name): super(name);

  static BuiltSet<ReservationDecisionDecisionEnum> get values => _$reservationDecisionDecisionEnumValues;
  static ReservationDecisionDecisionEnum valueOf(String name) => _$reservationDecisionDecisionEnumValueOf(name);
}

