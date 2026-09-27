//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pattern_input.g.dart';

/// PatternInput
///
/// Properties:
/// * [routeId] 
/// * [direction] 
@BuiltValue()
abstract class PatternInput implements Built<PatternInput, PatternInputBuilder> {
  @BuiltValueField(wireName: r'routeId')
  String get routeId;

  @BuiltValueField(wireName: r'direction')
  PatternInputDirectionEnum get direction;
  // enum directionEnum {  outbound,  return,  };

  PatternInput._();

  factory PatternInput([void updates(PatternInputBuilder b)]) = _$PatternInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PatternInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PatternInput> get serializer => _$PatternInputSerializer();
}

class _$PatternInputSerializer implements PrimitiveSerializer<PatternInput> {
  @override
  final Iterable<Type> types = const [PatternInput, _$PatternInput];

  @override
  final String wireName = r'PatternInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PatternInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'routeId';
    yield serializers.serialize(
      object.routeId,
      specifiedType: const FullType(String),
    );
    yield r'direction';
    yield serializers.serialize(
      object.direction,
      specifiedType: const FullType(PatternInputDirectionEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PatternInput object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PatternInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'routeId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.routeId = valueDes;
          break;
        case r'direction':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PatternInputDirectionEnum),
          ) as PatternInputDirectionEnum;
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
  PatternInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PatternInputBuilder();
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

class PatternInputDirectionEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'outbound')
  static const PatternInputDirectionEnum outbound = _$patternInputDirectionEnum_outbound;
  @BuiltValueEnumConst(wireName: r'return')
  static const PatternInputDirectionEnum return_ = _$patternInputDirectionEnum_return_;

  static Serializer<PatternInputDirectionEnum> get serializer => _$patternInputDirectionEnumSerializer;

  const PatternInputDirectionEnum._(String name): super(name);

  static BuiltSet<PatternInputDirectionEnum> get values => _$patternInputDirectionEnumValues;
  static PatternInputDirectionEnum valueOf(String name) => _$patternInputDirectionEnumValueOf(name);
}

