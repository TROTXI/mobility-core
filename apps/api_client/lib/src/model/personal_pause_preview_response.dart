//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/personal_pause_preview.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'personal_pause_preview_response.g.dart';

/// PersonalPausePreviewResponse
///
/// Properties:
<<<<<<< HEAD
/// * [data] 
@BuiltValue()
abstract class PersonalPausePreviewResponse implements Built<PersonalPausePreviewResponse, PersonalPausePreviewResponseBuilder> {
=======
/// * [data]
@BuiltValue()
abstract class PersonalPausePreviewResponse
    implements
        Built<PersonalPausePreviewResponse,
            PersonalPausePreviewResponseBuilder> {
>>>>>>> origin/main
  @BuiltValueField(wireName: r'data')
  PersonalPausePreview get data;

  PersonalPausePreviewResponse._();

<<<<<<< HEAD
  factory PersonalPausePreviewResponse([void updates(PersonalPausePreviewResponseBuilder b)]) = _$PersonalPausePreviewResponse;
=======
  factory PersonalPausePreviewResponse(
          [void updates(PersonalPausePreviewResponseBuilder b)]) =
      _$PersonalPausePreviewResponse;
>>>>>>> origin/main

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PersonalPausePreviewResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
<<<<<<< HEAD
  static Serializer<PersonalPausePreviewResponse> get serializer => _$PersonalPausePreviewResponseSerializer();
}

class _$PersonalPausePreviewResponseSerializer implements PrimitiveSerializer<PersonalPausePreviewResponse> {
  @override
  final Iterable<Type> types = const [PersonalPausePreviewResponse, _$PersonalPausePreviewResponse];
=======
  static Serializer<PersonalPausePreviewResponse> get serializer =>
      _$PersonalPausePreviewResponseSerializer();
}

class _$PersonalPausePreviewResponseSerializer
    implements PrimitiveSerializer<PersonalPausePreviewResponse> {
  @override
  final Iterable<Type> types = const [
    PersonalPausePreviewResponse,
    _$PersonalPausePreviewResponse
  ];
>>>>>>> origin/main

  @override
  final String wireName = r'PersonalPausePreviewResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PersonalPausePreviewResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(PersonalPausePreview),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PersonalPausePreviewResponse object, {
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
    required PersonalPausePreviewResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PersonalPausePreview),
          ) as PersonalPausePreview;
          result.data.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PersonalPausePreviewResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PersonalPausePreviewResponseBuilder();
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
