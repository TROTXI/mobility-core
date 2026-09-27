//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'trip_edit.g.dart';

/// TripEdit
///
/// Properties:
/// * [scheduledAt] 
@BuiltValue()
abstract class TripEdit implements Built<TripEdit, TripEditBuilder> {
  @BuiltValueField(wireName: r'scheduledAt')
  DateTime get scheduledAt;

  TripEdit._();

  factory TripEdit([void updates(TripEditBuilder b)]) = _$TripEdit;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TripEditBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TripEdit> get serializer => _$TripEditSerializer();
}

class _$TripEditSerializer implements PrimitiveSerializer<TripEdit> {
  @override
  final Iterable<Type> types = const [TripEdit, _$TripEdit];

  @override
  final String wireName = r'TripEdit';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TripEdit object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'scheduledAt';
    yield serializers.serialize(
      object.scheduledAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TripEdit object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TripEditBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'scheduledAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.scheduledAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TripEdit deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TripEditBuilder();
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

