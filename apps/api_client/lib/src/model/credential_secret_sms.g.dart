// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credential_secret_sms.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CredentialSecretSmsStateEnum _$credentialSecretSmsStateEnum_queued =
    const CredentialSecretSmsStateEnum._('queued');

CredentialSecretSmsStateEnum _$credentialSecretSmsStateEnumValueOf(
    String name) {
  switch (name) {
    case 'queued':
      return _$credentialSecretSmsStateEnum_queued;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CredentialSecretSmsStateEnum>
    _$credentialSecretSmsStateEnumValues =
    BuiltSet<CredentialSecretSmsStateEnum>(const <CredentialSecretSmsStateEnum>[
  _$credentialSecretSmsStateEnum_queued,
]);

Serializer<CredentialSecretSmsStateEnum>
    _$credentialSecretSmsStateEnumSerializer =
    _$CredentialSecretSmsStateEnumSerializer();

class _$CredentialSecretSmsStateEnumSerializer
    implements PrimitiveSerializer<CredentialSecretSmsStateEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'queued': 'queued',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'queued': 'queued',
  };

  @override
  final Iterable<Type> types = const <Type>[CredentialSecretSmsStateEnum];
  @override
  final String wireName = 'CredentialSecretSmsStateEnum';

  @override
  Object serialize(Serializers serializers, CredentialSecretSmsStateEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CredentialSecretSmsStateEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CredentialSecretSmsStateEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$CredentialSecretSms extends CredentialSecretSms {
  @override
  final String id;
  @override
  final String to;
  @override
  final CredentialSecretSmsStateEnum state;

  factory _$CredentialSecretSms(
          [void Function(CredentialSecretSmsBuilder)? updates]) =>
      (CredentialSecretSmsBuilder()..update(updates))._build();

  _$CredentialSecretSms._(
      {required this.id, required this.to, required this.state})
      : super._();
  @override
  CredentialSecretSms rebuild(
          void Function(CredentialSecretSmsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CredentialSecretSmsBuilder toBuilder() =>
      CredentialSecretSmsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CredentialSecretSms &&
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
    return (newBuiltValueToStringHelper(r'CredentialSecretSms')
          ..add('id', id)
          ..add('to', to)
          ..add('state', state))
        .toString();
  }
}

class CredentialSecretSmsBuilder
    implements Builder<CredentialSecretSms, CredentialSecretSmsBuilder> {
  _$CredentialSecretSms? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _to;
  String? get to => _$this._to;
  set to(String? to) => _$this._to = to;

  CredentialSecretSmsStateEnum? _state;
  CredentialSecretSmsStateEnum? get state => _$this._state;
  set state(CredentialSecretSmsStateEnum? state) => _$this._state = state;

  CredentialSecretSmsBuilder() {
    CredentialSecretSms._defaults(this);
  }

  CredentialSecretSmsBuilder get _$this {
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
  void replace(CredentialSecretSms other) {
    _$v = other as _$CredentialSecretSms;
  }

  @override
  void update(void Function(CredentialSecretSmsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CredentialSecretSms build() => _build();

  _$CredentialSecretSms _build() {
    final _$result = _$v ??
        _$CredentialSecretSms._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'CredentialSecretSms', 'id'),
          to: BuiltValueNullFieldError.checkNotNull(
              to, r'CredentialSecretSms', 'to'),
          state: BuiltValueNullFieldError.checkNotNull(
              state, r'CredentialSecretSms', 'state'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
