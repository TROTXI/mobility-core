// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'google_sign_in.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GoogleSignIn extends GoogleSignIn {
  @override
  final String idToken;
  @override
  final bool? acceptedTerms;
  @override
  final String? termsVersion;

  factory _$GoogleSignIn([void Function(GoogleSignInBuilder)? updates]) =>
      (GoogleSignInBuilder()..update(updates))._build();

  _$GoogleSignIn._(
      {required this.idToken, this.acceptedTerms, this.termsVersion})
      : super._();
  @override
  GoogleSignIn rebuild(void Function(GoogleSignInBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GoogleSignInBuilder toBuilder() => GoogleSignInBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GoogleSignIn &&
        idToken == other.idToken &&
        acceptedTerms == other.acceptedTerms &&
        termsVersion == other.termsVersion;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, idToken.hashCode);
    _$hash = $jc(_$hash, acceptedTerms.hashCode);
    _$hash = $jc(_$hash, termsVersion.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GoogleSignIn')
          ..add('idToken', idToken)
          ..add('acceptedTerms', acceptedTerms)
          ..add('termsVersion', termsVersion))
        .toString();
  }
}

class GoogleSignInBuilder
    implements Builder<GoogleSignIn, GoogleSignInBuilder> {
  _$GoogleSignIn? _$v;

  String? _idToken;
  String? get idToken => _$this._idToken;
  set idToken(String? idToken) => _$this._idToken = idToken;

  bool? _acceptedTerms;
  bool? get acceptedTerms => _$this._acceptedTerms;
  set acceptedTerms(bool? acceptedTerms) =>
      _$this._acceptedTerms = acceptedTerms;

  String? _termsVersion;
  String? get termsVersion => _$this._termsVersion;
  set termsVersion(String? termsVersion) => _$this._termsVersion = termsVersion;

  GoogleSignInBuilder() {
    GoogleSignIn._defaults(this);
  }

  GoogleSignInBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _idToken = $v.idToken;
      _acceptedTerms = $v.acceptedTerms;
      _termsVersion = $v.termsVersion;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GoogleSignIn other) {
    _$v = other as _$GoogleSignIn;
  }

  @override
  void update(void Function(GoogleSignInBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GoogleSignIn build() => _build();

  _$GoogleSignIn _build() {
    final _$result = _$v ??
        _$GoogleSignIn._(
          idToken: BuiltValueNullFieldError.checkNotNull(
              idToken, r'GoogleSignIn', 'idToken'),
          acceptedTerms: acceptedTerms,
          termsVersion: termsVersion,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
