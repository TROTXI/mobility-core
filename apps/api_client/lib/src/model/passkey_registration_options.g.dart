// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'passkey_registration_options.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PasskeyRegistrationOptionsAttestationEnum
    _$passkeyRegistrationOptionsAttestationEnum_direct =
    const PasskeyRegistrationOptionsAttestationEnum._('direct');
const PasskeyRegistrationOptionsAttestationEnum
    _$passkeyRegistrationOptionsAttestationEnum_enterprise =
    const PasskeyRegistrationOptionsAttestationEnum._('enterprise');
const PasskeyRegistrationOptionsAttestationEnum
    _$passkeyRegistrationOptionsAttestationEnum_indirect =
    const PasskeyRegistrationOptionsAttestationEnum._('indirect');
const PasskeyRegistrationOptionsAttestationEnum
    _$passkeyRegistrationOptionsAttestationEnum_none =
    const PasskeyRegistrationOptionsAttestationEnum._('none');

PasskeyRegistrationOptionsAttestationEnum
    _$passkeyRegistrationOptionsAttestationEnumValueOf(String name) {
  switch (name) {
    case 'direct':
      return _$passkeyRegistrationOptionsAttestationEnum_direct;
    case 'enterprise':
      return _$passkeyRegistrationOptionsAttestationEnum_enterprise;
    case 'indirect':
      return _$passkeyRegistrationOptionsAttestationEnum_indirect;
    case 'none':
      return _$passkeyRegistrationOptionsAttestationEnum_none;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PasskeyRegistrationOptionsAttestationEnum>
    _$passkeyRegistrationOptionsAttestationEnumValues = BuiltSet<
        PasskeyRegistrationOptionsAttestationEnum>(const <PasskeyRegistrationOptionsAttestationEnum>[
  _$passkeyRegistrationOptionsAttestationEnum_direct,
  _$passkeyRegistrationOptionsAttestationEnum_enterprise,
  _$passkeyRegistrationOptionsAttestationEnum_indirect,
  _$passkeyRegistrationOptionsAttestationEnum_none,
]);

Serializer<PasskeyRegistrationOptionsAttestationEnum>
    _$passkeyRegistrationOptionsAttestationEnumSerializer =
    _$PasskeyRegistrationOptionsAttestationEnumSerializer();

class _$PasskeyRegistrationOptionsAttestationEnumSerializer
    implements PrimitiveSerializer<PasskeyRegistrationOptionsAttestationEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'direct': 'direct',
    'enterprise': 'enterprise',
    'indirect': 'indirect',
    'none': 'none',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'direct': 'direct',
    'enterprise': 'enterprise',
    'indirect': 'indirect',
    'none': 'none',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PasskeyRegistrationOptionsAttestationEnum
  ];
  @override
  final String wireName = 'PasskeyRegistrationOptionsAttestationEnum';

  @override
  Object serialize(Serializers serializers,
          PasskeyRegistrationOptionsAttestationEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PasskeyRegistrationOptionsAttestationEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PasskeyRegistrationOptionsAttestationEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PasskeyRegistrationOptions extends PasskeyRegistrationOptions {
  @override
  final PasskeyRegistrationOptionsRp rp;
  @override
  final PasskeyRegistrationOptionsUser user;
  @override
  final String challenge;
  @override
  final BuiltList<PasskeyRegistrationOptionsPubKeyCredParamsInner>
      pubKeyCredParams;
  @override
  final num? timeout;
  @override
  final BuiltList<PasskeyAuthenticationOptionsAllowCredentialsInner>?
      excludeCredentials;
  @override
  final PasskeyRegistrationOptionsAuthenticatorSelection?
      authenticatorSelection;
  @override
  final BuiltList<String>? hints;
  @override
  final PasskeyRegistrationOptionsAttestationEnum? attestation;
  @override
  final BuiltList<String>? attestationFormats;
  @override
  final BuiltMap<String, JsonObject?>? extensions;

  factory _$PasskeyRegistrationOptions(
          [void Function(PasskeyRegistrationOptionsBuilder)? updates]) =>
      (PasskeyRegistrationOptionsBuilder()..update(updates))._build();

  _$PasskeyRegistrationOptions._(
      {required this.rp,
      required this.user,
      required this.challenge,
      required this.pubKeyCredParams,
      this.timeout,
      this.excludeCredentials,
      this.authenticatorSelection,
      this.hints,
      this.attestation,
      this.attestationFormats,
      this.extensions})
      : super._();
  @override
  PasskeyRegistrationOptions rebuild(
          void Function(PasskeyRegistrationOptionsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PasskeyRegistrationOptionsBuilder toBuilder() =>
      PasskeyRegistrationOptionsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PasskeyRegistrationOptions &&
        rp == other.rp &&
        user == other.user &&
        challenge == other.challenge &&
        pubKeyCredParams == other.pubKeyCredParams &&
        timeout == other.timeout &&
        excludeCredentials == other.excludeCredentials &&
        authenticatorSelection == other.authenticatorSelection &&
        hints == other.hints &&
        attestation == other.attestation &&
        attestationFormats == other.attestationFormats &&
        extensions == other.extensions;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, rp.hashCode);
    _$hash = $jc(_$hash, user.hashCode);
    _$hash = $jc(_$hash, challenge.hashCode);
    _$hash = $jc(_$hash, pubKeyCredParams.hashCode);
    _$hash = $jc(_$hash, timeout.hashCode);
    _$hash = $jc(_$hash, excludeCredentials.hashCode);
    _$hash = $jc(_$hash, authenticatorSelection.hashCode);
    _$hash = $jc(_$hash, hints.hashCode);
    _$hash = $jc(_$hash, attestation.hashCode);
    _$hash = $jc(_$hash, attestationFormats.hashCode);
    _$hash = $jc(_$hash, extensions.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PasskeyRegistrationOptions')
          ..add('rp', rp)
          ..add('user', user)
          ..add('challenge', challenge)
          ..add('pubKeyCredParams', pubKeyCredParams)
          ..add('timeout', timeout)
          ..add('excludeCredentials', excludeCredentials)
          ..add('authenticatorSelection', authenticatorSelection)
          ..add('hints', hints)
          ..add('attestation', attestation)
          ..add('attestationFormats', attestationFormats)
          ..add('extensions', extensions))
        .toString();
  }
}

class PasskeyRegistrationOptionsBuilder
    implements
        Builder<PasskeyRegistrationOptions, PasskeyRegistrationOptionsBuilder> {
  _$PasskeyRegistrationOptions? _$v;

  PasskeyRegistrationOptionsRpBuilder? _rp;
  PasskeyRegistrationOptionsRpBuilder get rp =>
      _$this._rp ??= PasskeyRegistrationOptionsRpBuilder();
  set rp(PasskeyRegistrationOptionsRpBuilder? rp) => _$this._rp = rp;

  PasskeyRegistrationOptionsUserBuilder? _user;
  PasskeyRegistrationOptionsUserBuilder get user =>
      _$this._user ??= PasskeyRegistrationOptionsUserBuilder();
  set user(PasskeyRegistrationOptionsUserBuilder? user) => _$this._user = user;

  String? _challenge;
  String? get challenge => _$this._challenge;
  set challenge(String? challenge) => _$this._challenge = challenge;

  ListBuilder<PasskeyRegistrationOptionsPubKeyCredParamsInner>?
      _pubKeyCredParams;
  ListBuilder<PasskeyRegistrationOptionsPubKeyCredParamsInner>
      get pubKeyCredParams => _$this._pubKeyCredParams ??=
          ListBuilder<PasskeyRegistrationOptionsPubKeyCredParamsInner>();
  set pubKeyCredParams(
          ListBuilder<PasskeyRegistrationOptionsPubKeyCredParamsInner>?
              pubKeyCredParams) =>
      _$this._pubKeyCredParams = pubKeyCredParams;

  num? _timeout;
  num? get timeout => _$this._timeout;
  set timeout(num? timeout) => _$this._timeout = timeout;

  ListBuilder<PasskeyAuthenticationOptionsAllowCredentialsInner>?
      _excludeCredentials;
  ListBuilder<PasskeyAuthenticationOptionsAllowCredentialsInner>
      get excludeCredentials => _$this._excludeCredentials ??=
          ListBuilder<PasskeyAuthenticationOptionsAllowCredentialsInner>();
  set excludeCredentials(
          ListBuilder<PasskeyAuthenticationOptionsAllowCredentialsInner>?
              excludeCredentials) =>
      _$this._excludeCredentials = excludeCredentials;

  PasskeyRegistrationOptionsAuthenticatorSelectionBuilder?
      _authenticatorSelection;
  PasskeyRegistrationOptionsAuthenticatorSelectionBuilder
      get authenticatorSelection => _$this._authenticatorSelection ??=
          PasskeyRegistrationOptionsAuthenticatorSelectionBuilder();
  set authenticatorSelection(
          PasskeyRegistrationOptionsAuthenticatorSelectionBuilder?
              authenticatorSelection) =>
      _$this._authenticatorSelection = authenticatorSelection;

  ListBuilder<String>? _hints;
  ListBuilder<String> get hints => _$this._hints ??= ListBuilder<String>();
  set hints(ListBuilder<String>? hints) => _$this._hints = hints;

  PasskeyRegistrationOptionsAttestationEnum? _attestation;
  PasskeyRegistrationOptionsAttestationEnum? get attestation =>
      _$this._attestation;
  set attestation(PasskeyRegistrationOptionsAttestationEnum? attestation) =>
      _$this._attestation = attestation;

  ListBuilder<String>? _attestationFormats;
  ListBuilder<String> get attestationFormats =>
      _$this._attestationFormats ??= ListBuilder<String>();
  set attestationFormats(ListBuilder<String>? attestationFormats) =>
      _$this._attestationFormats = attestationFormats;

  MapBuilder<String, JsonObject?>? _extensions;
  MapBuilder<String, JsonObject?> get extensions =>
      _$this._extensions ??= MapBuilder<String, JsonObject?>();
  set extensions(MapBuilder<String, JsonObject?>? extensions) =>
      _$this._extensions = extensions;

  PasskeyRegistrationOptionsBuilder() {
    PasskeyRegistrationOptions._defaults(this);
  }

  PasskeyRegistrationOptionsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _rp = $v.rp.toBuilder();
      _user = $v.user.toBuilder();
      _challenge = $v.challenge;
      _pubKeyCredParams = $v.pubKeyCredParams.toBuilder();
      _timeout = $v.timeout;
      _excludeCredentials = $v.excludeCredentials?.toBuilder();
      _authenticatorSelection = $v.authenticatorSelection?.toBuilder();
      _hints = $v.hints?.toBuilder();
      _attestation = $v.attestation;
      _attestationFormats = $v.attestationFormats?.toBuilder();
      _extensions = $v.extensions?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PasskeyRegistrationOptions other) {
    _$v = other as _$PasskeyRegistrationOptions;
  }

  @override
  void update(void Function(PasskeyRegistrationOptionsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PasskeyRegistrationOptions build() => _build();

  _$PasskeyRegistrationOptions _build() {
    _$PasskeyRegistrationOptions _$result;
    try {
      _$result = _$v ??
          _$PasskeyRegistrationOptions._(
            rp: rp.build(),
            user: user.build(),
            challenge: BuiltValueNullFieldError.checkNotNull(
                challenge, r'PasskeyRegistrationOptions', 'challenge'),
            pubKeyCredParams: pubKeyCredParams.build(),
            timeout: timeout,
            excludeCredentials: _excludeCredentials?.build(),
            authenticatorSelection: _authenticatorSelection?.build(),
            hints: _hints?.build(),
            attestation: attestation,
            attestationFormats: _attestationFormats?.build(),
            extensions: _extensions?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'rp';
        rp.build();
        _$failedField = 'user';
        user.build();

        _$failedField = 'pubKeyCredParams';
        pubKeyCredParams.build();

        _$failedField = 'excludeCredentials';
        _excludeCredentials?.build();
        _$failedField = 'authenticatorSelection';
        _authenticatorSelection?.build();
        _$failedField = 'hints';
        _hints?.build();

        _$failedField = 'attestationFormats';
        _attestationFormats?.build();
        _$failedField = 'extensions';
        _extensions?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PasskeyRegistrationOptions', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
