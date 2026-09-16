//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client_next/src/model/stop_occurrence.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pattern_version.g.dart';

/// PatternVersion
///
/// Properties:
/// * [id] 
/// * [patternId] 
/// * [revision] 
/// * [state] 
/// * [effectiveFrom] 
/// * [effectiveTo] 
/// * [stops] 
/// * [geometryId] 
/// * [editToken] 
/// * [createdAt] 
/// * [updatedAt] 
/// * [version] 
@BuiltValue()
abstract class PatternVersion implements Built<PatternVersion, PatternVersionBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'patternId')
  String get patternId;

  @BuiltValueField(wireName: r'revision')
  int get revision;

  @BuiltValueField(wireName: r'state')
  PatternVersionStateEnum get state;
  // enum stateEnum {  draft,  published,  retired,  };

  @BuiltValueField(wireName: r'effectiveFrom')
  DateTime? get effectiveFrom;

  @BuiltValueField(wireName: r'effectiveTo')
  DateTime? get effectiveTo;

  @BuiltValueField(wireName: r'stops')
  BuiltList<StopOccurrence> get stops;

  @BuiltValueField(wireName: r'geometryId')
  String? get geometryId;

  @BuiltValueField(wireName: r'editToken')
  String get editToken;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updatedAt')
  DateTime get updatedAt;

  @BuiltValueField(wireName: r'version')
  int get version;

  PatternVersion._();

  factory PatternVersion([void updates(PatternVersionBuilder b)]) = _$PatternVersion;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PatternVersionBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PatternVersion> get serializer => _$PatternVersionSerializer();
}

class _$PatternVersionSerializer implements PrimitiveSerializer<PatternVersion> {
  @override
  final Iterable<Type> types = const [PatternVersion, _$PatternVersion];

  @override
  final String wireName = r'PatternVersion';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PatternVersion object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'patternId';
    yield serializers.serialize(
      object.patternId,
      specifiedType: const FullType(String),
    );
    yield r'revision';
    yield serializers.serialize(
      object.revision,
      specifiedType: const FullType(int),
    );
    yield r'state';
    yield serializers.serialize(
      object.state,
      specifiedType: const FullType(PatternVersionStateEnum),
    );
    yield r'effectiveFrom';
    yield object.effectiveFrom == null ? null : serializers.serialize(
      object.effectiveFrom,
      specifiedType: const FullType.nullable(DateTime),
    );
    yield r'effectiveTo';
    yield object.effectiveTo == null ? null : serializers.serialize(
      object.effectiveTo,
      specifiedType: const FullType.nullable(DateTime),
    );
    yield r'stops';
    yield serializers.serialize(
      object.stops,
      specifiedType: const FullType(BuiltList, [FullType(StopOccurrence)]),
    );
    yield r'geometryId';
    yield object.geometryId == null ? null : serializers.serialize(
      object.geometryId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'editToken';
    yield serializers.serialize(
      object.editToken,
      specifiedType: const FullType(String),
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
    PatternVersion object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PatternVersionBuilder result,
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
        case r'patternId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.patternId = valueDes;
          break;
        case r'revision':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.revision = valueDes;
          break;
        case r'state':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PatternVersionStateEnum),
          ) as PatternVersionStateEnum;
          result.state = valueDes;
          break;
        case r'effectiveFrom':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.effectiveFrom = valueDes;
          break;
        case r'effectiveTo':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.effectiveTo = valueDes;
          break;
        case r'stops':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(StopOccurrence)]),
          ) as BuiltList<StopOccurrence>;
          result.stops.replace(valueDes);
          break;
        case r'geometryId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.geometryId = valueDes;
          break;
        case r'editToken':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.editToken = valueDes;
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
  PatternVersion deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PatternVersionBuilder();
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

class PatternVersionStateEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'draft')
  static const PatternVersionStateEnum draft = _$patternVersionStateEnum_draft;
  @BuiltValueEnumConst(wireName: r'published')
  static const PatternVersionStateEnum published = _$patternVersionStateEnum_published;
  @BuiltValueEnumConst(wireName: r'retired')
  static const PatternVersionStateEnum retired = _$patternVersionStateEnum_retired;

  static Serializer<PatternVersionStateEnum> get serializer => _$patternVersionStateEnumSerializer;

  const PatternVersionStateEnum._(String name): super(name);

  static BuiltSet<PatternVersionStateEnum> get values => _$patternVersionStateEnumValues;
  static PatternVersionStateEnum valueOf(String name) => _$patternVersionStateEnumValueOf(name);
}

