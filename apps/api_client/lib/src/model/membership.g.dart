// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membership.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Membership extends Membership {
  @override
  final MembershipMembership? membership;
  @override
  final MembershipCoverage? coverage;
  @override
  final DateTime? lastCoverageEndedAt;
  @override
  final MembershipAccess access;
  @override
  final MembershipCommute? commute;
  @override
  final MembershipEntitlements entitlements;

  factory _$Membership([void Function(MembershipBuilder)? updates]) =>
      (MembershipBuilder()..update(updates))._build();

  _$Membership._(
      {this.membership,
      this.coverage,
      this.lastCoverageEndedAt,
      required this.access,
      this.commute,
      required this.entitlements})
      : super._();
  @override
  Membership rebuild(void Function(MembershipBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MembershipBuilder toBuilder() => MembershipBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Membership &&
        membership == other.membership &&
        coverage == other.coverage &&
        lastCoverageEndedAt == other.lastCoverageEndedAt &&
        access == other.access &&
        commute == other.commute &&
        entitlements == other.entitlements;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, membership.hashCode);
    _$hash = $jc(_$hash, coverage.hashCode);
    _$hash = $jc(_$hash, lastCoverageEndedAt.hashCode);
    _$hash = $jc(_$hash, access.hashCode);
    _$hash = $jc(_$hash, commute.hashCode);
    _$hash = $jc(_$hash, entitlements.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Membership')
          ..add('membership', membership)
          ..add('coverage', coverage)
          ..add('lastCoverageEndedAt', lastCoverageEndedAt)
          ..add('access', access)
          ..add('commute', commute)
          ..add('entitlements', entitlements))
        .toString();
  }
}

class MembershipBuilder implements Builder<Membership, MembershipBuilder> {
  _$Membership? _$v;

  MembershipMembershipBuilder? _membership;
  MembershipMembershipBuilder get membership =>
      _$this._membership ??= MembershipMembershipBuilder();
  set membership(MembershipMembershipBuilder? membership) =>
      _$this._membership = membership;

  MembershipCoverageBuilder? _coverage;
  MembershipCoverageBuilder get coverage =>
      _$this._coverage ??= MembershipCoverageBuilder();
  set coverage(MembershipCoverageBuilder? coverage) =>
      _$this._coverage = coverage;

  DateTime? _lastCoverageEndedAt;
  DateTime? get lastCoverageEndedAt => _$this._lastCoverageEndedAt;
  set lastCoverageEndedAt(DateTime? lastCoverageEndedAt) =>
      _$this._lastCoverageEndedAt = lastCoverageEndedAt;

  MembershipAccessBuilder? _access;
  MembershipAccessBuilder get access =>
      _$this._access ??= MembershipAccessBuilder();
  set access(MembershipAccessBuilder? access) => _$this._access = access;

  MembershipCommuteBuilder? _commute;
  MembershipCommuteBuilder get commute =>
      _$this._commute ??= MembershipCommuteBuilder();
  set commute(MembershipCommuteBuilder? commute) => _$this._commute = commute;

  MembershipEntitlementsBuilder? _entitlements;
  MembershipEntitlementsBuilder get entitlements =>
      _$this._entitlements ??= MembershipEntitlementsBuilder();
  set entitlements(MembershipEntitlementsBuilder? entitlements) =>
      _$this._entitlements = entitlements;

  MembershipBuilder() {
    Membership._defaults(this);
  }

  MembershipBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _membership = $v.membership?.toBuilder();
      _coverage = $v.coverage?.toBuilder();
      _lastCoverageEndedAt = $v.lastCoverageEndedAt;
      _access = $v.access.toBuilder();
      _commute = $v.commute?.toBuilder();
      _entitlements = $v.entitlements.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Membership other) {
    _$v = other as _$Membership;
  }

  @override
  void update(void Function(MembershipBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Membership build() => _build();

  _$Membership _build() {
    _$Membership _$result;
    try {
      _$result = _$v ??
          _$Membership._(
            membership: _membership?.build(),
            coverage: _coverage?.build(),
            lastCoverageEndedAt: lastCoverageEndedAt,
            access: access.build(),
            commute: _commute?.build(),
            entitlements: entitlements.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'membership';
        _membership?.build();
        _$failedField = 'coverage';
        _coverage?.build();

        _$failedField = 'access';
        access.build();
        _$failedField = 'commute';
        _commute?.build();
        _$failedField = 'entitlements';
        entitlements.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'Membership', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
