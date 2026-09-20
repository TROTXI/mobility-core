//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/money.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'refund_initiation.g.dart';

/// RefundInitiation
///
/// Properties:
/// * [id] 
/// * [purchaseId] 
/// * [amount] 
/// * [reason] 
/// * [state] 
/// * [providerRefundId] 
/// * [createdAt] 
@BuiltValue()
abstract class RefundInitiation implements Built<RefundInitiation, RefundInitiationBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'purchaseId')
  String get purchaseId;

  @BuiltValueField(wireName: r'amount')
  Money get amount;

  @BuiltValueField(wireName: r'reason')
  String get reason;

  @BuiltValueField(wireName: r'state')
  RefundInitiationStateEnum get state;
  // enum stateEnum {  submitting,  accepted,  unknown,  };

  @BuiltValueField(wireName: r'providerRefundId')
  String? get providerRefundId;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  RefundInitiation._();

  factory RefundInitiation([void updates(RefundInitiationBuilder b)]) = _$RefundInitiation;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RefundInitiationBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RefundInitiation> get serializer => _$RefundInitiationSerializer();
}

class _$RefundInitiationSerializer implements PrimitiveSerializer<RefundInitiation> {
  @override
  final Iterable<Type> types = const [RefundInitiation, _$RefundInitiation];

  @override
  final String wireName = r'RefundInitiation';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RefundInitiation object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'purchaseId';
    yield serializers.serialize(
      object.purchaseId,
      specifiedType: const FullType(String),
    );
    yield r'amount';
    yield serializers.serialize(
      object.amount,
      specifiedType: const FullType(Money),
    );
    yield r'reason';
    yield serializers.serialize(
      object.reason,
      specifiedType: const FullType(String),
    );
    yield r'state';
    yield serializers.serialize(
      object.state,
      specifiedType: const FullType(RefundInitiationStateEnum),
    );
    yield r'providerRefundId';
    yield object.providerRefundId == null ? null : serializers.serialize(
      object.providerRefundId,
      specifiedType: const FullType.nullable(String),
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
    RefundInitiation object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RefundInitiationBuilder result,
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
        case r'purchaseId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.purchaseId = valueDes;
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
            specifiedType: const FullType(String),
          ) as String;
          result.reason = valueDes;
          break;
        case r'state':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(RefundInitiationStateEnum),
          ) as RefundInitiationStateEnum;
          result.state = valueDes;
          break;
        case r'providerRefundId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.providerRefundId = valueDes;
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
  RefundInitiation deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RefundInitiationBuilder();
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

class RefundInitiationStateEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'submitting')
  static const RefundInitiationStateEnum submitting = _$refundInitiationStateEnum_submitting;
  @BuiltValueEnumConst(wireName: r'accepted')
  static const RefundInitiationStateEnum accepted = _$refundInitiationStateEnum_accepted;
  @BuiltValueEnumConst(wireName: r'unknown')
  static const RefundInitiationStateEnum unknown = _$refundInitiationStateEnum_unknown;

  static Serializer<RefundInitiationStateEnum> get serializer => _$refundInitiationStateEnumSerializer;

  const RefundInitiationStateEnum._(String name): super(name);

  static BuiltSet<RefundInitiationStateEnum> get values => _$refundInitiationStateEnumValues;
  static RefundInitiationStateEnum valueOf(String name) => _$refundInitiationStateEnumValueOf(name);
}

