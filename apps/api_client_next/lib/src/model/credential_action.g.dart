// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credential_action.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CredentialActionActionEnum _$credentialActionActionEnum_suspend =
    const CredentialActionActionEnum._('suspend');
const CredentialActionActionEnum _$credentialActionActionEnum_activate =
    const CredentialActionActionEnum._('activate');
const CredentialActionActionEnum _$credentialActionActionEnum_unlock =
    const CredentialActionActionEnum._('unlock');

CredentialActionActionEnum _$credentialActionActionEnumValueOf(String name) {
  switch (name) {
    case 'suspend':
      return _$credentialActionActionEnum_suspend;
    case 'activate':
      return _$credentialActionActionEnum_activate;
    case 'unlock':
      return _$credentialActionActionEnum_unlock;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CredentialActionActionEnum> _$credentialActionActionEnumValues =
    BuiltSet<CredentialActionActionEnum>(const <CredentialActionActionEnum>[
  _$credentialActionActionEnum_suspend,
  _$credentialActionActionEnum_activate,
  _$credentialActionActionEnum_unlock,
]);

Serializer<CredentialActionActionEnum> _$credentialActionActionEnumSerializer =
    _$CredentialActionActionEnumSerializer();

class _$CredentialActionActionEnumSerializer
    implements PrimitiveSerializer<CredentialActionActionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'suspend': 'suspend',
    'activate': 'activate',
    'unlock': 'unlock',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'suspend': 'suspend',
    'activate': 'activate',
    'unlock': 'unlock',
  };

  @override
  final Iterable<Type> types = const <Type>[CredentialActionActionEnum];
  @override
  final String wireName = 'CredentialActionActionEnum';

  @override
  Object serialize(Serializers serializers, CredentialActionActionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CredentialActionActionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CredentialActionActionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$CredentialAction extends CredentialAction {
  @override
  final CredentialActionActionEnum action;
  @override
  final String reason;

  factory _$CredentialAction(
          [void Function(CredentialActionBuilder)? updates]) =>
      (CredentialActionBuilder()..update(updates))._build();

  _$CredentialAction._({required this.action, required this.reason})
      : super._();
  @override
  CredentialAction rebuild(void Function(CredentialActionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CredentialActionBuilder toBuilder() =>
      CredentialActionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CredentialAction &&
        action == other.action &&
        reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, action.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CredentialAction')
          ..add('action', action)
          ..add('reason', reason))
        .toString();
  }
}

class CredentialActionBuilder
    implements Builder<CredentialAction, CredentialActionBuilder> {
  _$CredentialAction? _$v;

  CredentialActionActionEnum? _action;
  CredentialActionActionEnum? get action => _$this._action;
  set action(CredentialActionActionEnum? action) => _$this._action = action;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  CredentialActionBuilder() {
    CredentialAction._defaults(this);
  }

  CredentialActionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _action = $v.action;
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CredentialAction other) {
    _$v = other as _$CredentialAction;
  }

  @override
  void update(void Function(CredentialActionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CredentialAction build() => _build();

  _$CredentialAction _build() {
    final _$result = _$v ??
        _$CredentialAction._(
          action: BuiltValueNullFieldError.checkNotNull(
              action, r'CredentialAction', 'action'),
          reason: BuiltValueNullFieldError.checkNotNull(
              reason, r'CredentialAction', 'reason'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
