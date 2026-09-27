//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/date.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'personal_resume_input.g.dart';

/// PersonalResumeInput
///
/// Properties:
<<<<<<< HEAD
/// * [resumeDate] 
@BuiltValue()
abstract class PersonalResumeInput implements Built<PersonalResumeInput, PersonalResumeInputBuilder> {
=======
/// * [resumeDate]
@BuiltValue()
abstract class PersonalResumeInput
    implements Built<PersonalResumeInput, PersonalResumeInputBuilder> {
>>>>>>> origin/main
  @BuiltValueField(wireName: r'resumeDate')
  Date get resumeDate;

  PersonalResumeInput._();

<<<<<<< HEAD
  factory PersonalResumeInput([void updates(PersonalResumeInputBuilder b)]) = _$PersonalResumeInput;
=======
  factory PersonalResumeInput([void updates(PersonalResumeInputBuilder b)]) =
      _$PersonalResumeInput;
>>>>>>> origin/main

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PersonalResumeInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
<<<<<<< HEAD
  static Serializer<PersonalResumeInput> get serializer => _$PersonalResumeInputSerializer();
}

class _$PersonalResumeInputSerializer implements PrimitiveSerializer<PersonalResumeInput> {
  @override
  final Iterable<Type> types = const [PersonalResumeInput, _$PersonalResumeInput];
=======
  static Serializer<PersonalResumeInput> get serializer =>
      _$PersonalResumeInputSerializer();
}

class _$PersonalResumeInputSerializer
    implements PrimitiveSerializer<PersonalResumeInput> {
  @override
  final Iterable<Type> types = const [
    PersonalResumeInput,
    _$PersonalResumeInput
  ];
>>>>>>> origin/main

  @override
  final String wireName = r'PersonalResumeInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PersonalResumeInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'resumeDate';
    yield serializers.serialize(
      object.resumeDate,
      specifiedType: const FullType(Date),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PersonalResumeInput object, {
    FullType specifiedType = FullType.unspecified,
  }) {
<<<<<<< HEAD
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
=======
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
>>>>>>> origin/main
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PersonalResumeInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
  PersonalResumeInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PersonalResumeInputBuilder();
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
<<<<<<< HEAD

=======
>>>>>>> origin/main
