// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phone_verification_confirm.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PhoneVerificationConfirm extends PhoneVerificationConfirm {
  @override
  final String challengeId;
  @override
  final String code;

  factory _$PhoneVerificationConfirm(
          [void Function(PhoneVerificationConfirmBuilder)? updates]) =>
      (PhoneVerificationConfirmBuilder()..update(updates))._build();

  _$PhoneVerificationConfirm._({required this.challengeId, required this.code})
      : super._();
  @override
  PhoneVerificationConfirm rebuild(
          void Function(PhoneVerificationConfirmBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PhoneVerificationConfirmBuilder toBuilder() =>
      PhoneVerificationConfirmBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PhoneVerificationConfirm &&
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
    return (newBuiltValueToStringHelper(r'PhoneVerificationConfirm')
          ..add('challengeId', challengeId)
          ..add('code', code))
        .toString();
  }
}

class PhoneVerificationConfirmBuilder
    implements
        Builder<PhoneVerificationConfirm, PhoneVerificationConfirmBuilder> {
  _$PhoneVerificationConfirm? _$v;

  String? _challengeId;
  String? get challengeId => _$this._challengeId;
  set challengeId(String? challengeId) => _$this._challengeId = challengeId;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  PhoneVerificationConfirmBuilder() {
    PhoneVerificationConfirm._defaults(this);
  }

  PhoneVerificationConfirmBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _challengeId = $v.challengeId;
      _code = $v.code;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PhoneVerificationConfirm other) {
    _$v = other as _$PhoneVerificationConfirm;
  }

  @override
  void update(void Function(PhoneVerificationConfirmBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PhoneVerificationConfirm build() => _build();

  _$PhoneVerificationConfirm _build() {
    final _$result = _$v ??
        _$PhoneVerificationConfirm._(
          challengeId: BuiltValueNullFieldError.checkNotNull(
              challengeId, r'PhoneVerificationConfirm', 'challengeId'),
          code: BuiltValueNullFieldError.checkNotNull(
              code, r'PhoneVerificationConfirm', 'code'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
