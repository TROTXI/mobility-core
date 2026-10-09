// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'operator_invitation_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OperatorInvitationInput extends OperatorInvitationInput {
  @override
  final String email;
  @override
  final String name;
  @override
  final String reason;

  factory _$OperatorInvitationInput(
          [void Function(OperatorInvitationInputBuilder)? updates]) =>
      (OperatorInvitationInputBuilder()..update(updates))._build();

  _$OperatorInvitationInput._(
      {required this.email, required this.name, required this.reason})
      : super._();
  @override
  OperatorInvitationInput rebuild(
          void Function(OperatorInvitationInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OperatorInvitationInputBuilder toBuilder() =>
      OperatorInvitationInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OperatorInvitationInput &&
        email == other.email &&
        name == other.name &&
        reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OperatorInvitationInput')
          ..add('email', email)
          ..add('name', name)
          ..add('reason', reason))
        .toString();
  }
}

class OperatorInvitationInputBuilder
    implements
        Builder<OperatorInvitationInput, OperatorInvitationInputBuilder> {
  _$OperatorInvitationInput? _$v;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  OperatorInvitationInputBuilder() {
    OperatorInvitationInput._defaults(this);
  }

  OperatorInvitationInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _email = $v.email;
      _name = $v.name;
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OperatorInvitationInput other) {
    _$v = other as _$OperatorInvitationInput;
  }

  @override
  void update(void Function(OperatorInvitationInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OperatorInvitationInput build() => _build();

  _$OperatorInvitationInput _build() {
    final _$result = _$v ??
        _$OperatorInvitationInput._(
          email: BuiltValueNullFieldError.checkNotNull(
              email, r'OperatorInvitationInput', 'email'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'OperatorInvitationInput', 'name'),
          reason: BuiltValueNullFieldError.checkNotNull(
              reason, r'OperatorInvitationInput', 'reason'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
