//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/money.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'standby_offer_input_credits_inner.g.dart';

/// StandbyOfferInputCreditsInner
///
/// Properties:
/// * [direction]
/// * [creditPerUnusedRide]
@BuiltValue()
abstract class StandbyOfferInputCreditsInner
    implements
        Built<StandbyOfferInputCreditsInner,
            StandbyOfferInputCreditsInnerBuilder> {
  @BuiltValueField(wireName: r'direction')
  StandbyOfferInputCreditsInnerDirectionEnum get direction;
  // enum directionEnum {  outbound,  return,  };

  @BuiltValueField(wireName: r'creditPerUnusedRide')
  Money get creditPerUnusedRide;

  StandbyOfferInputCreditsInner._();

  factory StandbyOfferInputCreditsInner(
          [void updates(StandbyOfferInputCreditsInnerBuilder b)]) =
      _$StandbyOfferInputCreditsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(StandbyOfferInputCreditsInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<StandbyOfferInputCreditsInner> get serializer =>
      _$StandbyOfferInputCreditsInnerSerializer();
}

class _$StandbyOfferInputCreditsInnerSerializer
    implements PrimitiveSerializer<StandbyOfferInputCreditsInner> {
  @override
  final Iterable<Type> types = const [
    StandbyOfferInputCreditsInner,
    _$StandbyOfferInputCreditsInner
  ];

  @override
  final String wireName = r'StandbyOfferInputCreditsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    StandbyOfferInputCreditsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'direction';
    yield serializers.serialize(
      object.direction,
      specifiedType: const FullType(StandbyOfferInputCreditsInnerDirectionEnum),
    );
    yield r'creditPerUnusedRide';
    yield serializers.serialize(
      object.creditPerUnusedRide,
      specifiedType: const FullType(Money),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    StandbyOfferInputCreditsInner object, {
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
    required StandbyOfferInputCreditsInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'direction':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(StandbyOfferInputCreditsInnerDirectionEnum),
          ) as StandbyOfferInputCreditsInnerDirectionEnum;
          result.direction = valueDes;
          break;
        case r'creditPerUnusedRide':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Money),
          ) as Money;
          result.creditPerUnusedRide.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  StandbyOfferInputCreditsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = StandbyOfferInputCreditsInnerBuilder();
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

class StandbyOfferInputCreditsInnerDirectionEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'outbound')
  static const StandbyOfferInputCreditsInnerDirectionEnum outbound =
      _$standbyOfferInputCreditsInnerDirectionEnum_outbound;
  @BuiltValueEnumConst(wireName: r'return')
  static const StandbyOfferInputCreditsInnerDirectionEnum return_ =
      _$standbyOfferInputCreditsInnerDirectionEnum_return_;

  static Serializer<StandbyOfferInputCreditsInnerDirectionEnum>
      get serializer => _$standbyOfferInputCreditsInnerDirectionEnumSerializer;

  const StandbyOfferInputCreditsInnerDirectionEnum._(String name) : super(name);

  static BuiltSet<StandbyOfferInputCreditsInnerDirectionEnum> get values =>
      _$standbyOfferInputCreditsInnerDirectionEnumValues;
  static StandbyOfferInputCreditsInnerDirectionEnum valueOf(String name) =>
      _$standbyOfferInputCreditsInnerDirectionEnumValueOf(name);
}
