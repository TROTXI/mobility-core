//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/money.dart';
import 'package:trotxi_api_client/src/model/ops_auto_renewal_card.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ops_auto_renewal.g.dart';

/// OpsAutoRenewal
///
/// Properties:
/// * [id]
/// * [riderId]
/// * [riderName]
/// * [state]
/// * [failureCode]
/// * [attempts]
/// * [periodEndsAt]
/// * [nextAttemptAt]
/// * [price]
/// * [card]
/// * [renewalPurchaseId]
/// * [updatedAt]
@BuiltValue()
abstract class OpsAutoRenewal
    implements Built<OpsAutoRenewal, OpsAutoRenewalBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'riderId')
  String get riderId;

  @BuiltValueField(wireName: r'riderName')
  String? get riderName;

  @BuiltValueField(wireName: r'state')
  OpsAutoRenewalStateEnum get state;
  // enum stateEnum {  scheduled,  reminded,  charging,  paid,  failed,  needs_offer,  lapsed,  cancelled,  };

  @BuiltValueField(wireName: r'failureCode')
  String? get failureCode;

  @BuiltValueField(wireName: r'attempts')
  int get attempts;

  @BuiltValueField(wireName: r'periodEndsAt')
  DateTime get periodEndsAt;

  @BuiltValueField(wireName: r'nextAttemptAt')
  DateTime? get nextAttemptAt;

  @BuiltValueField(wireName: r'price')
  Money get price;

  @BuiltValueField(wireName: r'card')
  OpsAutoRenewalCard? get card;

  @BuiltValueField(wireName: r'renewalPurchaseId')
  String? get renewalPurchaseId;

  @BuiltValueField(wireName: r'updatedAt')
  DateTime get updatedAt;

  OpsAutoRenewal._();

  factory OpsAutoRenewal([void updates(OpsAutoRenewalBuilder b)]) =
      _$OpsAutoRenewal;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OpsAutoRenewalBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OpsAutoRenewal> get serializer =>
      _$OpsAutoRenewalSerializer();
}

class _$OpsAutoRenewalSerializer
    implements PrimitiveSerializer<OpsAutoRenewal> {
  @override
  final Iterable<Type> types = const [OpsAutoRenewal, _$OpsAutoRenewal];

  @override
  final String wireName = r'OpsAutoRenewal';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OpsAutoRenewal object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'riderId';
    yield serializers.serialize(
      object.riderId,
      specifiedType: const FullType(String),
    );
    yield r'riderName';
    yield object.riderName == null
        ? null
        : serializers.serialize(
            object.riderName,
            specifiedType: const FullType.nullable(String),
          );
    yield r'state';
    yield serializers.serialize(
      object.state,
      specifiedType: const FullType(OpsAutoRenewalStateEnum),
    );
    yield r'failureCode';
    yield object.failureCode == null
        ? null
        : serializers.serialize(
            object.failureCode,
            specifiedType: const FullType.nullable(String),
          );
    yield r'attempts';
    yield serializers.serialize(
      object.attempts,
      specifiedType: const FullType(int),
    );
    yield r'periodEndsAt';
    yield serializers.serialize(
      object.periodEndsAt,
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
    yield r'card';
    yield object.card == null
        ? null
        : serializers.serialize(
            object.card,
            specifiedType: const FullType.nullable(OpsAutoRenewalCard),
          );
    yield r'renewalPurchaseId';
    yield object.renewalPurchaseId == null
        ? null
        : serializers.serialize(
            object.renewalPurchaseId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'updatedAt';
    yield serializers.serialize(
      object.updatedAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OpsAutoRenewal object, {
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
    required OpsAutoRenewalBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'riderId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.riderId = valueDes;
          break;
        case r'riderName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.riderName = valueDes;
          break;
        case r'state':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OpsAutoRenewalStateEnum),
          ) as OpsAutoRenewalStateEnum;
          result.state = valueDes;
          break;
        case r'failureCode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.failureCode = valueDes;
          break;
        case r'attempts':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.attempts = valueDes;
          break;
        case r'periodEndsAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.periodEndsAt = valueDes;
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
        case r'card':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(OpsAutoRenewalCard),
          ) as OpsAutoRenewalCard?;
          if (valueDes == null) continue;
          result.card.replace(valueDes);
          break;
        case r'renewalPurchaseId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.renewalPurchaseId = valueDes;
          break;
        case r'updatedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.updatedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OpsAutoRenewal deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OpsAutoRenewalBuilder();
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

class OpsAutoRenewalStateEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'scheduled')
  static const OpsAutoRenewalStateEnum scheduled =
      _$opsAutoRenewalStateEnum_scheduled;
  @BuiltValueEnumConst(wireName: r'reminded')
  static const OpsAutoRenewalStateEnum reminded =
      _$opsAutoRenewalStateEnum_reminded;
  @BuiltValueEnumConst(wireName: r'charging')
  static const OpsAutoRenewalStateEnum charging =
      _$opsAutoRenewalStateEnum_charging;
  @BuiltValueEnumConst(wireName: r'paid')
  static const OpsAutoRenewalStateEnum paid = _$opsAutoRenewalStateEnum_paid;
  @BuiltValueEnumConst(wireName: r'failed')
  static const OpsAutoRenewalStateEnum failed =
      _$opsAutoRenewalStateEnum_failed;
  @BuiltValueEnumConst(wireName: r'needs_offer')
  static const OpsAutoRenewalStateEnum needsOffer =
      _$opsAutoRenewalStateEnum_needsOffer;
  @BuiltValueEnumConst(wireName: r'lapsed')
  static const OpsAutoRenewalStateEnum lapsed =
      _$opsAutoRenewalStateEnum_lapsed;
  @BuiltValueEnumConst(wireName: r'cancelled')
  static const OpsAutoRenewalStateEnum cancelled =
      _$opsAutoRenewalStateEnum_cancelled;

  static Serializer<OpsAutoRenewalStateEnum> get serializer =>
      _$opsAutoRenewalStateEnumSerializer;

  const OpsAutoRenewalStateEnum._(String name) : super(name);

  static BuiltSet<OpsAutoRenewalStateEnum> get values =>
      _$opsAutoRenewalStateEnumValues;
  static OpsAutoRenewalStateEnum valueOf(String name) =>
      _$opsAutoRenewalStateEnumValueOf(name);
}
