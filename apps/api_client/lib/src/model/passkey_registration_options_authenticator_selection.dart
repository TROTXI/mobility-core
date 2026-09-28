//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'passkey_registration_options_authenticator_selection.g.dart';

/// PasskeyRegistrationOptionsAuthenticatorSelection
///
/// Properties:
/// * [authenticatorAttachment]
/// * [requireResidentKey]
/// * [residentKey]
/// * [userVerification]
@BuiltValue()
abstract class PasskeyRegistrationOptionsAuthenticatorSelection
    implements
        Built<PasskeyRegistrationOptionsAuthenticatorSelection,
            PasskeyRegistrationOptionsAuthenticatorSelectionBuilder> {
  @BuiltValueField(wireName: r'authenticatorAttachment')
  PasskeyRegistrationOptionsAuthenticatorSelectionAuthenticatorAttachmentEnum?
      get authenticatorAttachment;
  // enum authenticatorAttachmentEnum {  cross-platform,  platform,  };

  @BuiltValueField(wireName: r'requireResidentKey')
  bool? get requireResidentKey;

  @BuiltValueField(wireName: r'residentKey')
  PasskeyRegistrationOptionsAuthenticatorSelectionResidentKeyEnum?
      get residentKey;
  // enum residentKeyEnum {  discouraged,  preferred,  required,  };

  @BuiltValueField(wireName: r'userVerification')
  PasskeyRegistrationOptionsAuthenticatorSelectionUserVerificationEnum?
      get userVerification;
  // enum userVerificationEnum {  discouraged,  preferred,  required,  };

  PasskeyRegistrationOptionsAuthenticatorSelection._();

  factory PasskeyRegistrationOptionsAuthenticatorSelection(
          [void updates(
              PasskeyRegistrationOptionsAuthenticatorSelectionBuilder b)]) =
      _$PasskeyRegistrationOptionsAuthenticatorSelection;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          PasskeyRegistrationOptionsAuthenticatorSelectionBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PasskeyRegistrationOptionsAuthenticatorSelection>
      get serializer =>
          _$PasskeyRegistrationOptionsAuthenticatorSelectionSerializer();
}

class _$PasskeyRegistrationOptionsAuthenticatorSelectionSerializer
    implements
        PrimitiveSerializer<PasskeyRegistrationOptionsAuthenticatorSelection> {
  @override
  final Iterable<Type> types = const [
    PasskeyRegistrationOptionsAuthenticatorSelection,
    _$PasskeyRegistrationOptionsAuthenticatorSelection
  ];

  @override
  final String wireName = r'PasskeyRegistrationOptionsAuthenticatorSelection';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PasskeyRegistrationOptionsAuthenticatorSelection object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.authenticatorAttachment != null) {
      yield r'authenticatorAttachment';
      yield serializers.serialize(
        object.authenticatorAttachment,
        specifiedType: const FullType(
            PasskeyRegistrationOptionsAuthenticatorSelectionAuthenticatorAttachmentEnum),
      );
    }
    if (object.requireResidentKey != null) {
      yield r'requireResidentKey';
      yield serializers.serialize(
        object.requireResidentKey,
        specifiedType: const FullType(bool),
      );
    }
    if (object.residentKey != null) {
      yield r'residentKey';
      yield serializers.serialize(
        object.residentKey,
        specifiedType: const FullType(
            PasskeyRegistrationOptionsAuthenticatorSelectionResidentKeyEnum),
      );
    }
    if (object.userVerification != null) {
      yield r'userVerification';
      yield serializers.serialize(
        object.userVerification,
        specifiedType: const FullType(
            PasskeyRegistrationOptionsAuthenticatorSelectionUserVerificationEnum),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PasskeyRegistrationOptionsAuthenticatorSelection object, {
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
    required PasskeyRegistrationOptionsAuthenticatorSelectionBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'authenticatorAttachment':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                PasskeyRegistrationOptionsAuthenticatorSelectionAuthenticatorAttachmentEnum),
          ) as PasskeyRegistrationOptionsAuthenticatorSelectionAuthenticatorAttachmentEnum;
          result.authenticatorAttachment = valueDes;
          break;
        case r'requireResidentKey':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.requireResidentKey = valueDes;
          break;
        case r'residentKey':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                PasskeyRegistrationOptionsAuthenticatorSelectionResidentKeyEnum),
          ) as PasskeyRegistrationOptionsAuthenticatorSelectionResidentKeyEnum;
          result.residentKey = valueDes;
          break;
        case r'userVerification':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                PasskeyRegistrationOptionsAuthenticatorSelectionUserVerificationEnum),
          ) as PasskeyRegistrationOptionsAuthenticatorSelectionUserVerificationEnum;
          result.userVerification = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PasskeyRegistrationOptionsAuthenticatorSelection deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PasskeyRegistrationOptionsAuthenticatorSelectionBuilder();
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

