//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/money.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'purchase_quote.g.dart';

/// PurchaseQuote
///
/// Properties:
/// * [routeId] 
/// * [plan] 
/// * [ridesGranted] 
/// * [fare] 
/// * [price] 
/// * [availableCredit] 
/// * [appliedCredit] 
/// * [cashDue] 
/// * [minimumCashDue] 
/// * [renewalMode] 
/// * [binding] 
/// * [quotedAt] 
@BuiltValue()
abstract class PurchaseQuote implements Built<PurchaseQuote, PurchaseQuoteBuilder> {
  @BuiltValueField(wireName: r'routeId')
  String get routeId;

  @BuiltValueField(wireName: r'plan')
  PurchaseQuotePlanEnum get plan;
  // enum planEnum {  monthly,  annual,  };

  @BuiltValueField(wireName: r'ridesGranted')
  int get ridesGranted;

  @BuiltValueField(wireName: r'fare')
  Money get fare;

  @BuiltValueField(wireName: r'price')
  Money get price;

  @BuiltValueField(wireName: r'availableCredit')
  Money get availableCredit;

  @BuiltValueField(wireName: r'appliedCredit')
  Money get appliedCredit;

  @BuiltValueField(wireName: r'cashDue')
  Money get cashDue;

  @BuiltValueField(wireName: r'minimumCashDue')
  Money get minimumCashDue;

  @BuiltValueField(wireName: r'renewalMode')
  PurchaseQuoteRenewalModeEnum get renewalMode;
  // enum renewalModeEnum {  manual,  };

  @BuiltValueField(wireName: r'binding')
  bool get binding;

  @BuiltValueField(wireName: r'quotedAt')
  DateTime get quotedAt;

  PurchaseQuote._();

  factory PurchaseQuote([void updates(PurchaseQuoteBuilder b)]) = _$PurchaseQuote;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PurchaseQuoteBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PurchaseQuote> get serializer => _$PurchaseQuoteSerializer();
}

class _$PurchaseQuoteSerializer implements PrimitiveSerializer<PurchaseQuote> {
  @override
  final Iterable<Type> types = const [PurchaseQuote, _$PurchaseQuote];

  @override
  final String wireName = r'PurchaseQuote';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PurchaseQuote object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'routeId';
    yield serializers.serialize(
      object.routeId,
      specifiedType: const FullType(String),
    );
    yield r'plan';
    yield serializers.serialize(
      object.plan,
      specifiedType: const FullType(PurchaseQuotePlanEnum),
    );
    yield r'ridesGranted';
    yield serializers.serialize(
      object.ridesGranted,
      specifiedType: const FullType(int),
    );
    yield r'fare';
    yield serializers.serialize(
      object.fare,
      specifiedType: const FullType(Money),
    );
    yield r'price';
    yield serializers.serialize(
      object.price,
      specifiedType: const FullType(Money),
    );
    yield r'availableCredit';
    yield serializers.serialize(
      object.availableCredit,
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
    yield r'minimumCashDue';
    yield serializers.serialize(
      object.minimumCashDue,
      specifiedType: const FullType(Money),
    );
    yield r'renewalMode';
    yield serializers.serialize(
      object.renewalMode,
      specifiedType: const FullType(PurchaseQuoteRenewalModeEnum),
    );
    yield r'binding';
    yield serializers.serialize(
      object.binding,
      specifiedType: const FullType(bool),
    );
    yield r'quotedAt';
    yield serializers.serialize(
      object.quotedAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PurchaseQuote object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PurchaseQuoteBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'routeId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.routeId = valueDes;
          break;
        case r'plan':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PurchaseQuotePlanEnum),
          ) as PurchaseQuotePlanEnum;
          result.plan = valueDes;
          break;
        case r'ridesGranted':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.ridesGranted = valueDes;
          break;
        case r'fare':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Money),
          ) as Money;
          result.fare.replace(valueDes);
          break;
        case r'price':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Money),
          ) as Money;
          result.price.replace(valueDes);
          break;
        case r'availableCredit':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Money),
          ) as Money;
          result.availableCredit.replace(valueDes);
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
        case r'minimumCashDue':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Money),
          ) as Money;
          result.minimumCashDue.replace(valueDes);
          break;
        case r'renewalMode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PurchaseQuoteRenewalModeEnum),
          ) as PurchaseQuoteRenewalModeEnum;
          result.renewalMode = valueDes;
          break;
        case r'binding':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.binding = valueDes;
          break;
        case r'quotedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.quotedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PurchaseQuote deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PurchaseQuoteBuilder();
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

class PurchaseQuotePlanEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'monthly')
  static const PurchaseQuotePlanEnum monthly = _$purchaseQuotePlanEnum_monthly;
  @BuiltValueEnumConst(wireName: r'annual')
  static const PurchaseQuotePlanEnum annual = _$purchaseQuotePlanEnum_annual;

  static Serializer<PurchaseQuotePlanEnum> get serializer => _$purchaseQuotePlanEnumSerializer;

  const PurchaseQuotePlanEnum._(String name): super(name);

  static BuiltSet<PurchaseQuotePlanEnum> get values => _$purchaseQuotePlanEnumValues;
  static PurchaseQuotePlanEnum valueOf(String name) => _$purchaseQuotePlanEnumValueOf(name);
}

class PurchaseQuoteRenewalModeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'manual')
  static const PurchaseQuoteRenewalModeEnum manual = _$purchaseQuoteRenewalModeEnum_manual;

  static Serializer<PurchaseQuoteRenewalModeEnum> get serializer => _$purchaseQuoteRenewalModeEnumSerializer;

  const PurchaseQuoteRenewalModeEnum._(String name): super(name);

  static BuiltSet<PurchaseQuoteRenewalModeEnum> get values => _$purchaseQuoteRenewalModeEnumValues;
  static PurchaseQuoteRenewalModeEnum valueOf(String name) => _$purchaseQuoteRenewalModeEnumValueOf(name);
}

