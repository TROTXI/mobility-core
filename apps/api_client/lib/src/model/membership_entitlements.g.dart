// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membership_entitlements.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MembershipEntitlements extends MembershipEntitlements {
  @override
  final int remainingRides;
  @override
  final Money credit;
  @override
  final Money heldCredit;
  @override
  final Money availableCredit;

  factory _$MembershipEntitlements(
          [void Function(MembershipEntitlementsBuilder)? updates]) =>
      (MembershipEntitlementsBuilder()..update(updates))._build();

  _$MembershipEntitlements._(
      {required this.remainingRides,
      required this.credit,
      required this.heldCredit,
      required this.availableCredit})
      : super._();
  @override
  MembershipEntitlements rebuild(
          void Function(MembershipEntitlementsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MembershipEntitlementsBuilder toBuilder() =>
      MembershipEntitlementsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MembershipEntitlements &&
        remainingRides == other.remainingRides &&
        credit == other.credit &&
        heldCredit == other.heldCredit &&
        availableCredit == other.availableCredit;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, remainingRides.hashCode);
    _$hash = $jc(_$hash, credit.hashCode);
    _$hash = $jc(_$hash, heldCredit.hashCode);
    _$hash = $jc(_$hash, availableCredit.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MembershipEntitlements')
          ..add('remainingRides', remainingRides)
          ..add('credit', credit)
          ..add('heldCredit', heldCredit)
          ..add('availableCredit', availableCredit))
        .toString();
  }
}

class MembershipEntitlementsBuilder
    implements Builder<MembershipEntitlements, MembershipEntitlementsBuilder> {
  _$MembershipEntitlements? _$v;

  int? _remainingRides;
  int? get remainingRides => _$this._remainingRides;
  set remainingRides(int? remainingRides) =>
      _$this._remainingRides = remainingRides;

  MoneyBuilder? _credit;
  MoneyBuilder get credit => _$this._credit ??= MoneyBuilder();
  set credit(MoneyBuilder? credit) => _$this._credit = credit;

  MoneyBuilder? _heldCredit;
  MoneyBuilder get heldCredit => _$this._heldCredit ??= MoneyBuilder();
  set heldCredit(MoneyBuilder? heldCredit) => _$this._heldCredit = heldCredit;

  MoneyBuilder? _availableCredit;
  MoneyBuilder get availableCredit =>
      _$this._availableCredit ??= MoneyBuilder();
  set availableCredit(MoneyBuilder? availableCredit) =>
      _$this._availableCredit = availableCredit;

  MembershipEntitlementsBuilder() {
    MembershipEntitlements._defaults(this);
  }

  MembershipEntitlementsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _remainingRides = $v.remainingRides;
      _credit = $v.credit.toBuilder();
      _heldCredit = $v.heldCredit.toBuilder();
      _availableCredit = $v.availableCredit.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MembershipEntitlements other) {
    _$v = other as _$MembershipEntitlements;
  }

  @override
  void update(void Function(MembershipEntitlementsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MembershipEntitlements build() => _build();

  _$MembershipEntitlements _build() {
    _$MembershipEntitlements _$result;
    try {
      _$result = _$v ??
          _$MembershipEntitlements._(
            remainingRides: BuiltValueNullFieldError.checkNotNull(
                remainingRides, r'MembershipEntitlements', 'remainingRides'),
            credit: credit.build(),
            heldCredit: heldCredit.build(),
            availableCredit: availableCredit.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'credit';
        credit.build();
        _$failedField = 'heldCredit';
        heldCredit.build();
        _$failedField = 'availableCredit';
        availableCredit.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'MembershipEntitlements', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
