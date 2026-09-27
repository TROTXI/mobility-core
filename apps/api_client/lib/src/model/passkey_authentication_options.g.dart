// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'passkey_authentication_options.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PasskeyAuthenticationOptionsUserVerificationEnum
    _$passkeyAuthenticationOptionsUserVerificationEnum_discouraged =
    const PasskeyAuthenticationOptionsUserVerificationEnum._('discouraged');
const PasskeyAuthenticationOptionsUserVerificationEnum
    _$passkeyAuthenticationOptionsUserVerificationEnum_preferred =
    const PasskeyAuthenticationOptionsUserVerificationEnum._('preferred');
const PasskeyAuthenticationOptionsUserVerificationEnum
    _$passkeyAuthenticationOptionsUserVerificationEnum_required_ =
    const PasskeyAuthenticationOptionsUserVerificationEnum._('required_');

PasskeyAuthenticationOptionsUserVerificationEnum
    _$passkeyAuthenticationOptionsUserVerificationEnumValueOf(String name) {
  switch (name) {
    case 'discouraged':
      return _$passkeyAuthenticationOptionsUserVerificationEnum_discouraged;
    case 'preferred':
      return _$passkeyAuthenticationOptionsUserVerificationEnum_preferred;
    case 'required_':
      return _$passkeyAuthenticationOptionsUserVerificationEnum_required_;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PasskeyAuthenticationOptionsUserVerificationEnum>
    _$passkeyAuthenticationOptionsUserVerificationEnumValues = BuiltSet<
        PasskeyAuthenticationOptionsUserVerificationEnum>(const <PasskeyAuthenticationOptionsUserVerificationEnum>[
  _$passkeyAuthenticationOptionsUserVerificationEnum_discouraged,
  _$passkeyAuthenticationOptionsUserVerificationEnum_preferred,
  _$passkeyAuthenticationOptionsUserVerificationEnum_required_,
]);

Serializer<PasskeyAuthenticationOptionsUserVerificationEnum>
    _$passkeyAuthenticationOptionsUserVerificationEnumSerializer =
    _$PasskeyAuthenticationOptionsUserVerificationEnumSerializer();

class _$PasskeyAuthenticationOptionsUserVerificationEnumSerializer
    implements
        PrimitiveSerializer<PasskeyAuthenticationOptionsUserVerificationEnum> {
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
    PasskeyAuthenticationOptionsUserVerificationEnum
  ];
  @override
  final String wireName = 'PasskeyAuthenticationOptionsUserVerificationEnum';

  @override
  Object serialize(Serializers serializers,
          PasskeyAuthenticationOptionsUserVerificationEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PasskeyAuthenticationOptionsUserVerificationEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PasskeyAuthenticationOptionsUserVerificationEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PasskeyAuthenticationOptions extends PasskeyAuthenticationOptions {
  @override
  final String challenge;
  @override
  final num? timeout;
  @override
  final String? rpId;
  @override
  final BuiltList<PasskeyAuthenticationOptionsAllowCredentialsInner>?
      allowCredentials;
  @override
  final PasskeyAuthenticationOptionsUserVerificationEnum? userVerification;
  @override
  final BuiltList<String>? hints;
  @override
  final BuiltMap<String, JsonObject?>? extensions;

  factory _$PasskeyAuthenticationOptions(
          [void Function(PasskeyAuthenticationOptionsBuilder)? updates]) =>
      (PasskeyAuthenticationOptionsBuilder()..update(updates))._build();

  _$PasskeyAuthenticationOptions._(
      {required this.challenge,
      this.timeout,
      this.rpId,
      this.allowCredentials,
      this.userVerification,
      this.hints,
      this.extensions})
      : super._();
  @override
  PasskeyAuthenticationOptions rebuild(
          void Function(PasskeyAuthenticationOptionsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PasskeyAuthenticationOptionsBuilder toBuilder() =>
      PasskeyAuthenticationOptionsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PasskeyAuthenticationOptions &&
        challenge == other.challenge &&
        timeout == other.timeout &&
        rpId == other.rpId &&
        allowCredentials == other.allowCredentials &&
        userVerification == other.userVerification &&
        hints == other.hints &&
        extensions == other.extensions;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, challenge.hashCode);
    _$hash = $jc(_$hash, timeout.hashCode);
    _$hash = $jc(_$hash, rpId.hashCode);
    _$hash = $jc(_$hash, allowCredentials.hashCode);
    _$hash = $jc(_$hash, userVerification.hashCode);
    _$hash = $jc(_$hash, hints.hashCode);
    _$hash = $jc(_$hash, extensions.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PasskeyAuthenticationOptions')
          ..add('challenge', challenge)
          ..add('timeout', timeout)
          ..add('rpId', rpId)
          ..add('allowCredentials', allowCredentials)
          ..add('userVerification', userVerification)
          ..add('hints', hints)
          ..add('extensions', extensions))
        .toString();
  }
}

class PasskeyAuthenticationOptionsBuilder
    implements
        Builder<PasskeyAuthenticationOptions,
            PasskeyAuthenticationOptionsBuilder> {
  _$PasskeyAuthenticationOptions? _$v;

  String? _challenge;
  String? get challenge => _$this._challenge;
  set challenge(String? challenge) => _$this._challenge = challenge;

  num? _timeout;
  num? get timeout => _$this._timeout;
  set timeout(num? timeout) => _$this._timeout = timeout;

  String? _rpId;
  String? get rpId => _$this._rpId;
  set rpId(String? rpId) => _$this._rpId = rpId;

  ListBuilder<PasskeyAuthenticationOptionsAllowCredentialsInner>?
      _allowCredentials;
  ListBuilder<PasskeyAuthenticationOptionsAllowCredentialsInner>
      get allowCredentials => _$this._allowCredentials ??=
          ListBuilder<PasskeyAuthenticationOptionsAllowCredentialsInner>();
  set allowCredentials(
          ListBuilder<PasskeyAuthenticationOptionsAllowCredentialsInner>?
              allowCredentials) =>
      _$this._allowCredentials = allowCredentials;

  PasskeyAuthenticationOptionsUserVerificationEnum? _userVerification;
  PasskeyAuthenticationOptionsUserVerificationEnum? get userVerification =>
      _$this._userVerification;
  set userVerification(
          PasskeyAuthenticationOptionsUserVerificationEnum? userVerification) =>
      _$this._userVerification = userVerification;

  ListBuilder<String>? _hints;
  ListBuilder<String> get hints => _$this._hints ??= ListBuilder<String>();
  set hints(ListBuilder<String>? hints) => _$this._hints = hints;

  MapBuilder<String, JsonObject?>? _extensions;
  MapBuilder<String, JsonObject?> get extensions =>
      _$this._extensions ??= MapBuilder<String, JsonObject?>();
  set extensions(MapBuilder<String, JsonObject?>? extensions) =>
      _$this._extensions = extensions;

  PasskeyAuthenticationOptionsBuilder() {
    PasskeyAuthenticationOptions._defaults(this);
  }

  PasskeyAuthenticationOptionsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _challenge = $v.challenge;
      _timeout = $v.timeout;
      _rpId = $v.rpId;
      _allowCredentials = $v.allowCredentials?.toBuilder();
      _userVerification = $v.userVerification;
      _hints = $v.hints?.toBuilder();
      _extensions = $v.extensions?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PasskeyAuthenticationOptions other) {
    _$v = other as _$PasskeyAuthenticationOptions;
  }

  @override
  void update(void Function(PasskeyAuthenticationOptionsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PasskeyAuthenticationOptions build() => _build();

  _$PasskeyAuthenticationOptions _build() {
    _$PasskeyAuthenticationOptions _$result;
    try {
      _$result = _$v ??
          _$PasskeyAuthenticationOptions._(
            challenge: BuiltValueNullFieldError.checkNotNull(
                challenge, r'PasskeyAuthenticationOptions', 'challenge'),
            timeout: timeout,
            rpId: rpId,
            allowCredentials: _allowCredentials?.build(),
            userVerification: userVerification,
            hints: _hints?.build(),
            extensions: _extensions?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'allowCredentials';
        _allowCredentials?.build();

        _$failedField = 'hints';
        _hints?.build();
        _$failedField = 'extensions';
        _extensions?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PasskeyAuthenticationOptions', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
