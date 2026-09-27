// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phone_challenge.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PhoneChallenge extends PhoneChallenge {
  @override
  final String challengeId;
  @override
  final DateTime expiresAt;
  @override
  final int resendAfterSeconds;

  factory _$PhoneChallenge([void Function(PhoneChallengeBuilder)? updates]) =>
      (PhoneChallengeBuilder()..update(updates))._build();

  _$PhoneChallenge._(
      {required this.challengeId,
      required this.expiresAt,
      required this.resendAfterSeconds})
      : super._();
  @override
  PhoneChallenge rebuild(void Function(PhoneChallengeBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PhoneChallengeBuilder toBuilder() => PhoneChallengeBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PhoneChallenge &&
        challengeId == other.challengeId &&
        expiresAt == other.expiresAt &&
        resendAfterSeconds == other.resendAfterSeconds;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, challengeId.hashCode);
    _$hash = $jc(_$hash, expiresAt.hashCode);
    _$hash = $jc(_$hash, resendAfterSeconds.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PhoneChallenge')
          ..add('challengeId', challengeId)
          ..add('expiresAt', expiresAt)
          ..add('resendAfterSeconds', resendAfterSeconds))
        .toString();
  }
}

class PhoneChallengeBuilder
    implements Builder<PhoneChallenge, PhoneChallengeBuilder> {
  _$PhoneChallenge? _$v;

  String? _challengeId;
  String? get challengeId => _$this._challengeId;
  set challengeId(String? challengeId) => _$this._challengeId = challengeId;

  DateTime? _expiresAt;
  DateTime? get expiresAt => _$this._expiresAt;
  set expiresAt(DateTime? expiresAt) => _$this._expiresAt = expiresAt;

  int? _resendAfterSeconds;
  int? get resendAfterSeconds => _$this._resendAfterSeconds;
  set resendAfterSeconds(int? resendAfterSeconds) =>
      _$this._resendAfterSeconds = resendAfterSeconds;

  PhoneChallengeBuilder() {
    PhoneChallenge._defaults(this);
  }

  PhoneChallengeBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _challengeId = $v.challengeId;
      _expiresAt = $v.expiresAt;
      _resendAfterSeconds = $v.resendAfterSeconds;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PhoneChallenge other) {
    _$v = other as _$PhoneChallenge;
  }

  @override
  void update(void Function(PhoneChallengeBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PhoneChallenge build() => _build();

  _$PhoneChallenge _build() {
    final _$result = _$v ??
        _$PhoneChallenge._(
          challengeId: BuiltValueNullFieldError.checkNotNull(
              challengeId, r'PhoneChallenge', 'challengeId'),
          expiresAt: BuiltValueNullFieldError.checkNotNull(
              expiresAt, r'PhoneChallenge', 'expiresAt'),
          resendAfterSeconds: BuiltValueNullFieldError.checkNotNull(
              resendAfterSeconds, r'PhoneChallenge', 'resendAfterSeconds'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
