// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phone_sign_in_verify.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PhoneSignInVerify extends PhoneSignInVerify {
  @override
  final String challengeId;
  @override
  final String code;

  factory _$PhoneSignInVerify(
          [void Function(PhoneSignInVerifyBuilder)? updates]) =>
      (PhoneSignInVerifyBuilder()..update(updates))._build();

  _$PhoneSignInVerify._({required this.challengeId, required this.code})
      : super._();
  @override
  PhoneSignInVerify rebuild(void Function(PhoneSignInVerifyBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PhoneSignInVerifyBuilder toBuilder() =>
      PhoneSignInVerifyBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PhoneSignInVerify &&
        challengeId == other.challengeId &&
        code == other.code;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, challengeId.hashCode);
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PhoneSignInVerify')
          ..add('challengeId', challengeId)
          ..add('code', code))
        .toString();
  }
}

class PhoneSignInVerifyBuilder
    implements Builder<PhoneSignInVerify, PhoneSignInVerifyBuilder> {
  _$PhoneSignInVerify? _$v;

  String? _challengeId;
  String? get challengeId => _$this._challengeId;
  set challengeId(String? challengeId) => _$this._challengeId = challengeId;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  PhoneSignInVerifyBuilder() {
    PhoneSignInVerify._defaults(this);
  }

  PhoneSignInVerifyBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _challengeId = $v.challengeId;
      _code = $v.code;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PhoneSignInVerify other) {
    _$v = other as _$PhoneSignInVerify;
  }

  @override
  void update(void Function(PhoneSignInVerifyBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PhoneSignInVerify build() => _build();

  _$PhoneSignInVerify _build() {
    final _$result = _$v ??
        _$PhoneSignInVerify._(
          challengeId: BuiltValueNullFieldError.checkNotNull(
              challengeId, r'PhoneSignInVerify', 'challengeId'),
          code: BuiltValueNullFieldError.checkNotNull(
              code, r'PhoneSignInVerify', 'code'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
