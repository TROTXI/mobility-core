// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credential_issue.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CredentialIssue extends CredentialIssue {
  @override
  final String? code;

  factory _$CredentialIssue([void Function(CredentialIssueBuilder)? updates]) =>
      (CredentialIssueBuilder()..update(updates))._build();

  _$CredentialIssue._({this.code}) : super._();
  @override
  CredentialIssue rebuild(void Function(CredentialIssueBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CredentialIssueBuilder toBuilder() => CredentialIssueBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CredentialIssue && code == other.code;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CredentialIssue')..add('code', code))
        .toString();
  }
}

class CredentialIssueBuilder
    implements Builder<CredentialIssue, CredentialIssueBuilder> {
  _$CredentialIssue? _$v;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  CredentialIssueBuilder() {
    CredentialIssue._defaults(this);
  }

  CredentialIssueBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _code = $v.code;
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
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