class PasskeyRegistrationOptionsAuthenticatorSelectionAuthenticatorAttachmentEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'cross-platform')
  static const PasskeyRegistrationOptionsAuthenticatorSelectionAuthenticatorAttachmentEnum
      crossPlatform =
      _$passkeyRegistrationOptionsAuthenticatorSelectionAuthenticatorAttachmentEnum_crossPlatform;
  @BuiltValueEnumConst(wireName: r'platform')
  static const PasskeyRegistrationOptionsAuthenticatorSelectionAuthenticatorAttachmentEnum
      platform =
      _$passkeyRegistrationOptionsAuthenticatorSelectionAuthenticatorAttachmentEnum_platform;

  static Serializer<
          PasskeyRegistrationOptionsAuthenticatorSelectionAuthenticatorAttachmentEnum>
      get serializer =>
          _$passkeyRegistrationOptionsAuthenticatorSelectionAuthenticatorAttachmentEnumSerializer;

  const PasskeyRegistrationOptionsAuthenticatorSelectionAuthenticatorAttachmentEnum._(
      String name)
      : super(name);

  static BuiltSet<
          PasskeyRegistrationOptionsAuthenticatorSelectionAuthenticatorAttachmentEnum>
      get values =>
          _$passkeyRegistrationOptionsAuthenticatorSelectionAuthenticatorAttachmentEnumValues;
  static PasskeyRegistrationOptionsAuthenticatorSelectionAuthenticatorAttachmentEnum
      valueOf(String name) =>
          _$passkeyRegistrationOptionsAuthenticatorSelectionAuthenticatorAttachmentEnumValueOf(
              name);
}

class PasskeyRegistrationOptionsAuthenticatorSelectionResidentKeyEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'discouraged')
  static const PasskeyRegistrationOptionsAuthenticatorSelectionResidentKeyEnum
      discouraged =
      _$passkeyRegistrationOptionsAuthenticatorSelectionResidentKeyEnum_discouraged;
  @BuiltValueEnumConst(wireName: r'preferred')
  static const PasskeyRegistrationOptionsAuthenticatorSelectionResidentKeyEnum
      preferred =
      _$passkeyRegistrationOptionsAuthenticatorSelectionResidentKeyEnum_preferred;
  @BuiltValueEnumConst(wireName: r'required')
  static const PasskeyRegistrationOptionsAuthenticatorSelectionResidentKeyEnum
      required_ =
      _$passkeyRegistrationOptionsAuthenticatorSelectionResidentKeyEnum_required_;

  static Serializer<
          PasskeyRegistrationOptionsAuthenticatorSelectionResidentKeyEnum>
      get serializer =>
          _$passkeyRegistrationOptionsAuthenticatorSelectionResidentKeyEnumSerializer;

  const PasskeyRegistrationOptionsAuthenticatorSelectionResidentKeyEnum._(
      String name)
      : super(name);

  static BuiltSet<
          PasskeyRegistrationOptionsAuthenticatorSelectionResidentKeyEnum>
      get values =>
          _$passkeyRegistrationOptionsAuthenticatorSelectionResidentKeyEnumValues;
  static PasskeyRegistrationOptionsAuthenticatorSelectionResidentKeyEnum valueOf(
          String name) =>
      _$passkeyRegistrationOptionsAuthenticatorSelectionResidentKeyEnumValueOf(
          name);
}

class PasskeyRegistrationOptionsAuthenticatorSelectionUserVerificationEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'discouraged')
  static const PasskeyRegistrationOptionsAuthenticatorSelectionUserVerificationEnum
      discouraged =
      _$passkeyRegistrationOptionsAuthenticatorSelectionUserVerificationEnum_discouraged;
  @BuiltValueEnumConst(wireName: r'preferred')
  static const PasskeyRegistrationOptionsAuthenticatorSelectionUserVerificationEnum
      preferred =
      _$passkeyRegistrationOptionsAuthenticatorSelectionUserVerificationEnum_preferred;
  @BuiltValueEnumConst(wireName: r'required')
  static const PasskeyRegistrationOptionsAuthenticatorSelectionUserVerificationEnum
      required_ =
      _$passkeyRegistrationOptionsAuthenticatorSelectionUserVerificationEnum_required_;

  static Serializer<
          PasskeyRegistrationOptionsAuthenticatorSelectionUserVerificationEnum>
      get serializer =>
          _$passkeyRegistrationOptionsAuthenticatorSelectionUserVerificationEnumSerializer;

  const PasskeyRegistrationOptionsAuthenticatorSelectionUserVerificationEnum._(
      String name)
      : super(name);

  static BuiltSet<
          PasskeyRegistrationOptionsAuthenticatorSelectionUserVerificationEnum>
      get values =>
          _$passkeyRegistrationOptionsAuthenticatorSelectionUserVerificationEnumValues;
  static PasskeyRegistrationOptionsAuthenticatorSelectionUserVerificationEnum
      valueOf(String name) =>
          _$passkeyRegistrationOptionsAuthenticatorSelectionUserVerificationEnumValueOf(
              name);
}
