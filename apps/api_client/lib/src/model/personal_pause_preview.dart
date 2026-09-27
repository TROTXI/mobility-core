//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/date.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'personal_pause_preview.g.dart';

/// PersonalPausePreview
///
/// Properties:
/// * [startDate] 
/// * [resumeDate] 
/// * [projectedEndsAt] 
/// * [cancelledReservationIds] 
@BuiltValue()
abstract class PersonalPausePreview implements Built<PersonalPausePreview, PersonalPausePreviewBuilder> {
  @BuiltValueField(wireName: r'startDate')
  Date get startDate;

  @BuiltValueField(wireName: r'resumeDate')
  Date get resumeDate;

  @BuiltValueField(wireName: r'projectedEndsAt')
  DateTime get projectedEndsAt;

  @BuiltValueField(wireName: r'cancelledReservationIds')
  BuiltList<String> get cancelledReservationIds;

  PersonalPausePreview._();

  factory PersonalPausePreview([void updates(PersonalPausePreviewBuilder b)]) = _$PersonalPausePreview;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PersonalPausePreviewBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PersonalPausePreview> get serializer => _$PersonalPausePreviewSerializer();
}

class _$PersonalPausePreviewSerializer implements PrimitiveSerializer<PersonalPausePreview> {
  @override
  final Iterable<Type> types = const [PersonalPausePreview, _$PersonalPausePreview];

  @override
  final String wireName = r'PersonalPausePreview';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PersonalPausePreview object, {
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
    yield r'projectedEndsAt';
    yield serializers.serialize(
      object.projectedEndsAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'cancelledReservationIds';
    yield serializers.serialize(
      object.cancelledReservationIds,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PersonalPausePreview object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PersonalPausePreviewBuilder result,
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
        case r'projectedEndsAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.projectedEndsAt = valueDes;
          break;
        case r'cancelledReservationIds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.cancelledReservationIds.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PersonalPausePreview deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PersonalPausePreviewBuilder();
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

