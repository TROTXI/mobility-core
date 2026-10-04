//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/money.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'fare_input.g.dart';

/// FareInput
///
/// Properties:
/// * [amount]
/// * [effectiveFrom]
/// * [note]
/// * [patternVersionId]
/// * [pickupOccurrenceId]
/// * [dropoffOccurrenceId]
@BuiltValue()
abstract class FareInput implements Built<FareInput, FareInputBuilder> {
  @BuiltValueField(wireName: r'amount')
  Money get amount;

  @BuiltValueField(wireName: r'effectiveFrom')
  DateTime get effectiveFrom;

  @BuiltValueField(wireName: r'note')
  String? get note;

  @BuiltValueField(wireName: r'patternVersionId')
  String? get patternVersionId;

  @BuiltValueField(wireName: r'pickupOccurrenceId')
  String? get pickupOccurrenceId;

  @BuiltValueField(wireName: r'dropoffOccurrenceId')
  String? get dropoffOccurrenceId;

  FareInput._();

  factory FareInput([void updates(FareInputBuilder b)]) = _$FareInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FareInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FareInput> get serializer => _$FareInputSerializer();
}

class _$FareInputSerializer implements PrimitiveSerializer<FareInput> {
  @override
  final Iterable<Type> types = const [FareInput, _$FareInput];

  @override
  final String wireName = r'FareInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FareInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'amount';
    yield serializers.serialize(
      object.amount,
      specifiedType: const FullType(Money),
    );
    yield r'effectiveFrom';
    yield serializers.serialize(
      object.effectiveFrom,
      specifiedType: const FullType(DateTime),
    );
    if (object.note != null) {
      yield r'note';
      yield serializers.serialize(
        object.note,
        specifiedType: const FullType(String),
      );
    }
    if (object.patternVersionId != null) {
      yield r'patternVersionId';
      yield serializers.serialize(
        object.patternVersionId,
        specifiedType: const FullType(String),
      );
    }
    if (object.pickupOccurrenceId != null) {
      yield r'pickupOccurrenceId';
      yield serializers.serialize(
        object.pickupOccurrenceId,
        specifiedType: const FullType(String),
      );
    }
    if (object.dropoffOccurrenceId != null) {
      yield r'dropoffOccurrenceId';
      yield serializers.serialize(
        object.dropoffOccurrenceId,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    FareInput object, {
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
    required FareInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Money),
          ) as Money;
          result.amount.replace(valueDes);
          break;
        case r'effectiveFrom':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.effectiveFrom = valueDes;
          break;
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.note = valueDes;
          break;
        case r'patternVersionId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.patternVersionId = valueDes;
          break;
        case r'pickupOccurrenceId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.pickupOccurrenceId = valueDes;
          break;
        case r'dropoffOccurrenceId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.dropoffOccurrenceId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  FareInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FareInputBuilder();
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
