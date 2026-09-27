// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credential_secret_email.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CredentialSecretEmailStateEnum _$credentialSecretEmailStateEnum_queued =
    const CredentialSecretEmailStateEnum._('queued');

CredentialSecretEmailStateEnum _$credentialSecretEmailStateEnumValueOf(
    String name) {
  switch (name) {
    case 'queued':
      return _$credentialSecretEmailStateEnum_queued;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CredentialSecretEmailStateEnum>
    _$credentialSecretEmailStateEnumValues = BuiltSet<
        CredentialSecretEmailStateEnum>(const <CredentialSecretEmailStateEnum>[
  _$credentialSecretEmailStateEnum_queued,
]);

Serializer<CredentialSecretEmailStateEnum>
    _$credentialSecretEmailStateEnumSerializer =
    _$CredentialSecretEmailStateEnumSerializer();

class _$CredentialSecretEmailStateEnumSerializer
    implements PrimitiveSerializer<CredentialSecretEmailStateEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'queued': 'queued',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'queued': 'queued',
  };

  @override
  final Iterable<Type> types = const <Type>[CredentialSecretEmailStateEnum];
  @override
  final String wireName = 'CredentialSecretEmailStateEnum';

  @override
  Object serialize(
          Serializers serializers, CredentialSecretEmailStateEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CredentialSecretEmailStateEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CredentialSecretEmailStateEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$CredentialSecretEmail extends CredentialSecretEmail {
  @override
  final String id;
  @override
  final String to;
  @override
  final CredentialSecretEmailStateEnum state;

  factory _$CredentialSecretEmail(
          [void Function(CredentialSecretEmailBuilder)? updates]) =>
      (CredentialSecretEmailBuilder()..update(updates))._build();

  _$CredentialSecretEmail._(
      {required this.id, required this.to, required this.state})
      : super._();
  @override
  CredentialSecretEmail rebuild(
          void Function(CredentialSecretEmailBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CredentialSecretEmailBuilder toBuilder() =>
      CredentialSecretEmailBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CredentialSecretEmail &&
        id == other.id &&
        to == other.to &&
        state == other.state;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, to.hashCode);
    _$hash = $jc(_$hash, state.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CredentialSecretEmail')
          ..add('id', id)
          ..add('to', to)
          ..add('state', state))
        .toString();
  }
}

class CredentialSecretEmailBuilder
    implements Builder<CredentialSecretEmail, CredentialSecretEmailBuilder> {
  _$CredentialSecretEmail? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _to;
  String? get to => _$this._to;
  set to(String? to) => _$this._to = to;

  CredentialSecretEmailStateEnum? _state;
  CredentialSecretEmailStateEnum? get state => _$this._state;
  set state(CredentialSecretEmailStateEnum? state) => _$this._state = state;

  CredentialSecretEmailBuilder() {
    CredentialSecretEmail._defaults(this);
  }

  CredentialSecretEmailBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _to = $v.to;
      _state = $v.state;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CredentialSecretEmail other) {
    _$v = other as _$CredentialSecretEmail;
  }

  @override
  void update(void Function(CredentialSecretEmailBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CredentialSecretEmail build() => _build();

  _$CredentialSecretEmail _build() {
    final _$result = _$v ??
        _$CredentialSecretEmail._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'CredentialSecretEmail', 'id'),
          to: BuiltValueNullFieldError.checkNotNull(
              to, r'CredentialSecretEmail', 'to'),
          state: BuiltValueNullFieldError.checkNotNull(
              state, r'CredentialSecretEmail', 'state'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
