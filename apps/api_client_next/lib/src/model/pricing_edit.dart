//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client_next/src/model/money.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pricing_edit.g.dart';

/// PricingEdit
///
/// Properties:
/// * [ridesPerPeriod] 
/// * [priceMultiplierBp] 
/// * [takeRateBp] 
/// * [creditPerRide] 
@BuiltValue()
abstract class PricingEdit implements Built<PricingEdit, PricingEditBuilder> {
  @BuiltValueField(wireName: r'ridesPerPeriod')
  int? get ridesPerPeriod;

  @BuiltValueField(wireName: r'priceMultiplierBp')
  int? get priceMultiplierBp;

  @BuiltValueField(wireName: r'takeRateBp')
  int? get takeRateBp;

  @BuiltValueField(wireName: r'creditPerRide')
  Money? get creditPerRide;

  PricingEdit._();

  factory PricingEdit([void updates(PricingEditBuilder b)]) = _$PricingEdit;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PricingEditBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PricingEdit> get serializer => _$PricingEditSerializer();
}

class _$PricingEditSerializer implements PrimitiveSerializer<PricingEdit> {
  @override
  final Iterable<Type> types = const [PricingEdit, _$PricingEdit];

  @override
  final String wireName = r'PricingEdit';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PricingEdit object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.ridesPerPeriod != null) {
      yield r'ridesPerPeriod';
      yield serializers.serialize(
        object.ridesPerPeriod,
        specifiedType: const FullType(int),
      );
    }
    if (object.priceMultiplierBp != null) {
      yield r'priceMultiplierBp';
      yield serializers.serialize(
        object.priceMultiplierBp,
        specifiedType: const FullType(int),
      );
    }
    if (object.takeRateBp != null) {
      yield r'takeRateBp';
      yield serializers.serialize(
        object.takeRateBp,
        specifiedType: const FullType(int),
      );
    }
    if (object.creditPerRide != null) {
      yield r'creditPerRide';
      yield serializers.serialize(
        object.creditPerRide,
        specifiedType: const FullType(Money),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PricingEdit object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PricingEditBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'ridesPerPeriod':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.ridesPerPeriod = valueDes;
          break;
        case r'priceMultiplierBp':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.priceMultiplierBp = valueDes;
          break;
        case r'takeRateBp':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.takeRateBp = valueDes;
          break;
        case r'creditPerRide':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Money),
          ) as Money;
          result.creditPerRide.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PricingEdit deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PricingEditBuilder();
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

