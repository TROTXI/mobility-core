//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/optional_personal_pause.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'optional_personal_pause_response.g.dart';

/// OptionalPersonalPauseResponse
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class OptionalPersonalPauseResponse implements Built<OptionalPersonalPauseResponse, OptionalPersonalPauseResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  OptionalPersonalPause? get data;

  OptionalPersonalPauseResponse._();

  factory OptionalPersonalPauseResponse([void updates(OptionalPersonalPauseResponseBuilder b)]) = _$OptionalPersonalPauseResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OptionalPersonalPauseResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OptionalPersonalPauseResponse> get serializer => _$OptionalPersonalPauseResponseSerializer();
}

class _$OptionalPersonalPauseResponseSerializer implements PrimitiveSerializer<OptionalPersonalPauseResponse> {
  @override
  final Iterable<Type> types = const [OptionalPersonalPauseResponse, _$OptionalPersonalPauseResponse];

  @override
  final String wireName = r'OptionalPersonalPauseResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OptionalPersonalPauseResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield object.data == null ? null : serializers.serialize(
      object.data,
      specifiedType: const FullType.nullable(OptionalPersonalPause),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OptionalPersonalPauseResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OptionalPersonalPauseResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(OptionalPersonalPause),
          ) as OptionalPersonalPause?;
          if (valueDes == null) continue;
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
  OptionalPersonalPauseResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OptionalPersonalPauseResponseBuilder();
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

