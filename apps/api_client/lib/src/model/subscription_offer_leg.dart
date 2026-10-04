//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/money.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'subscription_offer_leg.g.dart';

/// SubscriptionOfferLeg
///
/// Properties:
/// * [direction]
/// * [scheduleId]
/// * [patternVersionId]
/// * [pickupOccurrenceId]
/// * [dropoffOccurrenceId]
/// * [pickupName]
/// * [dropoffName]
/// * [fareId]
/// * [fare]
/// * [ridesGranted]
/// * [travelDays]
/// * [creditPerUnusedRide]
@BuiltValue()
abstract class SubscriptionOfferLeg
    implements Built<SubscriptionOfferLeg, SubscriptionOfferLegBuilder> {
  @BuiltValueField(wireName: r'direction')
  SubscriptionOfferLegDirectionEnum get direction;
  // enum directionEnum {  outbound,  return,  };

  @BuiltValueField(wireName: r'scheduleId')
  String get scheduleId;

  @BuiltValueField(wireName: r'patternVersionId')
  String get patternVersionId;

  @BuiltValueField(wireName: r'pickupOccurrenceId')
  String get pickupOccurrenceId;

  @BuiltValueField(wireName: r'dropoffOccurrenceId')
  String get dropoffOccurrenceId;

  @BuiltValueField(wireName: r'pickupName')
  String get pickupName;

  @BuiltValueField(wireName: r'dropoffName')
  String get dropoffName;

  @BuiltValueField(wireName: r'fareId')
  String get fareId;

  @BuiltValueField(wireName: r'fare')
  Money get fare;

  @BuiltValueField(wireName: r'ridesGranted')
  int get ridesGranted;

  @BuiltValueField(wireName: r'travelDays')
  BuiltList<int> get travelDays;

  @BuiltValueField(wireName: r'creditPerUnusedRide')
  Money get creditPerUnusedRide;

  SubscriptionOfferLeg._();

  factory SubscriptionOfferLeg([void updates(SubscriptionOfferLegBuilder b)]) =
      _$SubscriptionOfferLeg;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SubscriptionOfferLegBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SubscriptionOfferLeg> get serializer =>
      _$SubscriptionOfferLegSerializer();
}

class _$SubscriptionOfferLegSerializer
    implements PrimitiveSerializer<SubscriptionOfferLeg> {
  @override
  final Iterable<Type> types = const [
    SubscriptionOfferLeg,
    _$SubscriptionOfferLeg
  ];

  @override
  final String wireName = r'SubscriptionOfferLeg';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SubscriptionOfferLeg object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'direction';
    yield serializers.serialize(
      object.direction,
      specifiedType: const FullType(SubscriptionOfferLegDirectionEnum),
    );
    yield r'scheduleId';
    yield serializers.serialize(
      object.scheduleId,
      specifiedType: const FullType(String),
    );
    yield r'patternVersionId';
    yield serializers.serialize(
      object.patternVersionId,
      specifiedType: const FullType(String),
    );
    yield r'pickupOccurrenceId';
    yield serializers.serialize(
      object.pickupOccurrenceId,
      specifiedType: const FullType(String),
    );
    yield r'dropoffOccurrenceId';
    yield serializers.serialize(
      object.dropoffOccurrenceId,
      specifiedType: const FullType(String),
    );
    yield r'pickupName';
    yield serializers.serialize(
      object.pickupName,
      specifiedType: const FullType(String),
    );
    yield r'dropoffName';
    yield serializers.serialize(
      object.dropoffName,
      specifiedType: const FullType(String),
    );
    yield r'fareId';
    yield serializers.serialize(
      object.fareId,
      specifiedType: const FullType(String),
    );
    yield r'fare';
    yield serializers.serialize(
      object.fare,
      specifiedType: const FullType(Money),
    );
    yield r'ridesGranted';
    yield serializers.serialize(
      object.ridesGranted,
      specifiedType: const FullType(int),
    );
    yield r'travelDays';
    yield serializers.serialize(
      object.travelDays,
      specifiedType: const FullType(BuiltList, [FullType(int)]),
    );
    yield r'creditPerUnusedRide';
    yield serializers.serialize(
      object.creditPerUnusedRide,
      specifiedType: const FullType(Money),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SubscriptionOfferLeg object, {
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
    required SubscriptionOfferLegBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'direction':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SubscriptionOfferLegDirectionEnum),
          ) as SubscriptionOfferLegDirectionEnum;
          result.direction = valueDes;
          break;
        case r'scheduleId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.scheduleId = valueDes;
          break;
        case r'patternVersionId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.patternVersionId = valueDes;
          break;
        case r'pickupOccurrenceId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.pickupOccurrenceId = valueDes;
          break;
        case r'dropoffOccurrenceId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.dropoffOccurrenceId = valueDes;
          break;
        case r'pickupName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.pickupName = valueDes;
          break;
        case r'dropoffName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.dropoffName = valueDes;
          break;
        case r'fareId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.fareId = valueDes;
          break;
        case r'fare':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Money),
          ) as Money;
          result.fare.replace(valueDes);
          break;
        case r'ridesGranted':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.ridesGranted = valueDes;
          break;
        case r'travelDays':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(int)]),
          ) as BuiltList<int>;
          result.travelDays.replace(valueDes);
          break;
        case r'creditPerUnusedRide':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Money),
          ) as Money;
          result.creditPerUnusedRide.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SubscriptionOfferLeg deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SubscriptionOfferLegBuilder();
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

class SubscriptionOfferLegDirectionEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'outbound')
  static const SubscriptionOfferLegDirectionEnum outbound =
      _$subscriptionOfferLegDirectionEnum_outbound;
  @BuiltValueEnumConst(wireName: r'return')
  static const SubscriptionOfferLegDirectionEnum return_ =
      _$subscriptionOfferLegDirectionEnum_return_;

  static Serializer<SubscriptionOfferLegDirectionEnum> get serializer =>
      _$subscriptionOfferLegDirectionEnumSerializer;

  const SubscriptionOfferLegDirectionEnum._(String name) : super(name);

  static BuiltSet<SubscriptionOfferLegDirectionEnum> get values =>
      _$subscriptionOfferLegDirectionEnumValues;
  static SubscriptionOfferLegDirectionEnum valueOf(String name) =>
      _$subscriptionOfferLegDirectionEnumValueOf(name);
}
