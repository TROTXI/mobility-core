// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ops_google_sign_in.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OpsGoogleSignIn extends OpsGoogleSignIn {
  @override
  final String idToken;
  @override
  final String? invitationToken;

  factory _$OpsGoogleSignIn([void Function(OpsGoogleSignInBuilder)? updates]) =>
      (OpsGoogleSignInBuilder()..update(updates))._build();

  _$OpsGoogleSignIn._({required this.idToken, this.invitationToken})
      : super._();
  @override
  OpsGoogleSignIn rebuild(void Function(OpsGoogleSignInBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OpsGoogleSignInBuilder toBuilder() => OpsGoogleSignInBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OpsGoogleSignIn &&
        idToken == other.idToken &&
        invitationToken == other.invitationToken;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, idToken.hashCode);
    _$hash = $jc(_$hash, invitationToken.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OpsGoogleSignIn')
          ..add('idToken', idToken)
          ..add('invitationToken', invitationToken))
        .toString();
  }
}

class OpsGoogleSignInBuilder
    implements Builder<OpsGoogleSignIn, OpsGoogleSignInBuilder> {
  _$OpsGoogleSignIn? _$v;

  String? _idToken;
  String? get idToken => _$this._idToken;
  set idToken(String? idToken) => _$this._idToken = idToken;

  String? _invitationToken;
  String? get invitationToken => _$this._invitationToken;
  set invitationToken(String? invitationToken) =>
      _$this._invitationToken = invitationToken;

  OpsGoogleSignInBuilder() {
    OpsGoogleSignIn._defaults(this);
  }

  OpsGoogleSignInBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _idToken = $v.idToken;
      _invitationToken = $v.invitationToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OpsGoogleSignIn other) {
    _$v = other as _$OpsGoogleSignIn;
  }

  @override
  void update(void Function(OpsGoogleSignInBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OpsGoogleSignIn build() => _build();

  _$OpsGoogleSignIn _build() {
    final _$result = _$v ??
        _$OpsGoogleSignIn._(
          idToken: BuiltValueNullFieldError.checkNotNull(
              idToken, r'OpsGoogleSignIn', 'idToken'),
          invitationToken: invitationToken,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
