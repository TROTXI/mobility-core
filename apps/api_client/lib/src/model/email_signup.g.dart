// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'email_signup.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$EmailSignup extends EmailSignup {
  @override
  final String email;
  @override
  final String firstName;
  @override
  final String lastName;
  @override
  final String? otherNames;
  @override
  final bool acceptedTerms;
  @override
  final String termsVersion;

  factory _$EmailSignup([void Function(EmailSignupBuilder)? updates]) =>
      (EmailSignupBuilder()..update(updates))._build();

  _$EmailSignup._(
      {required this.email,
      required this.firstName,
      required this.lastName,
      this.otherNames,
      required this.acceptedTerms,
      required this.termsVersion})
      : super._();
  @override
  EmailSignup rebuild(void Function(EmailSignupBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  EmailSignupBuilder toBuilder() => EmailSignupBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is EmailSignup &&
        email == other.email &&
        firstName == other.firstName &&
        lastName == other.lastName &&
        otherNames == other.otherNames &&
        acceptedTerms == other.acceptedTerms &&
        termsVersion == other.termsVersion;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, firstName.hashCode);
    _$hash = $jc(_$hash, lastName.hashCode);
    _$hash = $jc(_$hash, otherNames.hashCode);
    _$hash = $jc(_$hash, acceptedTerms.hashCode);
    _$hash = $jc(_$hash, termsVersion.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'EmailSignup')
          ..add('email', email)
          ..add('firstName', firstName)
          ..add('lastName', lastName)
          ..add('otherNames', otherNames)
          ..add('acceptedTerms', acceptedTerms)
          ..add('termsVersion', termsVersion))
        .toString();
  }
}

class EmailSignupBuilder implements Builder<EmailSignup, EmailSignupBuilder> {
  _$EmailSignup? _$v;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  String? _firstName;
  String? get firstName => _$this._firstName;
  set firstName(String? firstName) => _$this._firstName = firstName;

  String? _lastName;
  String? get lastName => _$this._lastName;
  set lastName(String? lastName) => _$this._lastName = lastName;

  String? _otherNames;
  String? get otherNames => _$this._otherNames;
  set otherNames(String? otherNames) => _$this._otherNames = otherNames;

  bool? _acceptedTerms;
  bool? get acceptedTerms => _$this._acceptedTerms;
  set acceptedTerms(bool? acceptedTerms) =>
      _$this._acceptedTerms = acceptedTerms;

  String? _termsVersion;
  String? get termsVersion => _$this._termsVersion;
  set termsVersion(String? termsVersion) => _$this._termsVersion = termsVersion;

  EmailSignupBuilder() {
    EmailSignup._defaults(this);
  }

  EmailSignupBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _email = $v.email;
      _firstName = $v.firstName;
      _lastName = $v.lastName;
      _otherNames = $v.otherNames;
      _acceptedTerms = $v.acceptedTerms;
      _termsVersion = $v.termsVersion;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(EmailSignup other) {
    _$v = other as _$EmailSignup;
  }

  @override
  void update(void Function(EmailSignupBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  EmailSignup build() => _build();

  _$EmailSignup _build() {
    final _$result = _$v ??
        _$EmailSignup._(
          email: BuiltValueNullFieldError.checkNotNull(
              email, r'EmailSignup', 'email'),
          firstName: BuiltValueNullFieldError.checkNotNull(
              firstName, r'EmailSignup', 'firstName'),
          lastName: BuiltValueNullFieldError.checkNotNull(
              lastName, r'EmailSignup', 'lastName'),
          otherNames: otherNames,
          acceptedTerms: BuiltValueNullFieldError.checkNotNull(
              acceptedTerms, r'EmailSignup', 'acceptedTerms'),
          termsVersion: BuiltValueNullFieldError.checkNotNull(
              termsVersion, r'EmailSignup', 'termsVersion'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
