//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/date.dart';
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/money.dart';
import 'package:trotxi_api_client/src/model/standby_offer_input_credits_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'standby_offer_input.g.dart';

/// StandbyOfferInput
///
/// Properties:
/// * [expiresAt]
/// * [coverageStart]
/// * [coverageEnd]
/// * [price]
/// * [credits]
@BuiltValue()
abstract class StandbyOfferInput
    implements Built<StandbyOfferInput, StandbyOfferInputBuilder> {
  @BuiltValueField(wireName: r'expiresAt')
  DateTime get expiresAt;

  @BuiltValueField(wireName: r'coverageStart')
  Date get coverageStart;

  @BuiltValueField(wireName: r'coverageEnd')
  Date get coverageEnd;

  @BuiltValueField(wireName: r'price')
  Money get price;

  @BuiltValueField(wireName: r'credits')
  BuiltList<StandbyOfferInputCreditsInner> get credits;

  StandbyOfferInput._();

  factory StandbyOfferInput([void updates(StandbyOfferInputBuilder b)]) =
      _$StandbyOfferInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(StandbyOfferInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<StandbyOfferInput> get serializer =>
      _$StandbyOfferInputSerializer();
}

class _$StandbyOfferInputSerializer
    implements PrimitiveSerializer<StandbyOfferInput> {
  @override
  final Iterable<Type> types = const [StandbyOfferInput, _$StandbyOfferInput];

  @override
  final String wireName = r'StandbyOfferInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    StandbyOfferInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'expiresAt';
    yield serializers.serialize(
      object.expiresAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'coverageStart';
    yield serializers.serialize(
      object.coverageStart,
      specifiedType: const FullType(Date),
    );
    yield r'coverageEnd';
    yield serializers.serialize(
      object.coverageEnd,
      specifiedType: const FullType(Date),
    );
    yield r'price';
    yield serializers.serialize(
      object.price,
      specifiedType: const FullType(Money),
    );
    yield r'credits';
    yield serializers.serialize(
      object.credits,
      specifiedType:
          const FullType(BuiltList, [FullType(StandbyOfferInputCreditsInner)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    StandbyOfferInput object, {
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
    required StandbyOfferInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'expiresAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.expiresAt = valueDes;
          break;
        case r'coverageStart':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Date),
          ) as Date;
          result.coverageStart = valueDes;
          break;
        case r'coverageEnd':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Date),
          ) as Date;
          result.coverageEnd = valueDes;
          break;
        case r'price':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Money),
          ) as Money;
          result.price.replace(valueDes);
          break;
        case r'credits':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                BuiltList, [FullType(StandbyOfferInputCreditsInner)]),
          ) as BuiltList<StandbyOfferInputCreditsInner>;
          result.credits.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  StandbyOfferInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = StandbyOfferInputBuilder();
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
