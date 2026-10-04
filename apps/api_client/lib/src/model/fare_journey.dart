//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'fare_journey.g.dart';

/// FareJourney
///
/// Properties:
/// * [pickup]
/// * [dropoff]
/// * [direction]
@BuiltValue()
abstract class FareJourney implements Built<FareJourney, FareJourneyBuilder> {
  @BuiltValueField(wireName: r'pickup')
  String get pickup;

  @BuiltValueField(wireName: r'dropoff')
  String get dropoff;

  @BuiltValueField(wireName: r'direction')
  FareJourneyDirectionEnum get direction;
  // enum directionEnum {  outbound,  return,  };

  FareJourney._();

  factory FareJourney([void updates(FareJourneyBuilder b)]) = _$FareJourney;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FareJourneyBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FareJourney> get serializer => _$FareJourneySerializer();
}

class _$FareJourneySerializer implements PrimitiveSerializer<FareJourney> {
  @override
  final Iterable<Type> types = const [FareJourney, _$FareJourney];

  @override
  final String wireName = r'FareJourney';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FareJourney object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'pickup';
    yield serializers.serialize(
      object.pickup,
      specifiedType: const FullType(String),
    );
    yield r'dropoff';
    yield serializers.serialize(
      object.dropoff,
      specifiedType: const FullType(String),
    );
    yield r'direction';
    yield serializers.serialize(
      object.direction,
      specifiedType: const FullType(FareJourneyDirectionEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    FareJourney object, {
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
    required FareJourneyBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'pickup':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.pickup = valueDes;
          break;
        case r'dropoff':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.dropoff = valueDes;
          break;
        case r'direction':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FareJourneyDirectionEnum),
          ) as FareJourneyDirectionEnum;
          result.direction = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  FareJourney deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FareJourneyBuilder();
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

class FareJourneyDirectionEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'outbound')
  static const FareJourneyDirectionEnum outbound =
      _$fareJourneyDirectionEnum_outbound;
  @BuiltValueEnumConst(wireName: r'return')
  static const FareJourneyDirectionEnum return_ =
      _$fareJourneyDirectionEnum_return_;

  static Serializer<FareJourneyDirectionEnum> get serializer =>
      _$fareJourneyDirectionEnumSerializer;

  const FareJourneyDirectionEnum._(String name) : super(name);

  static BuiltSet<FareJourneyDirectionEnum> get values =>
      _$fareJourneyDirectionEnumValues;
  static FareJourneyDirectionEnum valueOf(String name) =>
      _$fareJourneyDirectionEnumValueOf(name);
}
