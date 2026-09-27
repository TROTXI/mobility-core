//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/money.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'payment_review.g.dart';

/// PaymentReview
///
/// Properties:
/// * [id] 
/// * [kind] 
/// * [editToken] 
/// * [purchaseId] 
/// * [status] 
/// * [amount] 
/// * [reason] 
/// * [updatedAt] 
@BuiltValue()
abstract class PaymentReview implements Built<PaymentReview, PaymentReviewBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'kind')
  PaymentReviewKindEnum get kind;
  // enum kindEnum {  refund,  dispute,  manual_review,  };

  @BuiltValueField(wireName: r'editToken')
  String get editToken;

  @BuiltValueField(wireName: r'purchaseId')
  String get purchaseId;

  @BuiltValueField(wireName: r'status')
  String get status;

  @BuiltValueField(wireName: r'amount')
  Money get amount;

  @BuiltValueField(wireName: r'reason')
  String? get reason;

  @BuiltValueField(wireName: r'updatedAt')
  DateTime get updatedAt;

  PaymentReview._();

  factory PaymentReview([void updates(PaymentReviewBuilder b)]) = _$PaymentReview;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PaymentReviewBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PaymentReview> get serializer => _$PaymentReviewSerializer();
}

class _$PaymentReviewSerializer implements PrimitiveSerializer<PaymentReview> {
  @override
  final Iterable<Type> types = const [PaymentReview, _$PaymentReview];

  @override
  final String wireName = r'PaymentReview';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PaymentReview object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(PaymentReviewKindEnum),
    );
    yield r'editToken';
    yield serializers.serialize(
      object.editToken,
      specifiedType: const FullType(String),
    );
    yield r'purchaseId';
    yield serializers.serialize(
      object.purchaseId,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(String),
    );
    yield r'amount';
    yield serializers.serialize(
      object.amount,
      specifiedType: const FullType(Money),
    );
    yield r'reason';
    yield object.reason == null ? null : serializers.serialize(
      object.reason,
      specifiedType: const FullType.nullable(String),
    );
    yield r'updatedAt';
    yield serializers.serialize(
      object.updatedAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PaymentReview object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PaymentReviewBuilder result,
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
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PaymentReviewKindEnum),
          ) as PaymentReviewKindEnum;
          result.kind = valueDes;
          break;
        case r'editToken':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.editToken = valueDes;
          break;
        case r'purchaseId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.purchaseId = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.status = valueDes;
          break;
        case r'amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Money),
          ) as Money;
          result.amount.replace(valueDes);
          break;
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.reason = valueDes;
          break;
        case r'updatedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.updatedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PaymentReview deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PaymentReviewBuilder();
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

class PaymentReviewKindEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'refund')
  static const PaymentReviewKindEnum refund = _$paymentReviewKindEnum_refund;
  @BuiltValueEnumConst(wireName: r'dispute')
  static const PaymentReviewKindEnum dispute = _$paymentReviewKindEnum_dispute;
  @BuiltValueEnumConst(wireName: r'manual_review')
  static const PaymentReviewKindEnum manualReview = _$paymentReviewKindEnum_manualReview;

  static Serializer<PaymentReviewKindEnum> get serializer => _$paymentReviewKindEnumSerializer;

  const PaymentReviewKindEnum._(String name): super(name);

  static BuiltSet<PaymentReviewKindEnum> get values => _$paymentReviewKindEnumValues;
  static PaymentReviewKindEnum valueOf(String name) => _$paymentReviewKindEnumValueOf(name);
}

