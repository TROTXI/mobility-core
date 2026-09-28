// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credential_issue.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CredentialIssue extends CredentialIssue {
  @override
  final String? code;
  @override
  final bool? emailInstructions;
  @override
  final bool? smsInstructions;

  factory _$CredentialIssue([void Function(CredentialIssueBuilder)? updates]) =>
      (CredentialIssueBuilder()..update(updates))._build();

  _$CredentialIssue._({this.code, this.emailInstructions, this.smsInstructions})
      : super._();
  @override
  CredentialIssue rebuild(void Function(CredentialIssueBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CredentialIssueBuilder toBuilder() => CredentialIssueBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CredentialIssue &&
        code == other.code &&
        emailInstructions == other.emailInstructions &&
        smsInstructions == other.smsInstructions;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, emailInstructions.hashCode);
    _$hash = $jc(_$hash, smsInstructions.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CredentialIssue')
          ..add('code', code)
          ..add('emailInstructions', emailInstructions)
          ..add('smsInstructions', smsInstructions))
        .toString();
  }
}

class CredentialIssueBuilder
    implements Builder<CredentialIssue, CredentialIssueBuilder> {
  _$CredentialIssue? _$v;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  bool? _emailInstructions;
  bool? get emailInstructions => _$this._emailInstructions;
  set emailInstructions(bool? emailInstructions) =>
      _$this._emailInstructions = emailInstructions;

  bool? _smsInstructions;
  bool? get smsInstructions => _$this._smsInstructions;
  set smsInstructions(bool? smsInstructions) =>
      _$this._smsInstructions = smsInstructions;

  CredentialIssueBuilder() {
    CredentialIssue._defaults(this);
  }

  CredentialIssueBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _code = $v.code;
      _emailInstructions = $v.emailInstructions;
      _smsInstructions = $v.smsInstructions;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CredentialIssue other) {
    _$v = other as _$CredentialIssue;
  }

  @override
  void update(void Function(CredentialIssueBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CredentialIssue build() => _build();

  _$CredentialIssue _build() {
    final _$result = _$v ??
        _$CredentialIssue._(
          code: code,
          emailInstructions: emailInstructions,
          smsInstructions: smsInstructions,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
