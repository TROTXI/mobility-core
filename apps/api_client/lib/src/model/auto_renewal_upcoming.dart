//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/money.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auto_renewal_upcoming.g.dart';

/// AutoRenewalUpcoming
///
/// Properties:
/// * [state]
/// * [periodEndsAt]
/// * [chargeFrom]
/// * [nextAttemptAt]
/// * [price]
/// * [failureCode]
@BuiltValue()
abstract class AutoRenewalUpcoming
    implements Built<AutoRenewalUpcoming, AutoRenewalUpcomingBuilder> {
  @BuiltValueField(wireName: r'state')
  AutoRenewalUpcomingStateEnum get state;
  // enum stateEnum {  scheduled,  reminded,  charging,  failed,  needs_offer,  };

  @BuiltValueField(wireName: r'periodEndsAt')
  DateTime get periodEndsAt;

  @BuiltValueField(wireName: r'chargeFrom')
  DateTime get chargeFrom;

  @BuiltValueField(wireName: r'nextAttemptAt')
  DateTime? get nextAttemptAt;

  @BuiltValueField(wireName: r'price')
  Money get price;

  @BuiltValueField(wireName: r'failureCode')
  AutoRenewalUpcomingFailureCodeEnum? get failureCode;
  // enum failureCodeEnum {  card_declined,  charge_unconfirmed,  fare_changed,  service_changed,  no_card,  coverage_conflict,  renewal_blocked,  };

  AutoRenewalUpcoming._();

  factory AutoRenewalUpcoming([void updates(AutoRenewalUpcomingBuilder b)]) =
      _$AutoRenewalUpcoming;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AutoRenewalUpcomingBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AutoRenewalUpcoming> get serializer =>
      _$AutoRenewalUpcomingSerializer();
}

class _$AutoRenewalUpcomingSerializer
    implements PrimitiveSerializer<AutoRenewalUpcoming> {
  @override
  final Iterable<Type> types = const [
    AutoRenewalUpcoming,
    _$AutoRenewalUpcoming
  ];

  @override
  final String wireName = r'AutoRenewalUpcoming';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AutoRenewalUpcoming object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'state';
    yield serializers.serialize(
      object.state,
      specifiedType: const FullType(AutoRenewalUpcomingStateEnum),
    );
    yield r'periodEndsAt';
    yield serializers.serialize(
      object.periodEndsAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'chargeFrom';
    yield serializers.serialize(
      object.chargeFrom,
      specifiedType: const FullType(DateTime),
    );
    yield r'nextAttemptAt';
    yield object.nextAttemptAt == null
        ? null
        : serializers.serialize(
            object.nextAttemptAt,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'price';
    yield serializers.serialize(
      object.price,
      specifiedType: const FullType(Money),
    );
    yield r'failureCode';
    yield object.failureCode == null
        ? null
        : serializers.serialize(
            object.failureCode,
            specifiedType:
                const FullType.nullable(AutoRenewalUpcomingFailureCodeEnum),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    AutoRenewalUpcoming object, {
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
    required AutoRenewalUpcomingBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'state':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AutoRenewalUpcomingStateEnum),
          ) as AutoRenewalUpcomingStateEnum;
          result.state = valueDes;
          break;
        case r'periodEndsAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.periodEndsAt = valueDes;
          break;
        case r'chargeFrom':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.chargeFrom = valueDes;
          break;
        case r'nextAttemptAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.nextAttemptAt = valueDes;
          break;
        case r'price':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Money),
          ) as Money;
          result.price.replace(valueDes);
          break;
        case r'failureCode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType.nullable(AutoRenewalUpcomingFailureCodeEnum),
          ) as AutoRenewalUpcomingFailureCodeEnum?;
          if (valueDes == null) continue;
          result.failureCode = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AutoRenewalUpcoming deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AutoRenewalUpcomingBuilder();
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

class AutoRenewalUpcomingStateEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'scheduled')
  static const AutoRenewalUpcomingStateEnum scheduled =
      _$autoRenewalUpcomingStateEnum_scheduled;
  @BuiltValueEnumConst(wireName: r'reminded')
  static const AutoRenewalUpcomingStateEnum reminded =
      _$autoRenewalUpcomingStateEnum_reminded;
  @BuiltValueEnumConst(wireName: r'charging')
  static const AutoRenewalUpcomingStateEnum charging =
      _$autoRenewalUpcomingStateEnum_charging;
  @BuiltValueEnumConst(wireName: r'failed')
  static const AutoRenewalUpcomingStateEnum failed =
      _$autoRenewalUpcomingStateEnum_failed;
  @BuiltValueEnumConst(wireName: r'needs_offer')
  static const AutoRenewalUpcomingStateEnum needsOffer =
      _$autoRenewalUpcomingStateEnum_needsOffer;

  static Serializer<AutoRenewalUpcomingStateEnum> get serializer =>
      _$autoRenewalUpcomingStateEnumSerializer;

  const AutoRenewalUpcomingStateEnum._(String name) : super(name);

  static BuiltSet<AutoRenewalUpcomingStateEnum> get values =>
      _$autoRenewalUpcomingStateEnumValues;
  static AutoRenewalUpcomingStateEnum valueOf(String name) =>
      _$autoRenewalUpcomingStateEnumValueOf(name);
}

class AutoRenewalUpcomingFailureCodeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'card_declined')
  static const AutoRenewalUpcomingFailureCodeEnum cardDeclined =
      _$autoRenewalUpcomingFailureCodeEnum_cardDeclined;
  @BuiltValueEnumConst(wireName: r'charge_unconfirmed')
  static const AutoRenewalUpcomingFailureCodeEnum chargeUnconfirmed =
      _$autoRenewalUpcomingFailureCodeEnum_chargeUnconfirmed;
  @BuiltValueEnumConst(wireName: r'fare_changed')
  static const AutoRenewalUpcomingFailureCodeEnum fareChanged =
      _$autoRenewalUpcomingFailureCodeEnum_fareChanged;
  @BuiltValueEnumConst(wireName: r'service_changed')
  static const AutoRenewalUpcomingFailureCodeEnum serviceChanged =
      _$autoRenewalUpcomingFailureCodeEnum_serviceChanged;
  @BuiltValueEnumConst(wireName: r'no_card')
  static const AutoRenewalUpcomingFailureCodeEnum noCard =
      _$autoRenewalUpcomingFailureCodeEnum_noCard;
  @BuiltValueEnumConst(wireName: r'coverage_conflict')
  static const AutoRenewalUpcomingFailureCodeEnum coverageConflict =
      _$autoRenewalUpcomingFailureCodeEnum_coverageConflict;
  @BuiltValueEnumConst(wireName: r'renewal_blocked')
  static const AutoRenewalUpcomingFailureCodeEnum renewalBlocked =
      _$autoRenewalUpcomingFailureCodeEnum_renewalBlocked;

  static Serializer<AutoRenewalUpcomingFailureCodeEnum> get serializer =>
      _$autoRenewalUpcomingFailureCodeEnumSerializer;

  const AutoRenewalUpcomingFailureCodeEnum._(String name) : super(name);

  static BuiltSet<AutoRenewalUpcomingFailureCodeEnum> get values =>
      _$autoRenewalUpcomingFailureCodeEnumValues;
  static AutoRenewalUpcomingFailureCodeEnum valueOf(String name) =>
      _$autoRenewalUpcomingFailureCodeEnumValueOf(name);
}
