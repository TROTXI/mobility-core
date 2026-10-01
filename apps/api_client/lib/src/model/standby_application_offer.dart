//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'standby_application_offer.g.dart';

/// StandbyApplicationOffer
///
/// Properties:
/// * [id]
/// * [state]
/// * [expiresAt]
/// * [purchaseId]
@BuiltValue()
abstract class StandbyApplicationOffer
    implements Built<StandbyApplicationOffer, StandbyApplicationOfferBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'state')
  StandbyApplicationOfferStateEnum get state;
  // enum stateEnum {  offered,  accepting,  checkout_open,  cancelled,  };

  @BuiltValueField(wireName: r'expiresAt')
  DateTime get expiresAt;

  @BuiltValueField(wireName: r'purchaseId')
  String? get purchaseId;

  StandbyApplicationOffer._();

  factory StandbyApplicationOffer(
          [void updates(StandbyApplicationOfferBuilder b)]) =
      _$StandbyApplicationOffer;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(StandbyApplicationOfferBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<StandbyApplicationOffer> get serializer =>
      _$StandbyApplicationOfferSerializer();
}

class _$StandbyApplicationOfferSerializer
    implements PrimitiveSerializer<StandbyApplicationOffer> {
  @override
  final Iterable<Type> types = const [
    StandbyApplicationOffer,
    _$StandbyApplicationOffer
  ];

  @override
  final String wireName = r'StandbyApplicationOffer';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    StandbyApplicationOffer object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'state';
    yield serializers.serialize(
      object.state,
      specifiedType: const FullType(StandbyApplicationOfferStateEnum),
    );
    yield r'expiresAt';
    yield serializers.serialize(
      object.expiresAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'purchaseId';
    yield object.purchaseId == null
        ? null
        : serializers.serialize(
            object.purchaseId,
            specifiedType: const FullType.nullable(String),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    StandbyApplicationOffer object, {
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
    required StandbyApplicationOfferBuilder result,
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
        case r'state':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(StandbyApplicationOfferStateEnum),
          ) as StandbyApplicationOfferStateEnum;
          result.state = valueDes;
          break;
        case r'expiresAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.expiresAt = valueDes;
          break;
        case r'purchaseId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.purchaseId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  StandbyApplicationOffer deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = StandbyApplicationOfferBuilder();
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

class StandbyApplicationOfferStateEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'offered')
  static const StandbyApplicationOfferStateEnum offered =
      _$standbyApplicationOfferStateEnum_offered;
  @BuiltValueEnumConst(wireName: r'accepting')
  static const StandbyApplicationOfferStateEnum accepting =
      _$standbyApplicationOfferStateEnum_accepting;
  @BuiltValueEnumConst(wireName: r'checkout_open')
  static const StandbyApplicationOfferStateEnum checkoutOpen =
      _$standbyApplicationOfferStateEnum_checkoutOpen;
  @BuiltValueEnumConst(wireName: r'cancelled')
  static const StandbyApplicationOfferStateEnum cancelled =
      _$standbyApplicationOfferStateEnum_cancelled;

  static Serializer<StandbyApplicationOfferStateEnum> get serializer =>
      _$standbyApplicationOfferStateEnumSerializer;

  const StandbyApplicationOfferStateEnum._(String name) : super(name);

  static BuiltSet<StandbyApplicationOfferStateEnum> get values =>
      _$standbyApplicationOfferStateEnumValues;
  static StandbyApplicationOfferStateEnum valueOf(String name) =>
      _$standbyApplicationOfferStateEnumValueOf(name);
}
