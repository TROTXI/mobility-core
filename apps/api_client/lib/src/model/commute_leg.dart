//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'commute_leg.g.dart';

/// CommuteLeg
///
/// Properties:
/// * [direction] 
/// * [scheduleId] 
/// * [patternVersionId] 
/// * [pickupOccurrenceId] 
/// * [dropoffOccurrenceId] 
@BuiltValue()
abstract class CommuteLeg implements Built<CommuteLeg, CommuteLegBuilder> {
  @BuiltValueField(wireName: r'direction')
  CommuteLegDirectionEnum get direction;
  // enum directionEnum {  outbound,  return,  };

  @BuiltValueField(wireName: r'scheduleId')
  String get scheduleId;

  @BuiltValueField(wireName: r'patternVersionId')
  String get patternVersionId;

  @BuiltValueField(wireName: r'pickupOccurrenceId')
  String get pickupOccurrenceId;

  @BuiltValueField(wireName: r'dropoffOccurrenceId')
  String get dropoffOccurrenceId;

  CommuteLeg._();

  factory CommuteLeg([void updates(CommuteLegBuilder b)]) = _$CommuteLeg;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CommuteLegBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CommuteLeg> get serializer => _$CommuteLegSerializer();
}

class _$CommuteLegSerializer implements PrimitiveSerializer<CommuteLeg> {
  @override
  final Iterable<Type> types = const [CommuteLeg, _$CommuteLeg];

  @override
  final String wireName = r'CommuteLeg';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CommuteLeg object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'direction';
    yield serializers.serialize(
      object.direction,
      specifiedType: const FullType(CommuteLegDirectionEnum),
    );
    yield r'scheduleId';
    yield serializers.serialize(
      object.scheduleId,
      specifiedType: const FullType(String),
    );
    yield r'patternVersionId';
    yield serializers.serialize(
      object.patternVersionId,
      specifiedType: const FullType(String),
    );
    yield r'pickupOccurrenceId';
    yield serializers.serialize(
      object.pickupOccurrenceId,
      specifiedType: const FullType(String),
    );
    yield r'dropoffOccurrenceId';
    yield serializers.serialize(
      object.dropoffOccurrenceId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CommuteLeg object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CommuteLegBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'direction':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CommuteLegDirectionEnum),
          ) as CommuteLegDirectionEnum;
          result.direction = valueDes;
          break;
        case r'scheduleId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.scheduleId = valueDes;
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
  CommuteLeg deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CommuteLegBuilder();
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

class CommuteLegDirectionEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'outbound')
  static const CommuteLegDirectionEnum outbound = _$commuteLegDirectionEnum_outbound;
  @BuiltValueEnumConst(wireName: r'return')
  static const CommuteLegDirectionEnum return_ = _$commuteLegDirectionEnum_return_;

  static Serializer<CommuteLegDirectionEnum> get serializer => _$commuteLegDirectionEnumSerializer;

  const CommuteLegDirectionEnum._(String name): super(name);

  static BuiltSet<CommuteLegDirectionEnum> get values => _$commuteLegDirectionEnumValues;
  static CommuteLegDirectionEnum valueOf(String name) => _$commuteLegDirectionEnumValueOf(name);
}

