//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/operator_command_result.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'operator_command_result_response.g.dart';

/// OperatorCommandResultResponse
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class OperatorCommandResultResponse
    implements
        Built<OperatorCommandResultResponse,
            OperatorCommandResultResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  OperatorCommandResult get data;

  OperatorCommandResultResponse._();

  factory OperatorCommandResultResponse(
          [void updates(OperatorCommandResultResponseBuilder b)]) =
      _$OperatorCommandResultResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OperatorCommandResultResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OperatorCommandResultResponse> get serializer =>
      _$OperatorCommandResultResponseSerializer();
}

class _$OperatorCommandResultResponseSerializer
    implements PrimitiveSerializer<OperatorCommandResultResponse> {
  @override
  final Iterable<Type> types = const [
    OperatorCommandResultResponse,
    _$OperatorCommandResultResponse
  ];

  @override
  final String wireName = r'OperatorCommandResultResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OperatorCommandResultResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(OperatorCommandResult),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OperatorCommandResultResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OperatorCommandResultResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OperatorCommandResult),
          ) as OperatorCommandResult;
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
  OperatorCommandResultResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OperatorCommandResultResponseBuilder();
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
