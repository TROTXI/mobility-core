//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/commute_leg.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'purchase_selection.g.dart';

/// PurchaseSelection
///
/// Properties:
/// * [plan]
/// * [routeId]
/// * [legs]
/// * [useCredit]
@BuiltValue()
abstract class PurchaseSelection
    implements Built<PurchaseSelection, PurchaseSelectionBuilder> {
  @BuiltValueField(wireName: r'plan')
  PurchaseSelectionPlanEnum get plan;
  // enum planEnum {  weekly,  biweekly,  monthly,  annual,  };

  @BuiltValueField(wireName: r'routeId')
  String get routeId;

  @BuiltValueField(wireName: r'legs')
  BuiltList<CommuteLeg> get legs;

  @BuiltValueField(wireName: r'useCredit')
  bool get useCredit;

  PurchaseSelection._();

  factory PurchaseSelection([void updates(PurchaseSelectionBuilder b)]) =
      _$PurchaseSelection;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PurchaseSelectionBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PurchaseSelection> get serializer =>
      _$PurchaseSelectionSerializer();
}

class _$PurchaseSelectionSerializer
    implements PrimitiveSerializer<PurchaseSelection> {
  @override
  final Iterable<Type> types = const [PurchaseSelection, _$PurchaseSelection];

  @override
  final String wireName = r'PurchaseSelection';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PurchaseSelection object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'plan';
    yield serializers.serialize(
      object.plan,
      specifiedType: const FullType(PurchaseSelectionPlanEnum),
    );
    yield r'routeId';
    yield serializers.serialize(
      object.routeId,
      specifiedType: const FullType(String),
    );
    yield r'legs';
    yield serializers.serialize(
      object.legs,
      specifiedType: const FullType(BuiltList, [FullType(CommuteLeg)]),
    );
    yield r'useCredit';
    yield serializers.serialize(
      object.useCredit,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PurchaseSelection object, {
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
    required PurchaseSelectionBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'plan':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PurchaseSelectionPlanEnum),
          ) as PurchaseSelectionPlanEnum;
          result.plan = valueDes;
          break;
        case r'routeId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.routeId = valueDes;
          break;
        case r'legs':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(CommuteLeg)]),
          ) as BuiltList<CommuteLeg>;
          result.legs.replace(valueDes);
          break;
        case r'useCredit':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.useCredit = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PurchaseSelection deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PurchaseSelectionBuilder();
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

class PurchaseSelectionPlanEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'weekly')
  static const PurchaseSelectionPlanEnum weekly =
      _$purchaseSelectionPlanEnum_weekly;
  @BuiltValueEnumConst(wireName: r'biweekly')
  static const PurchaseSelectionPlanEnum biweekly =
      _$purchaseSelectionPlanEnum_biweekly;
  @BuiltValueEnumConst(wireName: r'monthly')
  static const PurchaseSelectionPlanEnum monthly =
      _$purchaseSelectionPlanEnum_monthly;
  @BuiltValueEnumConst(wireName: r'annual')
  static const PurchaseSelectionPlanEnum annual =
      _$purchaseSelectionPlanEnum_annual;

  static Serializer<PurchaseSelectionPlanEnum> get serializer =>
      _$purchaseSelectionPlanEnumSerializer;

  const PurchaseSelectionPlanEnum._(String name) : super(name);

  static BuiltSet<PurchaseSelectionPlanEnum> get values =>
      _$purchaseSelectionPlanEnumValues;
  static PurchaseSelectionPlanEnum valueOf(String name) =>
      _$purchaseSelectionPlanEnumValueOf(name);
}
