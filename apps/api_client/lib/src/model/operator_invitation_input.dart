//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'operator_invitation_input.g.dart';

/// OperatorInvitationInput
///
/// Properties:
/// * [email]
/// * [name]
@BuiltValue()
abstract class OperatorInvitationInput
    implements Built<OperatorInvitationInput, OperatorInvitationInputBuilder> {
  @BuiltValueField(wireName: r'email')
  String get email;

  @BuiltValueField(wireName: r'name')
  String get name;

  OperatorInvitationInput._();

  factory OperatorInvitationInput(
          [void updates(OperatorInvitationInputBuilder b)]) =
      _$OperatorInvitationInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OperatorInvitationInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OperatorInvitationInput> get serializer =>
      _$OperatorInvitationInputSerializer();
}

class _$OperatorInvitationInputSerializer
    implements PrimitiveSerializer<OperatorInvitationInput> {
  @override
  final Iterable<Type> types = const [
    OperatorInvitationInput,
    _$OperatorInvitationInput
  ];

  @override
  final String wireName = r'OperatorInvitationInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OperatorInvitationInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'email';
    yield serializers.serialize(
      object.email,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OperatorInvitationInput object, {
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
    required OperatorInvitationInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'email':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.email = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OperatorInvitationInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OperatorInvitationInputBuilder();
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
