//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/ops_purchase_attempts_inner_received_amount.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ops_purchase_attempts_inner.g.dart';

/// OpsPurchaseAttemptsInner
///
/// Properties:
/// * [id] 
/// * [providerReference] 
/// * [providerTransactionId] 
/// * [environment] 
/// * [status] 
/// * [receivedAmount] 
@BuiltValue()
abstract class OpsPurchaseAttemptsInner implements Built<OpsPurchaseAttemptsInner, OpsPurchaseAttemptsInnerBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'providerReference')
  String get providerReference;

  @BuiltValueField(wireName: r'providerTransactionId')
  String? get providerTransactionId;

  @BuiltValueField(wireName: r'environment')
  OpsPurchaseAttemptsInnerEnvironmentEnum get environment;
  // enum environmentEnum {  test,  live,  };

  @BuiltValueField(wireName: r'status')
  OpsPurchaseAttemptsInnerStatusEnum get status;
  // enum statusEnum {  pending,  successful,  failed,  unknown,  };

  @BuiltValueField(wireName: r'receivedAmount')
  OpsPurchaseAttemptsInnerReceivedAmount? get receivedAmount;

  OpsPurchaseAttemptsInner._();

  factory OpsPurchaseAttemptsInner([void updates(OpsPurchaseAttemptsInnerBuilder b)]) = _$OpsPurchaseAttemptsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OpsPurchaseAttemptsInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OpsPurchaseAttemptsInner> get serializer => _$OpsPurchaseAttemptsInnerSerializer();
}

class _$OpsPurchaseAttemptsInnerSerializer implements PrimitiveSerializer<OpsPurchaseAttemptsInner> {
  @override
  final Iterable<Type> types = const [OpsPurchaseAttemptsInner, _$OpsPurchaseAttemptsInner];

  @override
  final String wireName = r'OpsPurchaseAttemptsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OpsPurchaseAttemptsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'providerReference';
    yield serializers.serialize(
      object.providerReference,
      specifiedType: const FullType(String),
    );
    yield r'providerTransactionId';
    yield object.providerTransactionId == null ? null : serializers.serialize(
      object.providerTransactionId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'environment';
    yield serializers.serialize(
      object.environment,
      specifiedType: const FullType(OpsPurchaseAttemptsInnerEnvironmentEnum),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(OpsPurchaseAttemptsInnerStatusEnum),
    );
    yield r'receivedAmount';
    yield object.receivedAmount == null ? null : serializers.serialize(
      object.receivedAmount,
      specifiedType: const FullType.nullable(OpsPurchaseAttemptsInnerReceivedAmount),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OpsPurchaseAttemptsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OpsPurchaseAttemptsInnerBuilder result,
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
        case r'providerReference':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.providerReference = valueDes;
          break;
        case r'providerTransactionId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.providerTransactionId = valueDes;
          break;
        case r'environment':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OpsPurchaseAttemptsInnerEnvironmentEnum),
          ) as OpsPurchaseAttemptsInnerEnvironmentEnum;
          result.environment = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OpsPurchaseAttemptsInnerStatusEnum),
          ) as OpsPurchaseAttemptsInnerStatusEnum;
          result.status = valueDes;
          break;
        case r'receivedAmount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(OpsPurchaseAttemptsInnerReceivedAmount),
          ) as OpsPurchaseAttemptsInnerReceivedAmount?;
          if (valueDes == null) continue;
          result.receivedAmount.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OpsPurchaseAttemptsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OpsPurchaseAttemptsInnerBuilder();
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

class OpsPurchaseAttemptsInnerEnvironmentEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'test')
  static const OpsPurchaseAttemptsInnerEnvironmentEnum test = _$opsPurchaseAttemptsInnerEnvironmentEnum_test;
  @BuiltValueEnumConst(wireName: r'live')
  static const OpsPurchaseAttemptsInnerEnvironmentEnum live = _$opsPurchaseAttemptsInnerEnvironmentEnum_live;

  static Serializer<OpsPurchaseAttemptsInnerEnvironmentEnum> get serializer => _$opsPurchaseAttemptsInnerEnvironmentEnumSerializer;

  const OpsPurchaseAttemptsInnerEnvironmentEnum._(String name): super(name);

  static BuiltSet<OpsPurchaseAttemptsInnerEnvironmentEnum> get values => _$opsPurchaseAttemptsInnerEnvironmentEnumValues;
  static OpsPurchaseAttemptsInnerEnvironmentEnum valueOf(String name) => _$opsPurchaseAttemptsInnerEnvironmentEnumValueOf(name);
}

class OpsPurchaseAttemptsInnerStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'pending')
  static const OpsPurchaseAttemptsInnerStatusEnum pending = _$opsPurchaseAttemptsInnerStatusEnum_pending;
  @BuiltValueEnumConst(wireName: r'successful')
  static const OpsPurchaseAttemptsInnerStatusEnum successful = _$opsPurchaseAttemptsInnerStatusEnum_successful;
  @BuiltValueEnumConst(wireName: r'failed')
  static const OpsPurchaseAttemptsInnerStatusEnum failed = _$opsPurchaseAttemptsInnerStatusEnum_failed;
  @BuiltValueEnumConst(wireName: r'unknown')
  static const OpsPurchaseAttemptsInnerStatusEnum unknown = _$opsPurchaseAttemptsInnerStatusEnum_unknown;

  static Serializer<OpsPurchaseAttemptsInnerStatusEnum> get serializer => _$opsPurchaseAttemptsInnerStatusEnumSerializer;

  const OpsPurchaseAttemptsInnerStatusEnum._(String name): super(name);

  static BuiltSet<OpsPurchaseAttemptsInnerStatusEnum> get values => _$opsPurchaseAttemptsInnerStatusEnumValues;
  static OpsPurchaseAttemptsInnerStatusEnum valueOf(String name) => _$opsPurchaseAttemptsInnerStatusEnumValueOf(name);
}

