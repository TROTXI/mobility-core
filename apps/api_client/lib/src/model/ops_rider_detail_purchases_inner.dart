//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/money.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ops_rider_detail_purchases_inner.g.dart';

/// OpsRiderDetailPurchasesInner
///
/// Properties:
/// * [id] 
/// * [plan] 
/// * [state] 
/// * [cashDue] 
/// * [createdAt] 
@BuiltValue()
abstract class OpsRiderDetailPurchasesInner implements Built<OpsRiderDetailPurchasesInner, OpsRiderDetailPurchasesInnerBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'plan')
  OpsRiderDetailPurchasesInnerPlanEnum get plan;
  // enum planEnum {  monthly,  annual,  };

  @BuiltValueField(wireName: r'state')
  String get state;

  @BuiltValueField(wireName: r'cashDue')
  Money get cashDue;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  OpsRiderDetailPurchasesInner._();

  factory OpsRiderDetailPurchasesInner([void updates(OpsRiderDetailPurchasesInnerBuilder b)]) = _$OpsRiderDetailPurchasesInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OpsRiderDetailPurchasesInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OpsRiderDetailPurchasesInner> get serializer => _$OpsRiderDetailPurchasesInnerSerializer();
}

class _$OpsRiderDetailPurchasesInnerSerializer implements PrimitiveSerializer<OpsRiderDetailPurchasesInner> {
  @override
  final Iterable<Type> types = const [OpsRiderDetailPurchasesInner, _$OpsRiderDetailPurchasesInner];

  @override
  final String wireName = r'OpsRiderDetailPurchasesInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OpsRiderDetailPurchasesInner object, {
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
      specifiedType: const FullType(OpsRiderDetailPurchasesInnerPlanEnum),
    );
    yield r'state';
    yield serializers.serialize(
      object.state,
      specifiedType: const FullType(String),
    );
    yield r'cashDue';
    yield serializers.serialize(
      object.cashDue,
      specifiedType: const FullType(Money),
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
    OpsRiderDetailPurchasesInner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OpsRiderDetailPurchasesInnerBuilder result,
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
            specifiedType: const FullType(OpsRiderDetailPurchasesInnerPlanEnum),
          ) as OpsRiderDetailPurchasesInnerPlanEnum;
          result.plan = valueDes;
          break;
        case r'state':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.state = valueDes;
          break;
        case r'cashDue':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Money),
          ) as Money;
          result.cashDue.replace(valueDes);
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
  OpsRiderDetailPurchasesInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OpsRiderDetailPurchasesInnerBuilder();
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

class OpsRiderDetailPurchasesInnerPlanEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'monthly')
  static const OpsRiderDetailPurchasesInnerPlanEnum monthly = _$opsRiderDetailPurchasesInnerPlanEnum_monthly;
  @BuiltValueEnumConst(wireName: r'annual')
  static const OpsRiderDetailPurchasesInnerPlanEnum annual = _$opsRiderDetailPurchasesInnerPlanEnum_annual;

  static Serializer<OpsRiderDetailPurchasesInnerPlanEnum> get serializer => _$opsRiderDetailPurchasesInnerPlanEnumSerializer;

  const OpsRiderDetailPurchasesInnerPlanEnum._(String name): super(name);

  static BuiltSet<OpsRiderDetailPurchasesInnerPlanEnum> get values => _$opsRiderDetailPurchasesInnerPlanEnumValues;
  static OpsRiderDetailPurchasesInnerPlanEnum valueOf(String name) => _$opsRiderDetailPurchasesInnerPlanEnumValueOf(name);
}

