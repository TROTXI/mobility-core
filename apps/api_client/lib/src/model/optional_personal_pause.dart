//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/date.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'optional_personal_pause.g.dart';

/// OptionalPersonalPause
///
/// Properties:
/// * [id] 
/// * [startDate] 
/// * [resumeDate] 
/// * [status] 
/// * [projectedEndsAt] 
/// * [extensionApplied] 
@BuiltValue()
abstract class OptionalPersonalPause implements Built<OptionalPersonalPause, OptionalPersonalPauseBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'startDate')
  Date get startDate;

  @BuiltValueField(wireName: r'resumeDate')
  Date get resumeDate;

  @BuiltValueField(wireName: r'status')
  OptionalPersonalPauseStatusEnum get status;
  // enum statusEnum {  scheduled,  paused,  resumed,  terminated,  };

  @BuiltValueField(wireName: r'projectedEndsAt')
  DateTime? get projectedEndsAt;

  @BuiltValueField(wireName: r'extensionApplied')
  bool get extensionApplied;

  OptionalPersonalPause._();

  factory OptionalPersonalPause([void updates(OptionalPersonalPauseBuilder b)]) = _$OptionalPersonalPause;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OptionalPersonalPauseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OptionalPersonalPause> get serializer => _$OptionalPersonalPauseSerializer();
}

class _$OptionalPersonalPauseSerializer implements PrimitiveSerializer<OptionalPersonalPause> {
  @override
  final Iterable<Type> types = const [OptionalPersonalPause, _$OptionalPersonalPause];

  @override
  final String wireName = r'OptionalPersonalPause';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OptionalPersonalPause object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'startDate';
    yield serializers.serialize(
      object.startDate,
      specifiedType: const FullType(Date),
    );
    yield r'resumeDate';
    yield serializers.serialize(
      object.resumeDate,
      specifiedType: const FullType(Date),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(OptionalPersonalPauseStatusEnum),
    );
    yield r'projectedEndsAt';
    yield object.projectedEndsAt == null ? null : serializers.serialize(
      object.projectedEndsAt,
      specifiedType: const FullType.nullable(DateTime),
    );
    yield r'extensionApplied';
    yield serializers.serialize(
      object.extensionApplied,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OptionalPersonalPause object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OptionalPersonalPauseBuilder result,
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
        case r'startDate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Date),
          ) as Date;
          result.startDate = valueDes;
          break;
        case r'resumeDate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Date),
          ) as Date;
          result.resumeDate = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OptionalPersonalPauseStatusEnum),
          ) as OptionalPersonalPauseStatusEnum;
          result.status = valueDes;
          break;
        case r'projectedEndsAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.projectedEndsAt = valueDes;
          break;
        case r'extensionApplied':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.extensionApplied = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OptionalPersonalPause deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OptionalPersonalPauseBuilder();
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

class OptionalPersonalPauseStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'scheduled')
  static const OptionalPersonalPauseStatusEnum scheduled = _$optionalPersonalPauseStatusEnum_scheduled;
  @BuiltValueEnumConst(wireName: r'paused')
  static const OptionalPersonalPauseStatusEnum paused = _$optionalPersonalPauseStatusEnum_paused;
  @BuiltValueEnumConst(wireName: r'resumed')
  static const OptionalPersonalPauseStatusEnum resumed = _$optionalPersonalPauseStatusEnum_resumed;
  @BuiltValueEnumConst(wireName: r'terminated')
  static const OptionalPersonalPauseStatusEnum terminated = _$optionalPersonalPauseStatusEnum_terminated;

  static Serializer<OptionalPersonalPauseStatusEnum> get serializer => _$optionalPersonalPauseStatusEnumSerializer;

  const OptionalPersonalPauseStatusEnum._(String name): super(name);

  static BuiltSet<OptionalPersonalPauseStatusEnum> get values => _$optionalPersonalPauseStatusEnumValues;
  static OptionalPersonalPauseStatusEnum valueOf(String name) => _$optionalPersonalPauseStatusEnumValueOf(name);
}

