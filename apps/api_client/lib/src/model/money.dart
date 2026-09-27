//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'money.g.dart';

/// Money
///
/// Properties:
/// * [amountMinor] 
/// * [currency] 
@BuiltValue()
abstract class Money implements Built<Money, MoneyBuilder> {
  @BuiltValueField(wireName: r'amountMinor')
  int get amountMinor;

  @BuiltValueField(wireName: r'currency')
  MoneyCurrencyEnum get currency;
  // enum currencyEnum {  GHS,  };

  Money._();

  factory Money([void updates(MoneyBuilder b)]) = _$Money;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MoneyBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Money> get serializer => _$MoneySerializer();
}

class _$MoneySerializer implements PrimitiveSerializer<Money> {
  @override
  final Iterable<Type> types = const [Money, _$Money];

  @override
  final String wireName = r'Money';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Money object, {
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
      specifiedType: const FullType(MoneyCurrencyEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    Money object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MoneyBuilder result,
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
            specifiedType: const FullType(MoneyCurrencyEnum),
          ) as MoneyCurrencyEnum;
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
  Money deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MoneyBuilder();
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

class MoneyCurrencyEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'GHS')
  static const MoneyCurrencyEnum GHS = _$moneyCurrencyEnum_GHS;

  static Serializer<MoneyCurrencyEnum> get serializer => _$moneyCurrencyEnumSerializer;

  const MoneyCurrencyEnum._(String name): super(name);

  static BuiltSet<MoneyCurrencyEnum> get values => _$moneyCurrencyEnumValues;
  static MoneyCurrencyEnum valueOf(String name) => _$moneyCurrencyEnumValueOf(name);
}

