// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'passkey_authentication_options_allow_credentials_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PasskeyAuthenticationOptionsAllowCredentialsInnerTypeEnum
    _$passkeyAuthenticationOptionsAllowCredentialsInnerTypeEnum_publicKey =
    const PasskeyAuthenticationOptionsAllowCredentialsInnerTypeEnum._(
        'publicKey');

PasskeyAuthenticationOptionsAllowCredentialsInnerTypeEnum
    _$passkeyAuthenticationOptionsAllowCredentialsInnerTypeEnumValueOf(
        String name) {
  switch (name) {
    case 'publicKey':
      return _$passkeyAuthenticationOptionsAllowCredentialsInnerTypeEnum_publicKey;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PasskeyAuthenticationOptionsAllowCredentialsInnerTypeEnum>
    _$passkeyAuthenticationOptionsAllowCredentialsInnerTypeEnumValues =
    BuiltSet<
        PasskeyAuthenticationOptionsAllowCredentialsInnerTypeEnum>(const <PasskeyAuthenticationOptionsAllowCredentialsInnerTypeEnum>[
  _$passkeyAuthenticationOptionsAllowCredentialsInnerTypeEnum_publicKey,
]);

Serializer<PasskeyAuthenticationOptionsAllowCredentialsInnerTypeEnum>
    _$passkeyAuthenticationOptionsAllowCredentialsInnerTypeEnumSerializer =
    _$PasskeyAuthenticationOptionsAllowCredentialsInnerTypeEnumSerializer();

class _$PasskeyAuthenticationOptionsAllowCredentialsInnerTypeEnumSerializer
    implements
        PrimitiveSerializer<
            PasskeyAuthenticationOptionsAllowCredentialsInnerTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'publicKey': 'public-key',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'public-key': 'publicKey',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PasskeyAuthenticationOptionsAllowCredentialsInnerTypeEnum
  ];
  @override
  final String wireName =
      'PasskeyAuthenticationOptionsAllowCredentialsInnerTypeEnum';

  @override
  Object serialize(Serializers serializers,
          PasskeyAuthenticationOptionsAllowCredentialsInnerTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PasskeyAuthenticationOptionsAllowCredentialsInnerTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PasskeyAuthenticationOptionsAllowCredentialsInnerTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PasskeyAuthenticationOptionsAllowCredentialsInner
    extends PasskeyAuthenticationOptionsAllowCredentialsInner {
  @override
  final String id;
  @override
  final PasskeyAuthenticationOptionsAllowCredentialsInnerTypeEnum type;
  @override
  final BuiltList<String>? transports;

  factory _$PasskeyAuthenticationOptionsAllowCredentialsInner(
          [void Function(
                  PasskeyAuthenticationOptionsAllowCredentialsInnerBuilder)?
              updates]) =>
      (PasskeyAuthenticationOptionsAllowCredentialsInnerBuilder()
            ..update(updates))
          ._build();

  _$PasskeyAuthenticationOptionsAllowCredentialsInner._(
      {required this.id, required this.type, this.transports})
      : super._();
  @override
  PasskeyAuthenticationOptionsAllowCredentialsInner rebuild(
          void Function(
                  PasskeyAuthenticationOptionsAllowCredentialsInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PasskeyAuthenticationOptionsAllowCredentialsInnerBuilder toBuilder() =>
      PasskeyAuthenticationOptionsAllowCredentialsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PasskeyAuthenticationOptionsAllowCredentialsInner &&
        id == other.id &&
        type == other.type &&
        transports == other.transports;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, transports.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PasskeyAuthenticationOptionsAllowCredentialsInner')
          ..add('id', id)
          ..add('type', type)
          ..add('transports', transports))
        .toString();
  }
}

class PasskeyAuthenticationOptionsAllowCredentialsInnerBuilder
    implements
        Builder<PasskeyAuthenticationOptionsAllowCredentialsInner,
            PasskeyAuthenticationOptionsAllowCredentialsInnerBuilder> {
  _$PasskeyAuthenticationOptionsAllowCredentialsInner? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  PasskeyAuthenticationOptionsAllowCredentialsInnerTypeEnum? _type;
  PasskeyAuthenticationOptionsAllowCredentialsInnerTypeEnum? get type =>
      _$this._type;
  set type(PasskeyAuthenticationOptionsAllowCredentialsInnerTypeEnum? type) =>
      _$this._type = type;

  ListBuilder<String>? _transports;
  ListBuilder<String> get transports =>
      _$this._transports ??= ListBuilder<String>();
  set transports(ListBuilder<String>? transports) =>
      _$this._transports = transports;

  PasskeyAuthenticationOptionsAllowCredentialsInnerBuilder() {
    PasskeyAuthenticationOptionsAllowCredentialsInner._defaults(this);
  }

  PasskeyAuthenticationOptionsAllowCredentialsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _type = $v.type;
      _transports = $v.transports?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PasskeyAuthenticationOptionsAllowCredentialsInner other) {
    _$v = other as _$PasskeyAuthenticationOptionsAllowCredentialsInner;
  }

  @override
  void update(
      void Function(PasskeyAuthenticationOptionsAllowCredentialsInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PasskeyAuthenticationOptionsAllowCredentialsInner build() => _build();

  _$PasskeyAuthenticationOptionsAllowCredentialsInner _build() {
    _$PasskeyAuthenticationOptionsAllowCredentialsInner _$result;
    try {
      _$result = _$v ??
          _$PasskeyAuthenticationOptionsAllowCredentialsInner._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'PasskeyAuthenticationOptionsAllowCredentialsInner', 'id'),
            type: BuiltValueNullFieldError.checkNotNull(type,
                r'PasskeyAuthenticationOptionsAllowCredentialsInner', 'type'),
            transports: _transports?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'transports';
        _transports?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PasskeyAuthenticationOptionsAllowCredentialsInner',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
