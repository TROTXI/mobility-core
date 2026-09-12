//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_learn_routes_post200_response_routes_inner_segments_learned.g.dart';

/// AdminLearnRoutesPost200ResponseRoutesInnerSegmentsLearned
///
/// Properties:
/// * [morning] 
/// * [evening] 
@BuiltValue()
abstract class AdminLearnRoutesPost200ResponseRoutesInnerSegmentsLearned implements Built<AdminLearnRoutesPost200ResponseRoutesInnerSegmentsLearned, AdminLearnRoutesPost200ResponseRoutesInnerSegmentsLearnedBuilder> {
  @BuiltValueField(wireName: r'morning')
  int get morning;

  @BuiltValueField(wireName: r'evening')
  int get evening;

  AdminLearnRoutesPost200ResponseRoutesInnerSegmentsLearned._();

  factory AdminLearnRoutesPost200ResponseRoutesInnerSegmentsLearned([void updates(AdminLearnRoutesPost200ResponseRoutesInnerSegmentsLearnedBuilder b)]) = _$AdminLearnRoutesPost200ResponseRoutesInnerSegmentsLearned;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminLearnRoutesPost200ResponseRoutesInnerSegmentsLearnedBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminLearnRoutesPost200ResponseRoutesInnerSegmentsLearned> get serializer => _$AdminLearnRoutesPost200ResponseRoutesInnerSegmentsLearnedSerializer();
}

class _$AdminLearnRoutesPost200ResponseRoutesInnerSegmentsLearnedSerializer implements PrimitiveSerializer<AdminLearnRoutesPost200ResponseRoutesInnerSegmentsLearned> {
  @override
  final Iterable<Type> types = const [AdminLearnRoutesPost200ResponseRoutesInnerSegmentsLearned, _$AdminLearnRoutesPost200ResponseRoutesInnerSegmentsLearned];

  @override
  final String wireName = r'AdminLearnRoutesPost200ResponseRoutesInnerSegmentsLearned';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminLearnRoutesPost200ResponseRoutesInnerSegmentsLearned object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'morning';
    yield serializers.serialize(
      object.morning,
      specifiedType: const FullType(int),
    );
    yield r'evening';
    yield serializers.serialize(
      object.evening,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminLearnRoutesPost200ResponseRoutesInnerSegmentsLearned object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminLearnRoutesPost200ResponseRoutesInnerSegmentsLearnedBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'morning':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.morning = valueDes;
          break;
        case r'evening':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.evening = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminLearnRoutesPost200ResponseRoutesInnerSegmentsLearned deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminLearnRoutesPost200ResponseRoutesInnerSegmentsLearnedBuilder();
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

