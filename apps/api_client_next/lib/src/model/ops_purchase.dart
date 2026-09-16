//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client_next/src/model/ops_purchase_attempts_inner.dart';
import 'package:trotxi_api_client_next/src/model/money.dart';
import 'package:trotxi_api_client_next/src/model/ops_purchase_checkout.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ops_purchase.g.dart';

/// OpsPurchase
///
/// Properties:
/// * [id] 
/// * [plan] 
/// * [state] 
/// * [collectionState] 
/// * [price] 
/// * [appliedCredit] 
/// * [cashDue] 
/// * [checkout] 
/// * [billingPeriodId] 
/// * [failureCode] 
/// * [createdAt] 
/// * [riderId] 
/// * [attempts] 
@BuiltValue()
abstract class OpsPurchase implements Built<OpsPurchase, OpsPurchaseBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'plan')
  OpsPurchasePlanEnum get plan;
  // enum planEnum {  monthly,  annual,  };

  @BuiltValueField(wireName: r'state')
  OpsPurchaseStateEnum get state;
  // enum stateEnum {  awaiting_payment,  processing,  fulfilled,  failed,  cancelled,  review_required,  };

  @BuiltValueField(wireName: r'collectionState')
  OpsPurchaseCollectionStateEnum get collectionState;
  // enum collectionStateEnum {  pending,  successful,  failed,  unknown,  };

  @BuiltValueField(wireName: r'price')
  Money get price;

  @BuiltValueField(wireName: r'appliedCredit')
  Money get appliedCredit;

  @BuiltValueField(wireName: r'cashDue')
  Money get cashDue;

  @BuiltValueField(wireName: r'checkout')
  OpsPurchaseCheckout? get checkout;

  @BuiltValueField(wireName: r'billingPeriodId')
  String? get billingPeriodId;

  @BuiltValueField(wireName: r'failureCode')
  String? get failureCode;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'riderId')
  String get riderId;

  @BuiltValueField(wireName: r'attempts')
  BuiltList<OpsPurchaseAttemptsInner> get attempts;

  OpsPurchase._();

  factory OpsPurchase([void updates(OpsPurchaseBuilder b)]) = _$OpsPurchase;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OpsPurchaseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OpsPurchase> get serializer => _$OpsPurchaseSerializer();
}

class _$OpsPurchaseSerializer implements PrimitiveSerializer<OpsPurchase> {
  @override
  final Iterable<Type> types = const [OpsPurchase, _$OpsPurchase];

  @override
  final String wireName = r'OpsPurchase';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OpsPurchase object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'plan';
    yield serializers.serialize(
      object.plan,
      specifiedType: const FullType(OpsPurchasePlanEnum),
    );
    yield r'state';
    yield serializers.serialize(
      object.state,
      specifiedType: const FullType(OpsPurchaseStateEnum),
    );
    yield r'collectionState';
    yield serializers.serialize(
      object.collectionState,
      specifiedType: const FullType(OpsPurchaseCollectionStateEnum),
    );
    yield r'price';
    yield serializers.serialize(
      object.price,
      specifiedType: const FullType(Money),
    );
    yield r'appliedCredit';
    yield serializers.serialize(
      object.appliedCredit,
      specifiedType: const FullType(Money),
    );
    yield r'cashDue';
    yield serializers.serialize(
      object.cashDue,
      specifiedType: const FullType(Money),
    );
    yield r'checkout';
    yield object.checkout == null ? null : serializers.serialize(
      object.checkout,
      specifiedType: const FullType.nullable(OpsPurchaseCheckout),
    );
    yield r'billingPeriodId';
    yield object.billingPeriodId == null ? null : serializers.serialize(
      object.billingPeriodId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'failureCode';
    yield object.failureCode == null ? null : serializers.serialize(
      object.failureCode,
      specifiedType: const FullType.nullable(String),
    );
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'riderId';
    yield serializers.serialize(
      object.riderId,
      specifiedType: const FullType(String),
    );
    yield r'attempts';
    yield serializers.serialize(
      object.attempts,
      specifiedType: const FullType(BuiltList, [FullType(OpsPurchaseAttemptsInner)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OpsPurchase object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OpsPurchaseBuilder result,
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
        case r'plan':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OpsPurchasePlanEnum),
          ) as OpsPurchasePlanEnum;
          result.plan = valueDes;
          break;
        case r'state':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OpsPurchaseStateEnum),
          ) as OpsPurchaseStateEnum;
          result.state = valueDes;
          break;
        case r'collectionState':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OpsPurchaseCollectionStateEnum),
          ) as OpsPurchaseCollectionStateEnum;
          result.collectionState = valueDes;
          break;
        case r'price':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Money),
          ) as Money;
          result.price.replace(valueDes);
          break;
        case r'appliedCredit':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Money),
          ) as Money;
          result.appliedCredit.replace(valueDes);
          break;
        case r'cashDue':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Money),
          ) as Money;
          result.cashDue.replace(valueDes);
          break;
        case r'checkout':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(OpsPurchaseCheckout),
          ) as OpsPurchaseCheckout?;
          if (valueDes == null) continue;
          result.checkout.replace(valueDes);
          break;
        case r'billingPeriodId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.billingPeriodId = valueDes;
          break;
        case r'failureCode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.failureCode = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'riderId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.riderId = valueDes;
          break;
        case r'attempts':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(OpsPurchaseAttemptsInner)]),
          ) as BuiltList<OpsPurchaseAttemptsInner>;
          result.attempts.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OpsPurchase deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OpsPurchaseBuilder();
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

class OpsPurchasePlanEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'monthly')
  static const OpsPurchasePlanEnum monthly = _$opsPurchasePlanEnum_monthly;
  @BuiltValueEnumConst(wireName: r'annual')
  static const OpsPurchasePlanEnum annual = _$opsPurchasePlanEnum_annual;

  static Serializer<OpsPurchasePlanEnum> get serializer => _$opsPurchasePlanEnumSerializer;

  const OpsPurchasePlanEnum._(String name): super(name);

  static BuiltSet<OpsPurchasePlanEnum> get values => _$opsPurchasePlanEnumValues;
  static OpsPurchasePlanEnum valueOf(String name) => _$opsPurchasePlanEnumValueOf(name);
}

class OpsPurchaseStateEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'awaiting_payment')
  static const OpsPurchaseStateEnum awaitingPayment = _$opsPurchaseStateEnum_awaitingPayment;
  @BuiltValueEnumConst(wireName: r'processing')
  static const OpsPurchaseStateEnum processing = _$opsPurchaseStateEnum_processing;
  @BuiltValueEnumConst(wireName: r'fulfilled')
  static const OpsPurchaseStateEnum fulfilled = _$opsPurchaseStateEnum_fulfilled;
  @BuiltValueEnumConst(wireName: r'failed')
  static const OpsPurchaseStateEnum failed = _$opsPurchaseStateEnum_failed;
  @BuiltValueEnumConst(wireName: r'cancelled')
  static const OpsPurchaseStateEnum cancelled = _$opsPurchaseStateEnum_cancelled;
  @BuiltValueEnumConst(wireName: r'review_required')
  static const OpsPurchaseStateEnum reviewRequired = _$opsPurchaseStateEnum_reviewRequired;

  static Serializer<OpsPurchaseStateEnum> get serializer => _$opsPurchaseStateEnumSerializer;

  const OpsPurchaseStateEnum._(String name): super(name);

  static BuiltSet<OpsPurchaseStateEnum> get values => _$opsPurchaseStateEnumValues;
  static OpsPurchaseStateEnum valueOf(String name) => _$opsPurchaseStateEnumValueOf(name);
}

class OpsPurchaseCollectionStateEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'pending')
  static const OpsPurchaseCollectionStateEnum pending = _$opsPurchaseCollectionStateEnum_pending;
  @BuiltValueEnumConst(wireName: r'successful')
  static const OpsPurchaseCollectionStateEnum successful = _$opsPurchaseCollectionStateEnum_successful;
  @BuiltValueEnumConst(wireName: r'failed')
  static const OpsPurchaseCollectionStateEnum failed = _$opsPurchaseCollectionStateEnum_failed;
  @BuiltValueEnumConst(wireName: r'unknown')
  static const OpsPurchaseCollectionStateEnum unknown = _$opsPurchaseCollectionStateEnum_unknown;

  static Serializer<OpsPurchaseCollectionStateEnum> get serializer => _$opsPurchaseCollectionStateEnumSerializer;

  const OpsPurchaseCollectionStateEnum._(String name): super(name);

  static BuiltSet<OpsPurchaseCollectionStateEnum> get values => _$opsPurchaseCollectionStateEnumValues;
  static OpsPurchaseCollectionStateEnum valueOf(String name) => _$opsPurchaseCollectionStateEnumValueOf(name);
}

