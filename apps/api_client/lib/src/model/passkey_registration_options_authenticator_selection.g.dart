// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'passkey_registration_options_authenticator_selection.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PasskeyRegistrationOptionsAuthenticatorSelectionAuthenticatorAttachmentEnum
    _$passkeyRegistrationOptionsAuthenticatorSelectionAuthenticatorAttachmentEnum_crossPlatform =
    const PasskeyRegistrationOptionsAuthenticatorSelectionAuthenticatorAttachmentEnum
        ._('crossPlatform');
const PasskeyRegistrationOptionsAuthenticatorSelectionAuthenticatorAttachmentEnum
    _$passkeyRegistrationOptionsAuthenticatorSelectionAuthenticatorAttachmentEnum_platform =
    const PasskeyRegistrationOptionsAuthenticatorSelectionAuthenticatorAttachmentEnum
        ._('platform');

PasskeyRegistrationOptionsAuthenticatorSelectionAuthenticatorAttachmentEnum
    _$passkeyRegistrationOptionsAuthenticatorSelectionAuthenticatorAttachmentEnumValueOf(
        String name) {
  switch (name) {
    case 'crossPlatform':
      return _$passkeyRegistrationOptionsAuthenticatorSelectionAuthenticatorAttachmentEnum_crossPlatform;
    case 'platform':
      return _$passkeyRegistrationOptionsAuthenticatorSelectionAuthenticatorAttachmentEnum_platform;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<
        PasskeyRegistrationOptionsAuthenticatorSelectionAuthenticatorAttachmentEnum>
    _$passkeyRegistrationOptionsAuthenticatorSelectionAuthenticatorAttachmentEnumValues =
    BuiltSet<
        PasskeyRegistrationOptionsAuthenticatorSelectionAuthenticatorAttachmentEnum>(const <PasskeyRegistrationOptionsAuthenticatorSelectionAuthenticatorAttachmentEnum>[
  _$passkeyRegistrationOptionsAuthenticatorSelectionAuthenticatorAttachmentEnum_crossPlatform,
  _$passkeyRegistrationOptionsAuthenticatorSelectionAuthenticatorAttachmentEnum_platform,
]);

const PasskeyRegistrationOptionsAuthenticatorSelectionResidentKeyEnum
    _$passkeyRegistrationOptionsAuthenticatorSelectionResidentKeyEnum_discouraged =
    const PasskeyRegistrationOptionsAuthenticatorSelectionResidentKeyEnum._(
        'discouraged');
const PasskeyRegistrationOptionsAuthenticatorSelectionResidentKeyEnum
    _$passkeyRegistrationOptionsAuthenticatorSelectionResidentKeyEnum_preferred =
    const PasskeyRegistrationOptionsAuthenticatorSelectionResidentKeyEnum._(
        'preferred');
const PasskeyRegistrationOptionsAuthenticatorSelectionResidentKeyEnum
    _$passkeyRegistrationOptionsAuthenticatorSelectionResidentKeyEnum_required_ =
    const PasskeyRegistrationOptionsAuthenticatorSelectionResidentKeyEnum._(
        'required_');

PasskeyRegistrationOptionsAuthenticatorSelectionResidentKeyEnum
    _$passkeyRegistrationOptionsAuthenticatorSelectionResidentKeyEnumValueOf(
        String name) {
  switch (name) {
    case 'discouraged':
      return _$passkeyRegistrationOptionsAuthenticatorSelectionResidentKeyEnum_discouraged;
    case 'preferred':
      return _$passkeyRegistrationOptionsAuthenticatorSelectionResidentKeyEnum_preferred;
    case 'required_':
      return _$passkeyRegistrationOptionsAuthenticatorSelectionResidentKeyEnum_required_;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PasskeyRegistrationOptionsAuthenticatorSelectionResidentKeyEnum>
    _$passkeyRegistrationOptionsAuthenticatorSelectionResidentKeyEnumValues =
    BuiltSet<
        PasskeyRegistrationOptionsAuthenticatorSelectionResidentKeyEnum>(const <PasskeyRegistrationOptionsAuthenticatorSelectionResidentKeyEnum>[
  _$passkeyRegistrationOptionsAuthenticatorSelectionResidentKeyEnum_discouraged,
  _$passkeyRegistrationOptionsAuthenticatorSelectionResidentKeyEnum_preferred,
  _$passkeyRegistrationOptionsAuthenticatorSelectionResidentKeyEnum_required_,
]);

const PasskeyRegistrationOptionsAuthenticatorSelectionUserVerificationEnum
    _$passkeyRegistrationOptionsAuthenticatorSelectionUserVerificationEnum_discouraged =
    const PasskeyRegistrationOptionsAuthenticatorSelectionUserVerificationEnum
        ._('discouraged');
const PasskeyRegistrationOptionsAuthenticatorSelectionUserVerificationEnum
    _$passkeyRegistrationOptionsAuthenticatorSelectionUserVerificationEnum_preferred =
    const PasskeyRegistrationOptionsAuthenticatorSelectionUserVerificationEnum
        ._('preferred');
const PasskeyRegistrationOptionsAuthenticatorSelectionUserVerificationEnum
    _$passkeyRegistrationOptionsAuthenticatorSelectionUserVerificationEnum_required_ =
    const PasskeyRegistrationOptionsAuthenticatorSelectionUserVerificationEnum
        ._('required_');

PasskeyRegistrationOptionsAuthenticatorSelectionUserVerificationEnum
    _$passkeyRegistrationOptionsAuthenticatorSelectionUserVerificationEnumValueOf(
        String name) {
  switch (name) {
    case 'discouraged':
      return _$passkeyRegistrationOptionsAuthenticatorSelectionUserVerificationEnum_discouraged;
    case 'preferred':
      return _$passkeyRegistrationOptionsAuthenticatorSelectionUserVerificationEnum_preferred;
    case 'required_':
      return _$passkeyRegistrationOptionsAuthenticatorSelectionUserVerificationEnum_required_;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<
        PasskeyRegistrationOptionsAuthenticatorSelectionUserVerificationEnum>
    _$passkeyRegistrationOptionsAuthenticatorSelectionUserVerificationEnumValues =
    BuiltSet<
        PasskeyRegistrationOptionsAuthenticatorSelectionUserVerificationEnum>(const <PasskeyRegistrationOptionsAuthenticatorSelectionUserVerificationEnum>[
  _$passkeyRegistrationOptionsAuthenticatorSelectionUserVerificationEnum_discouraged,
  _$passkeyRegistrationOptionsAuthenticatorSelectionUserVerificationEnum_preferred,
  _$passkeyRegistrationOptionsAuthenticatorSelectionUserVerificationEnum_required_,
]);

Serializer<
        PasskeyRegistrationOptionsAuthenticatorSelectionAuthenticatorAttachmentEnum>
    _$passkeyRegistrationOptionsAuthenticatorSelectionAuthenticatorAttachmentEnumSerializer =
    _$PasskeyRegistrationOptionsAuthenticatorSelectionAuthenticatorAttachmentEnumSerializer();
Serializer<PasskeyRegistrationOptionsAuthenticatorSelectionResidentKeyEnum>
    _$passkeyRegistrationOptionsAuthenticatorSelectionResidentKeyEnumSerializer =
    _$PasskeyRegistrationOptionsAuthenticatorSelectionResidentKeyEnumSerializer();
Serializer<PasskeyRegistrationOptionsAuthenticatorSelectionUserVerificationEnum>
    _$passkeyRegistrationOptionsAuthenticatorSelectionUserVerificationEnumSerializer =
    _$PasskeyRegistrationOptionsAuthenticatorSelectionUserVerificationEnumSerializer();

class _$PasskeyRegistrationOptionsAuthenticatorSelectionAuthenticatorAttachmentEnumSerializer
    implements
        PrimitiveSerializer<
            PasskeyRegistrationOptionsAuthenticatorSelectionAuthenticatorAttachmentEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'crossPlatform': 'cross-platform',
    'platform': 'platform',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'cross-platform': 'crossPlatform',
    'platform': 'platform',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PasskeyRegistrationOptionsAuthenticatorSelectionAuthenticatorAttachmentEnum
  ];
  @override
  final String wireName =
      'PasskeyRegistrationOptionsAuthenticatorSelectionAuthenticatorAttachmentEnum';

  @override
  Object serialize(
          Serializers serializers,
          PasskeyRegistrationOptionsAuthenticatorSelectionAuthenticatorAttachmentEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PasskeyRegistrationOptionsAuthenticatorSelectionAuthenticatorAttachmentEnum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          PasskeyRegistrationOptionsAuthenticatorSelectionAuthenticatorAttachmentEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$PasskeyRegistrationOptionsAuthenticatorSelectionResidentKeyEnumSerializer
    implements
        PrimitiveSerializer<
            PasskeyRegistrationOptionsAuthenticatorSelectionResidentKeyEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'discouraged': 'discouraged',
    'preferred': 'preferred',
    'required_': 'required',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'discouraged': 'discouraged',
    'preferred': 'preferred',
    'required': 'required_',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PasskeyRegistrationOptionsAuthenticatorSelectionResidentKeyEnum
  ];
  @override
  final String wireName =
      'PasskeyRegistrationOptionsAuthenticatorSelectionResidentKeyEnum';

  @override
  Object serialize(
          Serializers serializers,
          PasskeyRegistrationOptionsAuthenticatorSelectionResidentKeyEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PasskeyRegistrationOptionsAuthenticatorSelectionResidentKeyEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PasskeyRegistrationOptionsAuthenticatorSelectionResidentKeyEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PasskeyRegistrationOptionsAuthenticatorSelectionUserVerificationEnumSerializer
    implements
        PrimitiveSerializer<
            PasskeyRegistrationOptionsAuthenticatorSelectionUserVerificationEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'discouraged': 'discouraged',
    'preferred': 'preferred',
    'required_': 'required',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'discouraged': 'discouraged',
    'preferred': 'preferred',
    'required': 'required_',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PasskeyRegistrationOptionsAuthenticatorSelectionUserVerificationEnum
  ];
  @override
  final String wireName =
      'PasskeyRegistrationOptionsAuthenticatorSelectionUserVerificationEnum';

  @override
  Object serialize(
          Serializers serializers,
          PasskeyRegistrationOptionsAuthenticatorSelectionUserVerificationEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PasskeyRegistrationOptionsAuthenticatorSelectionUserVerificationEnum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          PasskeyRegistrationOptionsAuthenticatorSelectionUserVerificationEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$PasskeyRegistrationOptionsAuthenticatorSelection
    extends PasskeyRegistrationOptionsAuthenticatorSelection {
  @override
  final PasskeyRegistrationOptionsAuthenticatorSelectionAuthenticatorAttachmentEnum?
      authenticatorAttachment;
  @override
  final bool? requireResidentKey;
  @override
  final PasskeyRegistrationOptionsAuthenticatorSelectionResidentKeyEnum?
      residentKey;
  @override
  final PasskeyRegistrationOptionsAuthenticatorSelectionUserVerificationEnum?
      userVerification;

  factory _$PasskeyRegistrationOptionsAuthenticatorSelection(
          [void Function(
                  PasskeyRegistrationOptionsAuthenticatorSelectionBuilder)?
              updates]) =>
      (PasskeyRegistrationOptionsAuthenticatorSelectionBuilder()
            ..update(updates))
          ._build();

  _$PasskeyRegistrationOptionsAuthenticatorSelection._(
      {this.authenticatorAttachment,
      this.requireResidentKey,
      this.residentKey,
      this.userVerification})
      : super._();
  @override
  PasskeyRegistrationOptionsAuthenticatorSelection rebuild(
          void Function(PasskeyRegistrationOptionsAuthenticatorSelectionBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PasskeyRegistrationOptionsAuthenticatorSelectionBuilder toBuilder() =>
      PasskeyRegistrationOptionsAuthenticatorSelectionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PasskeyRegistrationOptionsAuthenticatorSelection &&
        authenticatorAttachment == other.authenticatorAttachment &&
        requireResidentKey == other.requireResidentKey &&
        residentKey == other.residentKey &&
        userVerification == other.userVerification;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, authenticatorAttachment.hashCode);
    _$hash = $jc(_$hash, requireResidentKey.hashCode);
    _$hash = $jc(_$hash, residentKey.hashCode);
    _$hash = $jc(_$hash, userVerification.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PasskeyRegistrationOptionsAuthenticatorSelection')
          ..add('authenticatorAttachment', authenticatorAttachment)
          ..add('requireResidentKey', requireResidentKey)
          ..add('residentKey', residentKey)
          ..add('userVerification', userVerification))
        .toString();
  }
}

class PasskeyRegistrationOptionsAuthenticatorSelectionBuilder
    implements
        Builder<PasskeyRegistrationOptionsAuthenticatorSelection,
            PasskeyRegistrationOptionsAuthenticatorSelectionBuilder> {
  _$PasskeyRegistrationOptionsAuthenticatorSelection? _$v;

  PasskeyRegistrationOptionsAuthenticatorSelectionAuthenticatorAttachmentEnum?
      _authenticatorAttachment;
  PasskeyRegistrationOptionsAuthenticatorSelectionAuthenticatorAttachmentEnum?
      get authenticatorAttachment => _$this._authenticatorAttachment;
  set authenticatorAttachment(
          PasskeyRegistrationOptionsAuthenticatorSelectionAuthenticatorAttachmentEnum?
              authenticatorAttachment) =>
      _$this._authenticatorAttachment = authenticatorAttachment;

  bool? _requireResidentKey;
  bool? get requireResidentKey => _$this._requireResidentKey;
  set requireResidentKey(bool? requireResidentKey) =>
      _$this._requireResidentKey = requireResidentKey;

  PasskeyRegistrationOptionsAuthenticatorSelectionResidentKeyEnum? _residentKey;
  PasskeyRegistrationOptionsAuthenticatorSelectionResidentKeyEnum?
      get residentKey => _$this._residentKey;
  set residentKey(
          PasskeyRegistrationOptionsAuthenticatorSelectionResidentKeyEnum?
              residentKey) =>
      _$this._residentKey = residentKey;

  PasskeyRegistrationOptionsAuthenticatorSelectionUserVerificationEnum?
      _userVerification;
  PasskeyRegistrationOptionsAuthenticatorSelectionUserVerificationEnum?
      get userVerification => _$this._userVerification;
  set userVerification(
          PasskeyRegistrationOptionsAuthenticatorSelectionUserVerificationEnum?
              userVerification) =>
      _$this._userVerification = userVerification;

  PasskeyRegistrationOptionsAuthenticatorSelectionBuilder() {
    PasskeyRegistrationOptionsAuthenticatorSelection._defaults(this);
  }

  PasskeyRegistrationOptionsAuthenticatorSelectionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _authenticatorAttachment = $v.authenticatorAttachment;
      _requireResidentKey = $v.requireResidentKey;
      _residentKey = $v.residentKey;
      _userVerification = $v.userVerification;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PasskeyRegistrationOptionsAuthenticatorSelection other) {
    _$v = other as _$PasskeyRegistrationOptionsAuthenticatorSelection;
  }

  @override
  void update(
      void Function(PasskeyRegistrationOptionsAuthenticatorSelectionBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PasskeyRegistrationOptionsAuthenticatorSelection build() => _build();

  _$PasskeyRegistrationOptionsAuthenticatorSelection _build() {
    final _$result = _$v ??
        _$PasskeyRegistrationOptionsAuthenticatorSelection._(
          authenticatorAttachment: authenticatorAttachment,
          requireResidentKey: requireResidentKey,
          residentKey: residentKey,
          userVerification: userVerification,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
