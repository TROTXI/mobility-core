// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'passkey_status.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PasskeyStatus extends PasskeyStatus {
  @override
  final bool registered;
  @override
  final int passkeyCount;
  @override
  final bool registrationPending;
  @override
  final bool verified;

  factory _$PasskeyStatus([void Function(PasskeyStatusBuilder)? updates]) =>
      (PasskeyStatusBuilder()..update(updates))._build();

  _$PasskeyStatus._(
      {required this.registered,
      required this.passkeyCount,
      required this.registrationPending,
      required this.verified})
      : super._();
  @override
  PasskeyStatus rebuild(void Function(PasskeyStatusBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PasskeyStatusBuilder toBuilder() => PasskeyStatusBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PasskeyStatus &&
        registered == other.registered &&
        passkeyCount == other.passkeyCount &&
        registrationPending == other.registrationPending &&
        verified == other.verified;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, registered.hashCode);
    _$hash = $jc(_$hash, passkeyCount.hashCode);
    _$hash = $jc(_$hash, registrationPending.hashCode);
    _$hash = $jc(_$hash, verified.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PasskeyStatus')
          ..add('registered', registered)
          ..add('passkeyCount', passkeyCount)
          ..add('registrationPending', registrationPending)
          ..add('verified', verified))
        .toString();
  }
}

class PasskeyStatusBuilder
    implements Builder<PasskeyStatus, PasskeyStatusBuilder> {
  _$PasskeyStatus? _$v;

  bool? _registered;
  bool? get registered => _$this._registered;
  set registered(bool? registered) => _$this._registered = registered;

  int? _passkeyCount;
  int? get passkeyCount => _$this._passkeyCount;
  set passkeyCount(int? passkeyCount) => _$this._passkeyCount = passkeyCount;

  bool? _registrationPending;
  bool? get registrationPending => _$this._registrationPending;
  set registrationPending(bool? registrationPending) =>
      _$this._registrationPending = registrationPending;

  bool? _verified;
  bool? get verified => _$this._verified;
  set verified(bool? verified) => _$this._verified = verified;

  PasskeyStatusBuilder() {
    PasskeyStatus._defaults(this);
  }

  PasskeyStatusBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _registered = $v.registered;
      _passkeyCount = $v.passkeyCount;
      _registrationPending = $v.registrationPending;
      _verified = $v.verified;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PasskeyStatus other) {
    _$v = other as _$PasskeyStatus;
  }

  @override
  void update(void Function(PasskeyStatusBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PasskeyStatus build() => _build();

  _$PasskeyStatus _build() {
    final _$result = _$v ??
        _$PasskeyStatus._(
          registered: BuiltValueNullFieldError.checkNotNull(
              registered, r'PasskeyStatus', 'registered'),
          passkeyCount: BuiltValueNullFieldError.checkNotNull(
              passkeyCount, r'PasskeyStatus', 'passkeyCount'),
          registrationPending: BuiltValueNullFieldError.checkNotNull(
              registrationPending, r'PasskeyStatus', 'registrationPending'),
          verified: BuiltValueNullFieldError.checkNotNull(
              verified, r'PasskeyStatus', 'verified'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
