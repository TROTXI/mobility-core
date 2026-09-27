//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/trace_hold.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'trace_hold_response.g.dart';

/// TraceHoldResponse
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class TraceHoldResponse implements Built<TraceHoldResponse, TraceHoldResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  TraceHold get data;

  TraceHoldResponse._();

  factory TraceHoldResponse([void updates(TraceHoldResponseBuilder b)]) = _$TraceHoldResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TraceHoldResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TraceHoldResponse> get serializer => _$TraceHoldResponseSerializer();
}

class _$TraceHoldResponseSerializer implements PrimitiveSerializer<TraceHoldResponse> {
  @override
  final Iterable<Type> types = const [TraceHoldResponse, _$TraceHoldResponse];

  @override
  final String wireName = r'TraceHoldResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TraceHoldResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(TraceHold),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TraceHoldResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TraceHoldResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(TraceHold),
          ) as TraceHold;
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
  TraceHoldResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TraceHoldResponseBuilder();
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

