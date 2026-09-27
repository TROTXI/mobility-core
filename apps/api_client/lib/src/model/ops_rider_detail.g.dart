// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ops_rider_detail.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OpsRiderDetail extends OpsRiderDetail {
  @override
  final OpsRider rider;
  @override
  final OpsRiderDetailMembership? membership;
  @override
  final BuiltList<Restriction> restrictions;
  @override
  final BuiltList<OpsRiderDetailReservationsInner> reservations;
  @override
  final BuiltList<OpsRiderDetailPurchasesInner> purchases;

  factory _$OpsRiderDetail([void Function(OpsRiderDetailBuilder)? updates]) =>
      (OpsRiderDetailBuilder()..update(updates))._build();

  _$OpsRiderDetail._(
      {required this.rider,
      this.membership,
      required this.restrictions,
      required this.reservations,
      required this.purchases})
      : super._();
  @override
  OpsRiderDetail rebuild(void Function(OpsRiderDetailBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OpsRiderDetailBuilder toBuilder() => OpsRiderDetailBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OpsRiderDetail &&
        rider == other.rider &&
        membership == other.membership &&
        restrictions == other.restrictions &&
        reservations == other.reservations &&
        purchases == other.purchases;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, rider.hashCode);
    _$hash = $jc(_$hash, membership.hashCode);
    _$hash = $jc(_$hash, restrictions.hashCode);
    _$hash = $jc(_$hash, reservations.hashCode);
    _$hash = $jc(_$hash, purchases.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OpsRiderDetail')
          ..add('rider', rider)
          ..add('membership', membership)
          ..add('restrictions', restrictions)
          ..add('reservations', reservations)
          ..add('purchases', purchases))
        .toString();
  }
}

class OpsRiderDetailBuilder
    implements Builder<OpsRiderDetail, OpsRiderDetailBuilder> {
  _$OpsRiderDetail? _$v;

  OpsRiderBuilder? _rider;
  OpsRiderBuilder get rider => _$this._rider ??= OpsRiderBuilder();
  set rider(OpsRiderBuilder? rider) => _$this._rider = rider;

  OpsRiderDetailMembershipBuilder? _membership;
  OpsRiderDetailMembershipBuilder get membership =>
      _$this._membership ??= OpsRiderDetailMembershipBuilder();
  set membership(OpsRiderDetailMembershipBuilder? membership) =>
      _$this._membership = membership;

  ListBuilder<Restriction>? _restrictions;
  ListBuilder<Restriction> get restrictions =>
      _$this._restrictions ??= ListBuilder<Restriction>();
  set restrictions(ListBuilder<Restriction>? restrictions) =>
      _$this._restrictions = restrictions;

  ListBuilder<OpsRiderDetailReservationsInner>? _reservations;
  ListBuilder<OpsRiderDetailReservationsInner> get reservations =>
      _$this._reservations ??= ListBuilder<OpsRiderDetailReservationsInner>();
  set reservations(
          ListBuilder<OpsRiderDetailReservationsInner>? reservations) =>
      _$this._reservations = reservations;

  ListBuilder<OpsRiderDetailPurchasesInner>? _purchases;
  ListBuilder<OpsRiderDetailPurchasesInner> get purchases =>
      _$this._purchases ??= ListBuilder<OpsRiderDetailPurchasesInner>();
  set purchases(ListBuilder<OpsRiderDetailPurchasesInner>? purchases) =>
      _$this._purchases = purchases;

  OpsRiderDetailBuilder() {
    OpsRiderDetail._defaults(this);
  }

  OpsRiderDetailBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _rider = $v.rider.toBuilder();
      _membership = $v.membership?.toBuilder();
      _restrictions = $v.restrictions.toBuilder();
      _reservations = $v.reservations.toBuilder();
      _purchases = $v.purchases.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OpsRiderDetail other) {
    _$v = other as _$OpsRiderDetail;
  }

  @override
  void update(void Function(OpsRiderDetailBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OpsRiderDetail build() => _build();

  _$OpsRiderDetail _build() {
    _$OpsRiderDetail _$result;
    try {
      _$result = _$v ??
          _$OpsRiderDetail._(
            rider: rider.build(),
            membership: _membership?.build(),
            restrictions: restrictions.build(),
            reservations: reservations.build(),
            purchases: purchases.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'rider';
        rider.build();
        _$failedField = 'membership';
        _membership?.build();
        _$failedField = 'restrictions';
        restrictions.build();
        _$failedField = 'reservations';
        reservations.build();
        _$failedField = 'purchases';
        purchases.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'OpsRiderDetail', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
