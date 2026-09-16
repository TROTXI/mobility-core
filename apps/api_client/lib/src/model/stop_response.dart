//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/stop.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'stop_response.g.dart';

/// StopResponse
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class StopResponse implements Built<StopResponse, StopResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  Stop get data;

  StopResponse._();

  factory StopResponse([void updates(StopResponseBuilder b)]) = _$StopResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(StopResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<StopResponse> get serializer => _$StopResponseSerializer();
}

class _$StopResponseSerializer implements PrimitiveSerializer<StopResponse> {
  @override
  final Iterable<Type> types = const [StopResponse, _$StopResponse];

  @override
  final String wireName = r'StopResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    StopResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(Stop),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    StopResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required StopResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Stop),
          ) as Stop;
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
  StopResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = StopResponseBuilder();
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

