//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'operator_command_result.g.dart';

/// OperatorCommandResult
///
/// Properties:
/// * [id]
@BuiltValue()
abstract class OperatorCommandResult
    implements Built<OperatorCommandResult, OperatorCommandResultBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  OperatorCommandResult._();

  factory OperatorCommandResult(
      [void updates(OperatorCommandResultBuilder b)]) = _$OperatorCommandResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OperatorCommandResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OperatorCommandResult> get serializer =>
      _$OperatorCommandResultSerializer();
}

class _$OperatorCommandResultSerializer
    implements PrimitiveSerializer<OperatorCommandResult> {
  @override
  final Iterable<Type> types = const [
    OperatorCommandResult,
    _$OperatorCommandResult
  ];

  @override
  final String wireName = r'OperatorCommandResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OperatorCommandResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OperatorCommandResult object, {
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
    required OperatorCommandResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OperatorCommandResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OperatorCommandResultBuilder();
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
