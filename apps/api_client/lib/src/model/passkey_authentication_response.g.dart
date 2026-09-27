// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'passkey_authentication_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PasskeyAuthenticationResponseAuthenticatorAttachmentEnum
    _$passkeyAuthenticationResponseAuthenticatorAttachmentEnum_crossPlatform =
    const PasskeyAuthenticationResponseAuthenticatorAttachmentEnum._(
        'crossPlatform');
const PasskeyAuthenticationResponseAuthenticatorAttachmentEnum
    _$passkeyAuthenticationResponseAuthenticatorAttachmentEnum_platform =
    const PasskeyAuthenticationResponseAuthenticatorAttachmentEnum._(
        'platform');

PasskeyAuthenticationResponseAuthenticatorAttachmentEnum
    _$passkeyAuthenticationResponseAuthenticatorAttachmentEnumValueOf(
        String name) {
  switch (name) {
    case 'crossPlatform':
      return _$passkeyAuthenticationResponseAuthenticatorAttachmentEnum_crossPlatform;
    case 'platform':
      return _$passkeyAuthenticationResponseAuthenticatorAttachmentEnum_platform;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PasskeyAuthenticationResponseAuthenticatorAttachmentEnum>
    _$passkeyAuthenticationResponseAuthenticatorAttachmentEnumValues = BuiltSet<
        PasskeyAuthenticationResponseAuthenticatorAttachmentEnum>(const <PasskeyAuthenticationResponseAuthenticatorAttachmentEnum>[
  _$passkeyAuthenticationResponseAuthenticatorAttachmentEnum_crossPlatform,
  _$passkeyAuthenticationResponseAuthenticatorAttachmentEnum_platform,
]);

const PasskeyAuthenticationResponseTypeEnum
    _$passkeyAuthenticationResponseTypeEnum_publicKey =
    const PasskeyAuthenticationResponseTypeEnum._('publicKey');

PasskeyAuthenticationResponseTypeEnum
    _$passkeyAuthenticationResponseTypeEnumValueOf(String name) {
  switch (name) {
    case 'publicKey':
      return _$passkeyAuthenticationResponseTypeEnum_publicKey;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PasskeyAuthenticationResponseTypeEnum>
    _$passkeyAuthenticationResponseTypeEnumValues = BuiltSet<
        PasskeyAuthenticationResponseTypeEnum>(const <PasskeyAuthenticationResponseTypeEnum>[
  _$passkeyAuthenticationResponseTypeEnum_publicKey,
]);

Serializer<PasskeyAuthenticationResponseAuthenticatorAttachmentEnum>
    _$passkeyAuthenticationResponseAuthenticatorAttachmentEnumSerializer =
    _$PasskeyAuthenticationResponseAuthenticatorAttachmentEnumSerializer();
Serializer<PasskeyAuthenticationResponseTypeEnum>
    _$passkeyAuthenticationResponseTypeEnumSerializer =
    _$PasskeyAuthenticationResponseTypeEnumSerializer();

class _$PasskeyAuthenticationResponseAuthenticatorAttachmentEnumSerializer
    implements
        PrimitiveSerializer<
            PasskeyAuthenticationResponseAuthenticatorAttachmentEnum> {
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
    PasskeyAuthenticationResponseAuthenticatorAttachmentEnum
  ];
  @override
  final String wireName =
      'PasskeyAuthenticationResponseAuthenticatorAttachmentEnum';

  @override
  Object serialize(Serializers serializers,
          PasskeyAuthenticationResponseAuthenticatorAttachmentEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PasskeyAuthenticationResponseAuthenticatorAttachmentEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PasskeyAuthenticationResponseAuthenticatorAttachmentEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PasskeyAuthenticationResponseTypeEnumSerializer
    implements PrimitiveSerializer<PasskeyAuthenticationResponseTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'publicKey': 'public-key',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'public-key': 'publicKey',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PasskeyAuthenticationResponseTypeEnum
  ];
  @override
  final String wireName = 'PasskeyAuthenticationResponseTypeEnum';

  @override
  Object serialize(
          Serializers serializers, PasskeyAuthenticationResponseTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PasskeyAuthenticationResponseTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PasskeyAuthenticationResponseTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PasskeyAuthenticationResponse extends PasskeyAuthenticationResponse {
  @override
  final String id;
  @override
  final String rawId;
  @override
  final PasskeyAuthenticationResponseAuthenticatorAttachmentEnum?
      authenticatorAttachment;
  @override
  final BuiltMap<String, JsonObject?> clientExtensionResults;
  @override
  final PasskeyAuthenticationResponseTypeEnum type;
  @override
  final PasskeyAuthenticationResponseResponse response;

  factory _$PasskeyAuthenticationResponse(
          [void Function(PasskeyAuthenticationResponseBuilder)? updates]) =>
      (PasskeyAuthenticationResponseBuilder()..update(updates))._build();

  _$PasskeyAuthenticationResponse._(
      {required this.id,
      required this.rawId,
      this.authenticatorAttachment,
      required this.clientExtensionResults,
      required this.type,
      required this.response})
      : super._();
  @override
  PasskeyAuthenticationResponse rebuild(
          void Function(PasskeyAuthenticationResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PasskeyAuthenticationResponseBuilder toBuilder() =>
      PasskeyAuthenticationResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PasskeyAuthenticationResponse &&
        id == other.id &&
        rawId == other.rawId &&
        authenticatorAttachment == other.authenticatorAttachment &&
        clientExtensionResults == other.clientExtensionResults &&
        type == other.type &&
        response == other.response;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, rawId.hashCode);
    _$hash = $jc(_$hash, authenticatorAttachment.hashCode);
    _$hash = $jc(_$hash, clientExtensionResults.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, response.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PasskeyAuthenticationResponse')
          ..add('id', id)
          ..add('rawId', rawId)
          ..add('authenticatorAttachment', authenticatorAttachment)
          ..add('clientExtensionResults', clientExtensionResults)
          ..add('type', type)
          ..add('response', response))
        .toString();
  }
}

class PasskeyAuthenticationResponseBuilder
    implements
        Builder<PasskeyAuthenticationResponse,
            PasskeyAuthenticationResponseBuilder> {
  _$PasskeyAuthenticationResponse? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _rawId;
  String? get rawId => _$this._rawId;
  set rawId(String? rawId) => _$this._rawId = rawId;

  PasskeyAuthenticationResponseAuthenticatorAttachmentEnum?
      _authenticatorAttachment;
  PasskeyAuthenticationResponseAuthenticatorAttachmentEnum?
      get authenticatorAttachment => _$this._authenticatorAttachment;
  set authenticatorAttachment(
          PasskeyAuthenticationResponseAuthenticatorAttachmentEnum?
              authenticatorAttachment) =>
      _$this._authenticatorAttachment = authenticatorAttachment;

  MapBuilder<String, JsonObject?>? _clientExtensionResults;
  MapBuilder<String, JsonObject?> get clientExtensionResults =>
      _$this._clientExtensionResults ??= MapBuilder<String, JsonObject?>();
  set clientExtensionResults(
          MapBuilder<String, JsonObject?>? clientExtensionResults) =>
      _$this._clientExtensionResults = clientExtensionResults;

  PasskeyAuthenticationResponseTypeEnum? _type;
  PasskeyAuthenticationResponseTypeEnum? get type => _$this._type;
  set type(PasskeyAuthenticationResponseTypeEnum? type) => _$this._type = type;

  PasskeyAuthenticationResponseResponseBuilder? _response;
  PasskeyAuthenticationResponseResponseBuilder get response =>
      _$this._response ??= PasskeyAuthenticationResponseResponseBuilder();
  set response(PasskeyAuthenticationResponseResponseBuilder? response) =>
      _$this._response = response;

  PasskeyAuthenticationResponseBuilder() {
    PasskeyAuthenticationResponse._defaults(this);
  }

  PasskeyAuthenticationResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _rawId = $v.rawId;
      _authenticatorAttachment = $v.authenticatorAttachment;
      _clientExtensionResults = $v.clientExtensionResults.toBuilder();
      _type = $v.type;
      _response = $v.response.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PasskeyAuthenticationResponse other) {
    _$v = other as _$PasskeyAuthenticationResponse;
  }

  @override
  void update(void Function(PasskeyAuthenticationResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PasskeyAuthenticationResponse build() => _build();

  _$PasskeyAuthenticationResponse _build() {
    _$PasskeyAuthenticationResponse _$result;
    try {
      _$result = _$v ??
          _$PasskeyAuthenticationResponse._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'PasskeyAuthenticationResponse', 'id'),
            rawId: BuiltValueNullFieldError.checkNotNull(
                rawId, r'PasskeyAuthenticationResponse', 'rawId'),
            authenticatorAttachment: authenticatorAttachment,
            clientExtensionResults: clientExtensionResults.build(),
            type: BuiltValueNullFieldError.checkNotNull(
                type, r'PasskeyAuthenticationResponse', 'type'),
            response: response.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'clientExtensionResults';
        clientExtensionResults.build();

        _$failedField = 'response';
        response.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PasskeyAuthenticationResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
