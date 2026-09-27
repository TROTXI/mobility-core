//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/schedule.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'schedule_response.g.dart';

/// ScheduleResponse
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class ScheduleResponse implements Built<ScheduleResponse, ScheduleResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  Schedule get data;

  ScheduleResponse._();

  factory ScheduleResponse([void updates(ScheduleResponseBuilder b)]) = _$ScheduleResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ScheduleResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ScheduleResponse> get serializer => _$ScheduleResponseSerializer();
}

class _$ScheduleResponseSerializer implements PrimitiveSerializer<ScheduleResponse> {
  @override
  final Iterable<Type> types = const [ScheduleResponse, _$ScheduleResponse];

  @override
  final String wireName = r'ScheduleResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ScheduleResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(Schedule),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ScheduleResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ScheduleResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Schedule),
          ) as Schedule;
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
  ScheduleResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ScheduleResponseBuilder();
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

