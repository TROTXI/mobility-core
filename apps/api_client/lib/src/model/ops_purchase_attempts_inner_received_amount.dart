//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ops_purchase_attempts_inner_received_amount.g.dart';

/// OpsPurchaseAttemptsInnerReceivedAmount
///
/// Properties:
<<<<<<< HEAD
/// * [amountMinor] 
/// * [currency] 
@BuiltValue()
abstract class OpsPurchaseAttemptsInnerReceivedAmount implements Built<OpsPurchaseAttemptsInnerReceivedAmount, OpsPurchaseAttemptsInnerReceivedAmountBuilder> {
=======
/// * [amountMinor]
/// * [currency]
@BuiltValue()
abstract class OpsPurchaseAttemptsInnerReceivedAmount
    implements
        Built<OpsPurchaseAttemptsInnerReceivedAmount,
            OpsPurchaseAttemptsInnerReceivedAmountBuilder> {
>>>>>>> origin/main
  @BuiltValueField(wireName: r'amountMinor')
  int get amountMinor;

  @BuiltValueField(wireName: r'currency')
  OpsPurchaseAttemptsInnerReceivedAmountCurrencyEnum get currency;
  // enum currencyEnum {  GHS,  };

  OpsPurchaseAttemptsInnerReceivedAmount._();

<<<<<<< HEAD
  factory OpsPurchaseAttemptsInnerReceivedAmount([void updates(OpsPurchaseAttemptsInnerReceivedAmountBuilder b)]) = _$OpsPurchaseAttemptsInnerReceivedAmount;
=======
  factory OpsPurchaseAttemptsInnerReceivedAmount(
          [void updates(OpsPurchaseAttemptsInnerReceivedAmountBuilder b)]) =
      _$OpsPurchaseAttemptsInnerReceivedAmount;
>>>>>>> origin/main

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OpsPurchaseAttemptsInnerReceivedAmountBuilder b) => b;

  @BuiltValueSerializer(custom: true)
<<<<<<< HEAD
  static Serializer<OpsPurchaseAttemptsInnerReceivedAmount> get serializer => _$OpsPurchaseAttemptsInnerReceivedAmountSerializer();
}

class _$OpsPurchaseAttemptsInnerReceivedAmountSerializer implements PrimitiveSerializer<OpsPurchaseAttemptsInnerReceivedAmount> {
  @override
  final Iterable<Type> types = const [OpsPurchaseAttemptsInnerReceivedAmount, _$OpsPurchaseAttemptsInnerReceivedAmount];
=======
  static Serializer<OpsPurchaseAttemptsInnerReceivedAmount> get serializer =>
      _$OpsPurchaseAttemptsInnerReceivedAmountSerializer();
}

class _$OpsPurchaseAttemptsInnerReceivedAmountSerializer
    implements PrimitiveSerializer<OpsPurchaseAttemptsInnerReceivedAmount> {
  @override
  final Iterable<Type> types = const [
    OpsPurchaseAttemptsInnerReceivedAmount,
    _$OpsPurchaseAttemptsInnerReceivedAmount
  ];
>>>>>>> origin/main

  @override
  final String wireName = r'OpsPurchaseAttemptsInnerReceivedAmount';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OpsPurchaseAttemptsInnerReceivedAmount object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'amountMinor';
    yield serializers.serialize(
      object.amountMinor,
      specifiedType: const FullType(int),
    );
    yield r'currency';
    yield serializers.serialize(
      object.currency,
<<<<<<< HEAD
      specifiedType: const FullType(OpsPurchaseAttemptsInnerReceivedAmountCurrencyEnum),
=======
      specifiedType:
          const FullType(OpsPurchaseAttemptsInnerReceivedAmountCurrencyEnum),
>>>>>>> origin/main
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OpsPurchaseAttemptsInnerReceivedAmount object, {
    FullType specifiedType = FullType.unspecified,
  }) {
<<<<<<< HEAD
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
=======
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
>>>>>>> origin/main
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OpsPurchaseAttemptsInnerReceivedAmountBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'amountMinor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.amountMinor = valueDes;
          break;
        case r'currency':
          final valueDes = serializers.deserialize(
            value,
<<<<<<< HEAD
            specifiedType: const FullType(OpsPurchaseAttemptsInnerReceivedAmountCurrencyEnum),
=======
            specifiedType: const FullType(
                OpsPurchaseAttemptsInnerReceivedAmountCurrencyEnum),
>>>>>>> origin/main
          ) as OpsPurchaseAttemptsInnerReceivedAmountCurrencyEnum;
          result.currency = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OpsPurchaseAttemptsInnerReceivedAmount deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OpsPurchaseAttemptsInnerReceivedAmountBuilder();
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

class OpsPurchaseAttemptsInnerReceivedAmountCurrencyEnum extends EnumClass {
<<<<<<< HEAD

  @BuiltValueEnumConst(wireName: r'GHS')
  static const OpsPurchaseAttemptsInnerReceivedAmountCurrencyEnum GHS = _$opsPurchaseAttemptsInnerReceivedAmountCurrencyEnum_GHS;

  static Serializer<OpsPurchaseAttemptsInnerReceivedAmountCurrencyEnum> get serializer => _$opsPurchaseAttemptsInnerReceivedAmountCurrencyEnumSerializer;

  const OpsPurchaseAttemptsInnerReceivedAmountCurrencyEnum._(String name): super(name);

  static BuiltSet<OpsPurchaseAttemptsInnerReceivedAmountCurrencyEnum> get values => _$opsPurchaseAttemptsInnerReceivedAmountCurrencyEnumValues;
  static OpsPurchaseAttemptsInnerReceivedAmountCurrencyEnum valueOf(String name) => _$opsPurchaseAttemptsInnerReceivedAmountCurrencyEnumValueOf(name);
}

=======
  @BuiltValueEnumConst(wireName: r'GHS')
  static const OpsPurchaseAttemptsInnerReceivedAmountCurrencyEnum GHS =
      _$opsPurchaseAttemptsInnerReceivedAmountCurrencyEnum_GHS;

  static Serializer<OpsPurchaseAttemptsInnerReceivedAmountCurrencyEnum>
      get serializer =>
          _$opsPurchaseAttemptsInnerReceivedAmountCurrencyEnumSerializer;

  const OpsPurchaseAttemptsInnerReceivedAmountCurrencyEnum._(String name)
      : super(name);

  static BuiltSet<OpsPurchaseAttemptsInnerReceivedAmountCurrencyEnum>
      get values => _$opsPurchaseAttemptsInnerReceivedAmountCurrencyEnumValues;
  static OpsPurchaseAttemptsInnerReceivedAmountCurrencyEnum valueOf(
          String name) =>
      _$opsPurchaseAttemptsInnerReceivedAmountCurrencyEnumValueOf(name);
}
>>>>>>> origin/main
