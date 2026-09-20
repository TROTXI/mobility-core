//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'credit_entry.g.dart';

/// CreditEntry
///
/// Properties:
/// * [id] 
/// * [deltaMinor] 
/// * [currency] 
/// * [reason] 
/// * [createdAt] 
@BuiltValue()
abstract class CreditEntry implements Built<CreditEntry, CreditEntryBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'deltaMinor')
  int get deltaMinor;

  @BuiltValueField(wireName: r'currency')
  CreditEntryCurrencyEnum get currency;
  // enum currencyEnum {  GHS,  };

  @BuiltValueField(wireName: r'reason')
  CreditEntryReasonEnum get reason;
  // enum reasonEnum {  month_end_conversion,  purchase_applied,  refund_restored,  conversion_reversed,  adjustment,  };

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  CreditEntry._();

  factory CreditEntry([void updates(CreditEntryBuilder b)]) = _$CreditEntry;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreditEntryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreditEntry> get serializer => _$CreditEntrySerializer();
}

class _$CreditEntrySerializer implements PrimitiveSerializer<CreditEntry> {
  @override
  final Iterable<Type> types = const [CreditEntry, _$CreditEntry];

  @override
  final String wireName = r'CreditEntry';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreditEntry object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'deltaMinor';
    yield serializers.serialize(
      object.deltaMinor,
      specifiedType: const FullType(int),
    );
    yield r'currency';
    yield serializers.serialize(
      object.currency,
      specifiedType: const FullType(CreditEntryCurrencyEnum),
    );
    yield r'reason';
    yield serializers.serialize(
      object.reason,
      specifiedType: const FullType(CreditEntryReasonEnum),
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
    CreditEntry object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CreditEntryBuilder result,
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
        case r'deltaMinor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.deltaMinor = valueDes;
          break;
        case r'currency':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CreditEntryCurrencyEnum),
          ) as CreditEntryCurrencyEnum;
          result.currency = valueDes;
          break;
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CreditEntryReasonEnum),
          ) as CreditEntryReasonEnum;
          result.reason = valueDes;
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
  CreditEntry deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreditEntryBuilder();
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

class CreditEntryCurrencyEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'GHS')
  static const CreditEntryCurrencyEnum GHS = _$creditEntryCurrencyEnum_GHS;

  static Serializer<CreditEntryCurrencyEnum> get serializer => _$creditEntryCurrencyEnumSerializer;

  const CreditEntryCurrencyEnum._(String name): super(name);

  static BuiltSet<CreditEntryCurrencyEnum> get values => _$creditEntryCurrencyEnumValues;
  static CreditEntryCurrencyEnum valueOf(String name) => _$creditEntryCurrencyEnumValueOf(name);
}

class CreditEntryReasonEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'month_end_conversion')
  static const CreditEntryReasonEnum monthEndConversion = _$creditEntryReasonEnum_monthEndConversion;
  @BuiltValueEnumConst(wireName: r'purchase_applied')
  static const CreditEntryReasonEnum purchaseApplied = _$creditEntryReasonEnum_purchaseApplied;
  @BuiltValueEnumConst(wireName: r'refund_restored')
  static const CreditEntryReasonEnum refundRestored = _$creditEntryReasonEnum_refundRestored;
  @BuiltValueEnumConst(wireName: r'conversion_reversed')
  static const CreditEntryReasonEnum conversionReversed = _$creditEntryReasonEnum_conversionReversed;
  @BuiltValueEnumConst(wireName: r'adjustment')
  static const CreditEntryReasonEnum adjustment = _$creditEntryReasonEnum_adjustment;

  static Serializer<CreditEntryReasonEnum> get serializer => _$creditEntryReasonEnumSerializer;

  const CreditEntryReasonEnum._(String name): super(name);

  static BuiltSet<CreditEntryReasonEnum> get values => _$creditEntryReasonEnumValues;
  static CreditEntryReasonEnum valueOf(String name) => _$creditEntryReasonEnumValueOf(name);
}

