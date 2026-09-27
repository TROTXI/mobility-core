//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/commute_leg.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'purchase_input.g.dart';

/// PurchaseInput
///
/// Properties:
/// * [plan] 
/// * [routeId] 
/// * [legs] 
/// * [useCredit] 
@BuiltValue()
abstract class PurchaseInput implements Built<PurchaseInput, PurchaseInputBuilder> {
  @BuiltValueField(wireName: r'plan')
  PurchaseInputPlanEnum get plan;
  // enum planEnum {  monthly,  annual,  };

  @BuiltValueField(wireName: r'routeId')
  String get routeId;

  @BuiltValueField(wireName: r'legs')
  BuiltList<CommuteLeg> get legs;

  @BuiltValueField(wireName: r'useCredit')
  bool get useCredit;

  PurchaseInput._();

  factory PurchaseInput([void updates(PurchaseInputBuilder b)]) = _$PurchaseInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PurchaseInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PurchaseInput> get serializer => _$PurchaseInputSerializer();
}

class _$PurchaseInputSerializer implements PrimitiveSerializer<PurchaseInput> {
  @override
  final Iterable<Type> types = const [PurchaseInput, _$PurchaseInput];

  @override
  final String wireName = r'PurchaseInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PurchaseInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'plan';
    yield serializers.serialize(
      object.plan,
      specifiedType: const FullType(PurchaseInputPlanEnum),
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
    PurchaseInput object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PurchaseInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'plan':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PurchaseInputPlanEnum),
          ) as PurchaseInputPlanEnum;
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
  PurchaseInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PurchaseInputBuilder();
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

class PurchaseInputPlanEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'monthly')
  static const PurchaseInputPlanEnum monthly = _$purchaseInputPlanEnum_monthly;
  @BuiltValueEnumConst(wireName: r'annual')
  static const PurchaseInputPlanEnum annual = _$purchaseInputPlanEnum_annual;

  static Serializer<PurchaseInputPlanEnum> get serializer => _$purchaseInputPlanEnumSerializer;

  const PurchaseInputPlanEnum._(String name): super(name);

  static BuiltSet<PurchaseInputPlanEnum> get values => _$purchaseInputPlanEnumValues;
  static PurchaseInputPlanEnum valueOf(String name) => _$purchaseInputPlanEnumValueOf(name);
}

