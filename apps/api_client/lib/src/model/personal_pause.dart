//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/date.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'personal_pause.g.dart';

/// PersonalPause
///
/// Properties:
/// * [id] 
/// * [startDate] 
/// * [resumeDate] 
/// * [status] 
/// * [projectedEndsAt] 
/// * [extensionApplied] 
@BuiltValue()
abstract class PersonalPause implements Built<PersonalPause, PersonalPauseBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'startDate')
  Date get startDate;

  @BuiltValueField(wireName: r'resumeDate')
  Date get resumeDate;

  @BuiltValueField(wireName: r'status')
  PersonalPauseStatusEnum get status;
  // enum statusEnum {  scheduled,  paused,  resumed,  terminated,  };

  @BuiltValueField(wireName: r'projectedEndsAt')
  DateTime? get projectedEndsAt;

  @BuiltValueField(wireName: r'extensionApplied')
  bool get extensionApplied;

  PersonalPause._();

  factory PersonalPause([void updates(PersonalPauseBuilder b)]) = _$PersonalPause;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PersonalPauseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PersonalPause> get serializer => _$PersonalPauseSerializer();
}

class _$PersonalPauseSerializer implements PrimitiveSerializer<PersonalPause> {
  @override
  final Iterable<Type> types = const [PersonalPause, _$PersonalPause];

  @override
  final String wireName = r'PersonalPause';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PersonalPause object, {
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
      specifiedType: const FullType(PersonalPauseStatusEnum),
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
    PersonalPause object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PersonalPauseBuilder result,
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
            specifiedType: const FullType(PersonalPauseStatusEnum),
          ) as PersonalPauseStatusEnum;
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
  PersonalPause deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PersonalPauseBuilder();
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

class PersonalPauseStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'scheduled')
  static const PersonalPauseStatusEnum scheduled = _$personalPauseStatusEnum_scheduled;
  @BuiltValueEnumConst(wireName: r'paused')
  static const PersonalPauseStatusEnum paused = _$personalPauseStatusEnum_paused;
  @BuiltValueEnumConst(wireName: r'resumed')
  static const PersonalPauseStatusEnum resumed = _$personalPauseStatusEnum_resumed;
  @BuiltValueEnumConst(wireName: r'terminated')
  static const PersonalPauseStatusEnum terminated = _$personalPauseStatusEnum_terminated;

  static Serializer<PersonalPauseStatusEnum> get serializer => _$personalPauseStatusEnumSerializer;

  const PersonalPauseStatusEnum._(String name): super(name);

  static BuiltSet<PersonalPauseStatusEnum> get values => _$personalPauseStatusEnumValues;
  static PersonalPauseStatusEnum valueOf(String name) => _$personalPauseStatusEnumValueOf(name);
}

