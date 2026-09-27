// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'passkey_registration_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PasskeyRegistrationResponseAuthenticatorAttachmentEnum
    _$passkeyRegistrationResponseAuthenticatorAttachmentEnum_crossPlatform =
    const PasskeyRegistrationResponseAuthenticatorAttachmentEnum._(
        'crossPlatform');
const PasskeyRegistrationResponseAuthenticatorAttachmentEnum
    _$passkeyRegistrationResponseAuthenticatorAttachmentEnum_platform =
    const PasskeyRegistrationResponseAuthenticatorAttachmentEnum._('platform');

PasskeyRegistrationResponseAuthenticatorAttachmentEnum
    _$passkeyRegistrationResponseAuthenticatorAttachmentEnumValueOf(
        String name) {
  switch (name) {
    case 'crossPlatform':
      return _$passkeyRegistrationResponseAuthenticatorAttachmentEnum_crossPlatform;
    case 'platform':
      return _$passkeyRegistrationResponseAuthenticatorAttachmentEnum_platform;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PasskeyRegistrationResponseAuthenticatorAttachmentEnum>
    _$passkeyRegistrationResponseAuthenticatorAttachmentEnumValues = BuiltSet<
        PasskeyRegistrationResponseAuthenticatorAttachmentEnum>(const <PasskeyRegistrationResponseAuthenticatorAttachmentEnum>[
  _$passkeyRegistrationResponseAuthenticatorAttachmentEnum_crossPlatform,
  _$passkeyRegistrationResponseAuthenticatorAttachmentEnum_platform,
]);

const PasskeyRegistrationResponseTypeEnum
    _$passkeyRegistrationResponseTypeEnum_publicKey =
    const PasskeyRegistrationResponseTypeEnum._('publicKey');

PasskeyRegistrationResponseTypeEnum
    _$passkeyRegistrationResponseTypeEnumValueOf(String name) {
  switch (name) {
    case 'publicKey':
      return _$passkeyRegistrationResponseTypeEnum_publicKey;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PasskeyRegistrationResponseTypeEnum>
    _$passkeyRegistrationResponseTypeEnumValues = BuiltSet<
        PasskeyRegistrationResponseTypeEnum>(const <PasskeyRegistrationResponseTypeEnum>[
  _$passkeyRegistrationResponseTypeEnum_publicKey,
]);

Serializer<PasskeyRegistrationResponseAuthenticatorAttachmentEnum>
    _$passkeyRegistrationResponseAuthenticatorAttachmentEnumSerializer =
    _$PasskeyRegistrationResponseAuthenticatorAttachmentEnumSerializer();
Serializer<PasskeyRegistrationResponseTypeEnum>
    _$passkeyRegistrationResponseTypeEnumSerializer =
    _$PasskeyRegistrationResponseTypeEnumSerializer();

class _$PasskeyRegistrationResponseAuthenticatorAttachmentEnumSerializer
    implements
        PrimitiveSerializer<
            PasskeyRegistrationResponseAuthenticatorAttachmentEnum> {
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
    PasskeyRegistrationResponseAuthenticatorAttachmentEnum
  ];
  @override
  final String wireName =
      'PasskeyRegistrationResponseAuthenticatorAttachmentEnum';

  @override
  Object serialize(Serializers serializers,
          PasskeyRegistrationResponseAuthenticatorAttachmentEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PasskeyRegistrationResponseAuthenticatorAttachmentEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PasskeyRegistrationResponseAuthenticatorAttachmentEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PasskeyRegistrationResponseTypeEnumSerializer
    implements PrimitiveSerializer<PasskeyRegistrationResponseTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'publicKey': 'public-key',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'public-key': 'publicKey',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PasskeyRegistrationResponseTypeEnum
  ];
  @override
  final String wireName = 'PasskeyRegistrationResponseTypeEnum';

  @override
  Object serialize(
          Serializers serializers, PasskeyRegistrationResponseTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PasskeyRegistrationResponseTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PasskeyRegistrationResponseTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PasskeyRegistrationResponse extends PasskeyRegistrationResponse {
  @override
  final String id;
  @override
  final String rawId;
  @override
  final PasskeyRegistrationResponseAuthenticatorAttachmentEnum?
      authenticatorAttachment;
  @override
  final BuiltMap<String, JsonObject?> clientExtensionResults;
  @override
  final PasskeyRegistrationResponseTypeEnum type;
  @override
  final PasskeyRegistrationResponseResponse response;

  factory _$PasskeyRegistrationResponse(
          [void Function(PasskeyRegistrationResponseBuilder)? updates]) =>
      (PasskeyRegistrationResponseBuilder()..update(updates))._build();

  _$PasskeyRegistrationResponse._(
      {required this.id,
      required this.rawId,
      this.authenticatorAttachment,
      required this.clientExtensionResults,
      required this.type,
      required this.response})
      : super._();
  @override
  PasskeyRegistrationResponse rebuild(
          void Function(PasskeyRegistrationResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PasskeyRegistrationResponseBuilder toBuilder() =>
      PasskeyRegistrationResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PasskeyRegistrationResponse &&
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
    return (newBuiltValueToStringHelper(r'PasskeyRegistrationResponse')
          ..add('id', id)
          ..add('rawId', rawId)
          ..add('authenticatorAttachment', authenticatorAttachment)
          ..add('clientExtensionResults', clientExtensionResults)
          ..add('type', type)
          ..add('response', response))
        .toString();
  }
}

class PasskeyRegistrationResponseBuilder
    implements
        Builder<PasskeyRegistrationResponse,
            PasskeyRegistrationResponseBuilder> {
  _$PasskeyRegistrationResponse? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _rawId;
  String? get rawId => _$this._rawId;
  set rawId(String? rawId) => _$this._rawId = rawId;

  PasskeyRegistrationResponseAuthenticatorAttachmentEnum?
      _authenticatorAttachment;
  PasskeyRegistrationResponseAuthenticatorAttachmentEnum?
      get authenticatorAttachment => _$this._authenticatorAttachment;
  set authenticatorAttachment(
          PasskeyRegistrationResponseAuthenticatorAttachmentEnum?
              authenticatorAttachment) =>
      _$this._authenticatorAttachment = authenticatorAttachment;

  MapBuilder<String, JsonObject?>? _clientExtensionResults;
  MapBuilder<String, JsonObject?> get clientExtensionResults =>
      _$this._clientExtensionResults ??= MapBuilder<String, JsonObject?>();
  set clientExtensionResults(
          MapBuilder<String, JsonObject?>? clientExtensionResults) =>
      _$this._clientExtensionResults = clientExtensionResults;

  PasskeyRegistrationResponseTypeEnum? _type;
  PasskeyRegistrationResponseTypeEnum? get type => _$this._type;
  set type(PasskeyRegistrationResponseTypeEnum? type) => _$this._type = type;

  PasskeyRegistrationResponseResponseBuilder? _response;
  PasskeyRegistrationResponseResponseBuilder get response =>
      _$this._response ??= PasskeyRegistrationResponseResponseBuilder();
  set response(PasskeyRegistrationResponseResponseBuilder? response) =>
      _$this._response = response;

  PasskeyRegistrationResponseBuilder() {
    PasskeyRegistrationResponse._defaults(this);
  }

  PasskeyRegistrationResponseBuilder get _$this {
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
  void replace(PasskeyRegistrationResponse other) {
    _$v = other as _$PasskeyRegistrationResponse;
  }

  @override
  void update(void Function(PasskeyRegistrationResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PasskeyRegistrationResponse build() => _build();

  _$PasskeyRegistrationResponse _build() {
    _$PasskeyRegistrationResponse _$result;
    try {
      _$result = _$v ??
          _$PasskeyRegistrationResponse._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'PasskeyRegistrationResponse', 'id'),
            rawId: BuiltValueNullFieldError.checkNotNull(
                rawId, r'PasskeyRegistrationResponse', 'rawId'),
            authenticatorAttachment: authenticatorAttachment,
            clientExtensionResults: clientExtensionResults.build(),
            type: BuiltValueNullFieldError.checkNotNull(
                type, r'PasskeyRegistrationResponse', 'type'),
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
            r'PasskeyRegistrationResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
