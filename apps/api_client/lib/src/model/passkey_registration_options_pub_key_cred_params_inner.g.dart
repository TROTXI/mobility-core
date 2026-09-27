// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'passkey_registration_options_pub_key_cred_params_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PasskeyRegistrationOptionsPubKeyCredParamsInnerTypeEnum
    _$passkeyRegistrationOptionsPubKeyCredParamsInnerTypeEnum_publicKey =
    const PasskeyRegistrationOptionsPubKeyCredParamsInnerTypeEnum._(
        'publicKey');

PasskeyRegistrationOptionsPubKeyCredParamsInnerTypeEnum
    _$passkeyRegistrationOptionsPubKeyCredParamsInnerTypeEnumValueOf(
        String name) {
  switch (name) {
    case 'publicKey':
      return _$passkeyRegistrationOptionsPubKeyCredParamsInnerTypeEnum_publicKey;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PasskeyRegistrationOptionsPubKeyCredParamsInnerTypeEnum>
    _$passkeyRegistrationOptionsPubKeyCredParamsInnerTypeEnumValues = BuiltSet<
        PasskeyRegistrationOptionsPubKeyCredParamsInnerTypeEnum>(const <PasskeyRegistrationOptionsPubKeyCredParamsInnerTypeEnum>[
  _$passkeyRegistrationOptionsPubKeyCredParamsInnerTypeEnum_publicKey,
]);

Serializer<PasskeyRegistrationOptionsPubKeyCredParamsInnerTypeEnum>
    _$passkeyRegistrationOptionsPubKeyCredParamsInnerTypeEnumSerializer =
    _$PasskeyRegistrationOptionsPubKeyCredParamsInnerTypeEnumSerializer();

class _$PasskeyRegistrationOptionsPubKeyCredParamsInnerTypeEnumSerializer
    implements
        PrimitiveSerializer<
            PasskeyRegistrationOptionsPubKeyCredParamsInnerTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'publicKey': 'public-key',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'public-key': 'publicKey',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PasskeyRegistrationOptionsPubKeyCredParamsInnerTypeEnum
  ];
  @override
  final String wireName =
      'PasskeyRegistrationOptionsPubKeyCredParamsInnerTypeEnum';

  @override
  Object serialize(Serializers serializers,
          PasskeyRegistrationOptionsPubKeyCredParamsInnerTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PasskeyRegistrationOptionsPubKeyCredParamsInnerTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PasskeyRegistrationOptionsPubKeyCredParamsInnerTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PasskeyRegistrationOptionsPubKeyCredParamsInner
    extends PasskeyRegistrationOptionsPubKeyCredParamsInner {
  @override
  final PasskeyRegistrationOptionsPubKeyCredParamsInnerTypeEnum type;
  @override
  final int alg;

  factory _$PasskeyRegistrationOptionsPubKeyCredParamsInner(
          [void Function(
                  PasskeyRegistrationOptionsPubKeyCredParamsInnerBuilder)?
              updates]) =>
      (PasskeyRegistrationOptionsPubKeyCredParamsInnerBuilder()
            ..update(updates))
          ._build();

  _$PasskeyRegistrationOptionsPubKeyCredParamsInner._(
      {required this.type, required this.alg})
      : super._();
  @override
  PasskeyRegistrationOptionsPubKeyCredParamsInner rebuild(
          void Function(PasskeyRegistrationOptionsPubKeyCredParamsInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PasskeyRegistrationOptionsPubKeyCredParamsInnerBuilder toBuilder() =>
      PasskeyRegistrationOptionsPubKeyCredParamsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PasskeyRegistrationOptionsPubKeyCredParamsInner &&
        type == other.type &&
        alg == other.alg;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, alg.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PasskeyRegistrationOptionsPubKeyCredParamsInner')
          ..add('type', type)
          ..add('alg', alg))
        .toString();
  }
}

class PasskeyRegistrationOptionsPubKeyCredParamsInnerBuilder
    implements
        Builder<PasskeyRegistrationOptionsPubKeyCredParamsInner,
            PasskeyRegistrationOptionsPubKeyCredParamsInnerBuilder> {
  _$PasskeyRegistrationOptionsPubKeyCredParamsInner? _$v;

  PasskeyRegistrationOptionsPubKeyCredParamsInnerTypeEnum? _type;
  PasskeyRegistrationOptionsPubKeyCredParamsInnerTypeEnum? get type =>
      _$this._type;
  set type(PasskeyRegistrationOptionsPubKeyCredParamsInnerTypeEnum? type) =>
      _$this._type = type;

  int? _alg;
  int? get alg => _$this._alg;
  set alg(int? alg) => _$this._alg = alg;

  PasskeyRegistrationOptionsPubKeyCredParamsInnerBuilder() {
    PasskeyRegistrationOptionsPubKeyCredParamsInner._defaults(this);
  }

  PasskeyRegistrationOptionsPubKeyCredParamsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _type = $v.type;
      _alg = $v.alg;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PasskeyRegistrationOptionsPubKeyCredParamsInner other) {
    _$v = other as _$PasskeyRegistrationOptionsPubKeyCredParamsInner;
  }

  @override
  void update(
      void Function(PasskeyRegistrationOptionsPubKeyCredParamsInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PasskeyRegistrationOptionsPubKeyCredParamsInner build() => _build();

  _$PasskeyRegistrationOptionsPubKeyCredParamsInner _build() {
    final _$result = _$v ??
        _$PasskeyRegistrationOptionsPubKeyCredParamsInner._(
          type: BuiltValueNullFieldError.checkNotNull(
              type, r'PasskeyRegistrationOptionsPubKeyCredParamsInner', 'type'),
          alg: BuiltValueNullFieldError.checkNotNull(
              alg, r'PasskeyRegistrationOptionsPubKeyCredParamsInner', 'alg'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
