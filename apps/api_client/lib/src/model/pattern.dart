//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pattern.g.dart';

/// Pattern
///
/// Properties:
/// * [id] 
/// * [routeId] 
/// * [direction] 
/// * [publishedVersionId] 
/// * [createdAt] 
/// * [updatedAt] 
/// * [version] 
@BuiltValue()
abstract class Pattern implements Built<Pattern, PatternBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'routeId')
  String get routeId;

  @BuiltValueField(wireName: r'direction')
  PatternDirectionEnum get direction;
  // enum directionEnum {  outbound,  return,  };

  @BuiltValueField(wireName: r'publishedVersionId')
  String? get publishedVersionId;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updatedAt')
  DateTime get updatedAt;

  @BuiltValueField(wireName: r'version')
  int get version;

  Pattern._();

  factory Pattern([void updates(PatternBuilder b)]) = _$Pattern;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PatternBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Pattern> get serializer => _$PatternSerializer();
}

class _$PatternSerializer implements PrimitiveSerializer<Pattern> {
  @override
  final Iterable<Type> types = const [Pattern, _$Pattern];

  @override
  final String wireName = r'Pattern';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Pattern object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'routeId';
    yield serializers.serialize(
      object.routeId,
      specifiedType: const FullType(String),
    );
    yield r'direction';
    yield serializers.serialize(
      object.direction,
      specifiedType: const FullType(PatternDirectionEnum),
    );
    yield r'publishedVersionId';
    yield object.publishedVersionId == null ? null : serializers.serialize(
      object.publishedVersionId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'updatedAt';
    yield serializers.serialize(
      object.updatedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    Pattern object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PatternBuilder result,
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
            specifiedType: const FullType(PatternDirectionEnum),
          ) as PatternDirectionEnum;
          result.direction = valueDes;
          break;
        case r'publishedVersionId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.publishedVersionId = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'updatedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.updatedAt = valueDes;
          break;
        case r'version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.version = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Pattern deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PatternBuilder();
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

class PatternDirectionEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'outbound')
  static const PatternDirectionEnum outbound = _$patternDirectionEnum_outbound;
  @BuiltValueEnumConst(wireName: r'return')
  static const PatternDirectionEnum return_ = _$patternDirectionEnum_return_;

  static Serializer<PatternDirectionEnum> get serializer => _$patternDirectionEnumSerializer;

  const PatternDirectionEnum._(String name): super(name);

  static BuiltSet<PatternDirectionEnum> get values => _$patternDirectionEnumValues;
  static PatternDirectionEnum valueOf(String name) => _$patternDirectionEnumValueOf(name);
}

