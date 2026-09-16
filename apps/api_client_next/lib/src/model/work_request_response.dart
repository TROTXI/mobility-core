//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client_next/src/model/work_request.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'work_request_response.g.dart';

/// WorkRequestResponse
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class WorkRequestResponse implements Built<WorkRequestResponse, WorkRequestResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  WorkRequest get data;

  WorkRequestResponse._();

  factory WorkRequestResponse([void updates(WorkRequestResponseBuilder b)]) = _$WorkRequestResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WorkRequestResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<WorkRequestResponse> get serializer => _$WorkRequestResponseSerializer();
}

class _$WorkRequestResponseSerializer implements PrimitiveSerializer<WorkRequestResponse> {
  @override
  final Iterable<Type> types = const [WorkRequestResponse, _$WorkRequestResponse];

  @override
  final String wireName = r'WorkRequestResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    WorkRequestResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(WorkRequest),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    WorkRequestResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required WorkRequestResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(WorkRequest),
          ) as WorkRequest;
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
  WorkRequestResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WorkRequestResponseBuilder();
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

