//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client_next/src/model/money.dart';
import 'package:trotxi_api_client_next/src/model/ops_purchase_checkout.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'purchase.g.dart';

/// Purchase
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
@BuiltValue()
abstract class Purchase implements Built<Purchase, PurchaseBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'plan')
  PurchasePlanEnum get plan;
  // enum planEnum {  monthly,  annual,  };

  @BuiltValueField(wireName: r'state')
  PurchaseStateEnum get state;
  // enum stateEnum {  awaiting_payment,  processing,  fulfilled,  failed,  cancelled,  review_required,  };

  @BuiltValueField(wireName: r'collectionState')
  PurchaseCollectionStateEnum get collectionState;
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

  Purchase._();

  factory Purchase([void updates(PurchaseBuilder b)]) = _$Purchase;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PurchaseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Purchase> get serializer => _$PurchaseSerializer();
}

class _$PurchaseSerializer implements PrimitiveSerializer<Purchase> {
  @override
  final Iterable<Type> types = const [Purchase, _$Purchase];

  @override
  final String wireName = r'Purchase';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Purchase object, {
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
      specifiedType: const FullType(PurchasePlanEnum),
    );
    yield r'state';
    yield serializers.serialize(
      object.state,
      specifiedType: const FullType(PurchaseStateEnum),
    );
    yield r'collectionState';
    yield serializers.serialize(
      object.collectionState,
      specifiedType: const FullType(PurchaseCollectionStateEnum),
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
  }

  @override
  Object serialize(
    Serializers serializers,
    Purchase object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PurchaseBuilder result,
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
            specifiedType: const FullType(PurchasePlanEnum),
          ) as PurchasePlanEnum;
          result.plan = valueDes;
          break;
        case r'state':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PurchaseStateEnum),
          ) as PurchaseStateEnum;
          result.state = valueDes;
          break;
        case r'collectionState':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PurchaseCollectionStateEnum),
          ) as PurchaseCollectionStateEnum;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Purchase deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PurchaseBuilder();
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

class PurchasePlanEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'monthly')
  static const PurchasePlanEnum monthly = _$purchasePlanEnum_monthly;
  @BuiltValueEnumConst(wireName: r'annual')
  static const PurchasePlanEnum annual = _$purchasePlanEnum_annual;

  static Serializer<PurchasePlanEnum> get serializer => _$purchasePlanEnumSerializer;

  const PurchasePlanEnum._(String name): super(name);

  static BuiltSet<PurchasePlanEnum> get values => _$purchasePlanEnumValues;
  static PurchasePlanEnum valueOf(String name) => _$purchasePlanEnumValueOf(name);
}

class PurchaseStateEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'awaiting_payment')
  static const PurchaseStateEnum awaitingPayment = _$purchaseStateEnum_awaitingPayment;
  @BuiltValueEnumConst(wireName: r'processing')
  static const PurchaseStateEnum processing = _$purchaseStateEnum_processing;
  @BuiltValueEnumConst(wireName: r'fulfilled')
  static const PurchaseStateEnum fulfilled = _$purchaseStateEnum_fulfilled;
  @BuiltValueEnumConst(wireName: r'failed')
  static const PurchaseStateEnum failed = _$purchaseStateEnum_failed;
  @BuiltValueEnumConst(wireName: r'cancelled')
  static const PurchaseStateEnum cancelled = _$purchaseStateEnum_cancelled;
  @BuiltValueEnumConst(wireName: r'review_required')
  static const PurchaseStateEnum reviewRequired = _$purchaseStateEnum_reviewRequired;

  static Serializer<PurchaseStateEnum> get serializer => _$purchaseStateEnumSerializer;

  const PurchaseStateEnum._(String name): super(name);

  static BuiltSet<PurchaseStateEnum> get values => _$purchaseStateEnumValues;
  static PurchaseStateEnum valueOf(String name) => _$purchaseStateEnumValueOf(name);
}

class PurchaseCollectionStateEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'pending')
  static const PurchaseCollectionStateEnum pending = _$purchaseCollectionStateEnum_pending;
  @BuiltValueEnumConst(wireName: r'successful')
  static const PurchaseCollectionStateEnum successful = _$purchaseCollectionStateEnum_successful;
  @BuiltValueEnumConst(wireName: r'failed')
  static const PurchaseCollectionStateEnum failed = _$purchaseCollectionStateEnum_failed;
  @BuiltValueEnumConst(wireName: r'unknown')
  static const PurchaseCollectionStateEnum unknown = _$purchaseCollectionStateEnum_unknown;

  static Serializer<PurchaseCollectionStateEnum> get serializer => _$purchaseCollectionStateEnumSerializer;

  const PurchaseCollectionStateEnum._(String name): super(name);

  static BuiltSet<PurchaseCollectionStateEnum> get values => _$purchaseCollectionStateEnumValues;
  static PurchaseCollectionStateEnum valueOf(String name) => _$purchaseCollectionStateEnumValueOf(name);
}

