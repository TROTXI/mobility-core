//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'reason_input.g.dart';

/// ReasonInput
///
/// Properties:
/// * [reason] 
@BuiltValue()
abstract class ReasonInput implements Built<ReasonInput, ReasonInputBuilder> {
  @BuiltValueField(wireName: r'reason')
  String get reason;

  ReasonInput._();

  factory ReasonInput([void updates(ReasonInputBuilder b)]) = _$ReasonInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReasonInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReasonInput> get serializer => _$ReasonInputSerializer();
}

class _$ReasonInputSerializer implements PrimitiveSerializer<ReasonInput> {
  @override
  final Iterable<Type> types = const [ReasonInput, _$ReasonInput];

  @override
  final String wireName = r'ReasonInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReasonInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'reason';
    yield serializers.serialize(
      object.reason,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ReasonInput object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ReasonInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.reason = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ReasonInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReasonInputBuilder();
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

