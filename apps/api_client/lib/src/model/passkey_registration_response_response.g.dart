// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'passkey_registration_response_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PasskeyRegistrationResponseResponse
    extends PasskeyRegistrationResponseResponse {
  @override
  final String clientDataJSON;
  @override
  final String attestationObject;
  @override
  final String? authenticatorData;
  @override
  final BuiltList<String>? transports;
  @override
  final int? publicKeyAlgorithm;
  @override
  final String? publicKey;

  factory _$PasskeyRegistrationResponseResponse(
          [void Function(PasskeyRegistrationResponseResponseBuilder)?
              updates]) =>
      (PasskeyRegistrationResponseResponseBuilder()..update(updates))._build();

  _$PasskeyRegistrationResponseResponse._(
      {required this.clientDataJSON,
      required this.attestationObject,
      this.authenticatorData,
      this.transports,
      this.publicKeyAlgorithm,
      this.publicKey})
      : super._();
  @override
  PasskeyRegistrationResponseResponse rebuild(
          void Function(PasskeyRegistrationResponseResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PasskeyRegistrationResponseResponseBuilder toBuilder() =>
      PasskeyRegistrationResponseResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PasskeyRegistrationResponseResponse &&
        clientDataJSON == other.clientDataJSON &&
        attestationObject == other.attestationObject &&
        authenticatorData == other.authenticatorData &&
        transports == other.transports &&
        publicKeyAlgorithm == other.publicKeyAlgorithm &&
        publicKey == other.publicKey;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, clientDataJSON.hashCode);
    _$hash = $jc(_$hash, attestationObject.hashCode);
    _$hash = $jc(_$hash, authenticatorData.hashCode);
    _$hash = $jc(_$hash, transports.hashCode);
    _$hash = $jc(_$hash, publicKeyAlgorithm.hashCode);
    _$hash = $jc(_$hash, publicKey.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PasskeyRegistrationResponseResponse')
          ..add('clientDataJSON', clientDataJSON)
          ..add('attestationObject', attestationObject)
          ..add('authenticatorData', authenticatorData)
          ..add('transports', transports)
          ..add('publicKeyAlgorithm', publicKeyAlgorithm)
          ..add('publicKey', publicKey))
        .toString();
  }
}

class PasskeyRegistrationResponseResponseBuilder
    implements
        Builder<PasskeyRegistrationResponseResponse,
            PasskeyRegistrationResponseResponseBuilder> {
  _$PasskeyRegistrationResponseResponse? _$v;

  String? _clientDataJSON;
  String? get clientDataJSON => _$this._clientDataJSON;
  set clientDataJSON(String? clientDataJSON) =>
      _$this._clientDataJSON = clientDataJSON;

  String? _attestationObject;
  String? get attestationObject => _$this._attestationObject;
  set attestationObject(String? attestationObject) =>
      _$this._attestationObject = attestationObject;

  String? _authenticatorData;
  String? get authenticatorData => _$this._authenticatorData;
  set authenticatorData(String? authenticatorData) =>
      _$this._authenticatorData = authenticatorData;

  ListBuilder<String>? _transports;
  ListBuilder<String> get transports =>
      _$this._transports ??= ListBuilder<String>();
  set transports(ListBuilder<String>? transports) =>
      _$this._transports = transports;

  int? _publicKeyAlgorithm;
  int? get publicKeyAlgorithm => _$this._publicKeyAlgorithm;
  set publicKeyAlgorithm(int? publicKeyAlgorithm) =>
      _$this._publicKeyAlgorithm = publicKeyAlgorithm;

  String? _publicKey;
  String? get publicKey => _$this._publicKey;
  set publicKey(String? publicKey) => _$this._publicKey = publicKey;

  PasskeyRegistrationResponseResponseBuilder() {
    PasskeyRegistrationResponseResponse._defaults(this);
  }

  PasskeyRegistrationResponseResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _clientDataJSON = $v.clientDataJSON;
      _attestationObject = $v.attestationObject;
      _authenticatorData = $v.authenticatorData;
      _transports = $v.transports?.toBuilder();
      _publicKeyAlgorithm = $v.publicKeyAlgorithm;
      _publicKey = $v.publicKey;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PasskeyRegistrationResponseResponse other) {
    _$v = other as _$PasskeyRegistrationResponseResponse;
  }

  @override
  void update(
      void Function(PasskeyRegistrationResponseResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PasskeyRegistrationResponseResponse build() => _build();

  _$PasskeyRegistrationResponseResponse _build() {
    _$PasskeyRegistrationResponseResponse _$result;
    try {
      _$result = _$v ??
          _$PasskeyRegistrationResponseResponse._(
            clientDataJSON: BuiltValueNullFieldError.checkNotNull(
                clientDataJSON,
                r'PasskeyRegistrationResponseResponse',
                'clientDataJSON'),
            attestationObject: BuiltValueNullFieldError.checkNotNull(
                attestationObject,
                r'PasskeyRegistrationResponseResponse',
                'attestationObject'),
            authenticatorData: authenticatorData,
            transports: _transports?.build(),
            publicKeyAlgorithm: publicKeyAlgorithm,
            publicKey: publicKey,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'transports';
        _transports?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(r'PasskeyRegistrationResponseResponse',
            _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
