//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pin_reset_input.g.dart';

/// PinResetInput
///
/// Properties:
/// * [reason]
/// * [emailInstructions]
/// * [smsInstructions]
@BuiltValue()
abstract class PinResetInput
    implements Built<PinResetInput, PinResetInputBuilder> {
  @BuiltValueField(wireName: r'reason')
  String get reason;

  @BuiltValueField(wireName: r'emailInstructions')
  bool? get emailInstructions;

  @BuiltValueField(wireName: r'smsInstructions')
  bool? get smsInstructions;

  PinResetInput._();

  factory PinResetInput([void updates(PinResetInputBuilder b)]) =
      _$PinResetInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PinResetInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PinResetInput> get serializer =>
      _$PinResetInputSerializer();
}

class _$PinResetInputSerializer implements PrimitiveSerializer<PinResetInput> {
  @override
  final Iterable<Type> types = const [PinResetInput, _$PinResetInput];

  @override
  final String wireName = r'PinResetInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PinResetInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'reason';
    yield serializers.serialize(
      object.reason,
      specifiedType: const FullType(String),
    );
    if (object.emailInstructions != null) {
      yield r'emailInstructions';
      yield serializers.serialize(
        object.emailInstructions,
        specifiedType: const FullType(bool),
      );
    }
    if (object.smsInstructions != null) {
      yield r'smsInstructions';
      yield serializers.serialize(
        object.smsInstructions,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PinResetInput object, {
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
    required PinResetInputBuilder result,
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
        case r'emailInstructions':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.emailInstructions = valueDes;
          break;
        case r'smsInstructions':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.smsInstructions = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PinResetInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PinResetInputBuilder();
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
