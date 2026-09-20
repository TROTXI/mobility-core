//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/date.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'personal_pause_input.g.dart';

/// PersonalPauseInput
///
/// Properties:
/// * [startDate] 
/// * [resumeDate] 
@BuiltValue()
abstract class PersonalPauseInput implements Built<PersonalPauseInput, PersonalPauseInputBuilder> {
  @BuiltValueField(wireName: r'startDate')
  Date get startDate;

  @BuiltValueField(wireName: r'resumeDate')
  Date get resumeDate;

  PersonalPauseInput._();

  factory PersonalPauseInput([void updates(PersonalPauseInputBuilder b)]) = _$PersonalPauseInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PersonalPauseInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PersonalPauseInput> get serializer => _$PersonalPauseInputSerializer();
}

class _$PersonalPauseInputSerializer implements PrimitiveSerializer<PersonalPauseInput> {
  @override
  final Iterable<Type> types = const [PersonalPauseInput, _$PersonalPauseInput];

  @override
  final String wireName = r'PersonalPauseInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PersonalPauseInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
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
  }

  @override
  Object serialize(
    Serializers serializers,
    PersonalPauseInput object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PersonalPauseInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PersonalPauseInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PersonalPauseInputBuilder();
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

