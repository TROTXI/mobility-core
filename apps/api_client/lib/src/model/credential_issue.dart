//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'credential_issue.g.dart';

/// CredentialIssue
///
/// Properties:
/// * [code]
/// * [emailInstructions]
/// * [smsInstructions]
@BuiltValue()
abstract class CredentialIssue
    implements Built<CredentialIssue, CredentialIssueBuilder> {
  @BuiltValueField(wireName: r'code')
  String? get code;

  @BuiltValueField(wireName: r'emailInstructions')
  bool? get emailInstructions;

  @BuiltValueField(wireName: r'smsInstructions')
  bool? get smsInstructions;

  CredentialIssue._();

  factory CredentialIssue([void updates(CredentialIssueBuilder b)]) =
      _$CredentialIssue;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CredentialIssueBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CredentialIssue> get serializer =>
      _$CredentialIssueSerializer();
}

class _$CredentialIssueSerializer
    implements PrimitiveSerializer<CredentialIssue> {
  @override
  final Iterable<Type> types = const [CredentialIssue, _$CredentialIssue];

  @override
  final String wireName = r'CredentialIssue';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CredentialIssue object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.code != null) {
      yield r'code';
      yield serializers.serialize(
        object.code,
        specifiedType: const FullType(String),
      );
    }
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
    CredentialIssue object, {
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
    required CredentialIssueBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.code = valueDes;
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
  CredentialIssue deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CredentialIssueBuilder();
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
