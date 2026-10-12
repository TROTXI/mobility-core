//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/money.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ops_purchase_row.g.dart';

/// OpsPurchaseRow
///
/// Properties:
/// * [id]
/// * [plan]
/// * [state]
/// * [collectionState]
/// * [price]
/// * [appliedCredit]
/// * [cashDue]
/// * [failureCode]
/// * [createdAt]
/// * [riderId]
/// * [riderName]
@BuiltValue()
abstract class OpsPurchaseRow
    implements Built<OpsPurchaseRow, OpsPurchaseRowBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'plan')
  OpsPurchaseRowPlanEnum get plan;
  // enum planEnum {  weekly,  biweekly,  monthly,  annual,  };

  @BuiltValueField(wireName: r'state')
  OpsPurchaseRowStateEnum get state;
  // enum stateEnum {  awaiting_payment,  processing,  fulfilled,  failed,  cancelled,  review_required,  };

  @BuiltValueField(wireName: r'collectionState')
  OpsPurchaseRowCollectionStateEnum get collectionState;
  // enum collectionStateEnum {  pending,  successful,  failed,  unknown,  };

  @BuiltValueField(wireName: r'price')
  Money get price;

  @BuiltValueField(wireName: r'appliedCredit')
  Money get appliedCredit;

  @BuiltValueField(wireName: r'cashDue')
  Money get cashDue;

  @BuiltValueField(wireName: r'failureCode')
  String? get failureCode;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'riderId')
  String get riderId;

  @BuiltValueField(wireName: r'riderName')
  String? get riderName;

  OpsPurchaseRow._();

  factory OpsPurchaseRow([void updates(OpsPurchaseRowBuilder b)]) =
      _$OpsPurchaseRow;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OpsPurchaseRowBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OpsPurchaseRow> get serializer =>
      _$OpsPurchaseRowSerializer();
}

class _$OpsPurchaseRowSerializer
    implements PrimitiveSerializer<OpsPurchaseRow> {
  @override
  final Iterable<Type> types = const [OpsPurchaseRow, _$OpsPurchaseRow];

  @override
  final String wireName = r'OpsPurchaseRow';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OpsPurchaseRow object, {
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
      specifiedType: const FullType(OpsPurchaseRowPlanEnum),
    );
    yield r'state';
    yield serializers.serialize(
      object.state,
      specifiedType: const FullType(OpsPurchaseRowStateEnum),
    );
    yield r'collectionState';
    yield serializers.serialize(
      object.collectionState,
      specifiedType: const FullType(OpsPurchaseRowCollectionStateEnum),
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
    yield r'failureCode';
    yield object.failureCode == null
        ? null
        : serializers.serialize(
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
    yield r'riderName';
    yield object.riderName == null
        ? null
        : serializers.serialize(
            object.riderName,
            specifiedType: const FullType.nullable(String),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    OpsPurchaseRow object, {
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
    required OpsPurchaseRowBuilder result,
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
            specifiedType: const FullType(OpsPurchaseRowPlanEnum),
          ) as OpsPurchaseRowPlanEnum;
          result.plan = valueDes;
          break;
        case r'state':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OpsPurchaseRowStateEnum),
          ) as OpsPurchaseRowStateEnum;
          result.state = valueDes;
          break;
        case r'collectionState':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OpsPurchaseRowCollectionStateEnum),
          ) as OpsPurchaseRowCollectionStateEnum;
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
        case r'riderName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.riderName = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OpsPurchaseRow deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OpsPurchaseRowBuilder();
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

class OpsPurchaseRowPlanEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'weekly')
  static const OpsPurchaseRowPlanEnum weekly = _$opsPurchaseRowPlanEnum_weekly;
  @BuiltValueEnumConst(wireName: r'biweekly')
  static const OpsPurchaseRowPlanEnum biweekly =
      _$opsPurchaseRowPlanEnum_biweekly;
  @BuiltValueEnumConst(wireName: r'monthly')
  static const OpsPurchaseRowPlanEnum monthly =
      _$opsPurchaseRowPlanEnum_monthly;
  @BuiltValueEnumConst(wireName: r'annual')
  static const OpsPurchaseRowPlanEnum annual = _$opsPurchaseRowPlanEnum_annual;

  static Serializer<OpsPurchaseRowPlanEnum> get serializer =>
      _$opsPurchaseRowPlanEnumSerializer;

  const OpsPurchaseRowPlanEnum._(String name) : super(name);

  static BuiltSet<OpsPurchaseRowPlanEnum> get values =>
      _$opsPurchaseRowPlanEnumValues;
  static OpsPurchaseRowPlanEnum valueOf(String name) =>
      _$opsPurchaseRowPlanEnumValueOf(name);
}

class OpsPurchaseRowStateEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'awaiting_payment')
  static const OpsPurchaseRowStateEnum awaitingPayment =
      _$opsPurchaseRowStateEnum_awaitingPayment;
  @BuiltValueEnumConst(wireName: r'processing')
  static const OpsPurchaseRowStateEnum processing =
      _$opsPurchaseRowStateEnum_processing;
  @BuiltValueEnumConst(wireName: r'fulfilled')
  static const OpsPurchaseRowStateEnum fulfilled =
      _$opsPurchaseRowStateEnum_fulfilled;
  @BuiltValueEnumConst(wireName: r'failed')
  static const OpsPurchaseRowStateEnum failed =
      _$opsPurchaseRowStateEnum_failed;
  @BuiltValueEnumConst(wireName: r'cancelled')
  static const OpsPurchaseRowStateEnum cancelled =
      _$opsPurchaseRowStateEnum_cancelled;
  @BuiltValueEnumConst(wireName: r'review_required')
  static const OpsPurchaseRowStateEnum reviewRequired =
      _$opsPurchaseRowStateEnum_reviewRequired;

  static Serializer<OpsPurchaseRowStateEnum> get serializer =>
      _$opsPurchaseRowStateEnumSerializer;

  const OpsPurchaseRowStateEnum._(String name) : super(name);

  static BuiltSet<OpsPurchaseRowStateEnum> get values =>
      _$opsPurchaseRowStateEnumValues;
  static OpsPurchaseRowStateEnum valueOf(String name) =>
      _$opsPurchaseRowStateEnumValueOf(name);
}

class OpsPurchaseRowCollectionStateEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'pending')
  static const OpsPurchaseRowCollectionStateEnum pending =
      _$opsPurchaseRowCollectionStateEnum_pending;
  @BuiltValueEnumConst(wireName: r'successful')
  static const OpsPurchaseRowCollectionStateEnum successful =
      _$opsPurchaseRowCollectionStateEnum_successful;
  @BuiltValueEnumConst(wireName: r'failed')
  static const OpsPurchaseRowCollectionStateEnum failed =
      _$opsPurchaseRowCollectionStateEnum_failed;
  @BuiltValueEnumConst(wireName: r'unknown')
  static const OpsPurchaseRowCollectionStateEnum unknown =
      _$opsPurchaseRowCollectionStateEnum_unknown;

  static Serializer<OpsPurchaseRowCollectionStateEnum> get serializer =>
      _$opsPurchaseRowCollectionStateEnumSerializer;

  const OpsPurchaseRowCollectionStateEnum._(String name) : super(name);

  static BuiltSet<OpsPurchaseRowCollectionStateEnum> get values =>
      _$opsPurchaseRowCollectionStateEnumValues;
  static OpsPurchaseRowCollectionStateEnum valueOf(String name) =>
      _$opsPurchaseRowCollectionStateEnumValueOf(name);
}
