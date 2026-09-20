//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'purchase_quote_input.g.dart';

/// PurchaseQuoteInput
///
/// Properties:
/// * [plan] 
/// * [routeId] 
/// * [useCredit] 
@BuiltValue()
abstract class PurchaseQuoteInput implements Built<PurchaseQuoteInput, PurchaseQuoteInputBuilder> {
  @BuiltValueField(wireName: r'plan')
  PurchaseQuoteInputPlanEnum get plan;
  // enum planEnum {  monthly,  annual,  };

  @BuiltValueField(wireName: r'routeId')
  String get routeId;

  @BuiltValueField(wireName: r'useCredit')
  bool get useCredit;

  PurchaseQuoteInput._();

  factory PurchaseQuoteInput([void updates(PurchaseQuoteInputBuilder b)]) = _$PurchaseQuoteInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PurchaseQuoteInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PurchaseQuoteInput> get serializer => _$PurchaseQuoteInputSerializer();
}

class _$PurchaseQuoteInputSerializer implements PrimitiveSerializer<PurchaseQuoteInput> {
  @override
  final Iterable<Type> types = const [PurchaseQuoteInput, _$PurchaseQuoteInput];

  @override
  final String wireName = r'PurchaseQuoteInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PurchaseQuoteInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'plan';
    yield serializers.serialize(
      object.plan,
      specifiedType: const FullType(PurchaseQuoteInputPlanEnum),
    );
    yield r'routeId';
    yield serializers.serialize(
      object.routeId,
      specifiedType: const FullType(String),
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
    PurchaseQuoteInput object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PurchaseQuoteInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'plan':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PurchaseQuoteInputPlanEnum),
          ) as PurchaseQuoteInputPlanEnum;
          result.plan = valueDes;
          break;
        case r'routeId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.routeId = valueDes;
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
  PurchaseQuoteInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PurchaseQuoteInputBuilder();
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

class PurchaseQuoteInputPlanEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'monthly')
  static const PurchaseQuoteInputPlanEnum monthly = _$purchaseQuoteInputPlanEnum_monthly;
  @BuiltValueEnumConst(wireName: r'annual')
  static const PurchaseQuoteInputPlanEnum annual = _$purchaseQuoteInputPlanEnum_annual;

  static Serializer<PurchaseQuoteInputPlanEnum> get serializer => _$purchaseQuoteInputPlanEnumSerializer;

  const PurchaseQuoteInputPlanEnum._(String name): super(name);

  static BuiltSet<PurchaseQuoteInputPlanEnum> get values => _$purchaseQuoteInputPlanEnumValues;
  static PurchaseQuoteInputPlanEnum valueOf(String name) => _$purchaseQuoteInputPlanEnumValueOf(name);
}

