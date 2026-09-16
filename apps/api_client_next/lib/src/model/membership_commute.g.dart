// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membership_commute.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MembershipCommute extends MembershipCommute {
  @override
  final String id;
  @override
  final String routeId;
  @override
  final String routeName;
  @override
  final Date effectiveFrom;
  @override
  final Date? effectiveTo;
  @override
  final BuiltList<CommuteLegView> legs;

  factory _$MembershipCommute(
          [void Function(MembershipCommuteBuilder)? updates]) =>
      (MembershipCommuteBuilder()..update(updates))._build();

  _$MembershipCommute._(
      {required this.id,
      required this.routeId,
      required this.routeName,
      required this.effectiveFrom,
      this.effectiveTo,
      required this.legs})
      : super._();
  @override
  MembershipCommute rebuild(void Function(MembershipCommuteBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MembershipCommuteBuilder toBuilder() =>
      MembershipCommuteBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MembershipCommute &&
        id == other.id &&
        routeId == other.routeId &&
        routeName == other.routeName &&
        effectiveFrom == other.effectiveFrom &&
        effectiveTo == other.effectiveTo &&
        legs == other.legs;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, routeId.hashCode);
    _$hash = $jc(_$hash, routeName.hashCode);
    _$hash = $jc(_$hash, effectiveFrom.hashCode);
    _$hash = $jc(_$hash, effectiveTo.hashCode);
    _$hash = $jc(_$hash, legs.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MembershipCommute')
          ..add('id', id)
          ..add('routeId', routeId)
          ..add('routeName', routeName)
          ..add('effectiveFrom', effectiveFrom)
          ..add('effectiveTo', effectiveTo)
          ..add('legs', legs))
        .toString();
  }
}

class MembershipCommuteBuilder
    implements Builder<MembershipCommute, MembershipCommuteBuilder> {
  _$MembershipCommute? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _routeId;
  String? get routeId => _$this._routeId;
  set routeId(String? routeId) => _$this._routeId = routeId;

  String? _routeName;
  String? get routeName => _$this._routeName;
  set routeName(String? routeName) => _$this._routeName = routeName;

  Date? _effectiveFrom;
  Date? get effectiveFrom => _$this._effectiveFrom;
  set effectiveFrom(Date? effectiveFrom) =>
      _$this._effectiveFrom = effectiveFrom;

  Date? _effectiveTo;
  Date? get effectiveTo => _$this._effectiveTo;
  set effectiveTo(Date? effectiveTo) => _$this._effectiveTo = effectiveTo;

  ListBuilder<CommuteLegView>? _legs;
  ListBuilder<CommuteLegView> get legs =>
      _$this._legs ??= ListBuilder<CommuteLegView>();
  set legs(ListBuilder<CommuteLegView>? legs) => _$this._legs = legs;

  MembershipCommuteBuilder() {
    MembershipCommute._defaults(this);
  }

  MembershipCommuteBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _routeId = $v.routeId;
      _routeName = $v.routeName;
      _effectiveFrom = $v.effectiveFrom;
      _effectiveTo = $v.effectiveTo;
      _legs = $v.legs.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MembershipCommute other) {
    _$v = other as _$MembershipCommute;
  }

  @override
  void update(void Function(MembershipCommuteBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MembershipCommute build() => _build();

  _$MembershipCommute _build() {
    _$MembershipCommute _$result;
    try {
      _$result = _$v ??
          _$MembershipCommute._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'MembershipCommute', 'id'),
            routeId: BuiltValueNullFieldError.checkNotNull(
                routeId, r'MembershipCommute', 'routeId'),
            routeName: BuiltValueNullFieldError.checkNotNull(
                routeName, r'MembershipCommute', 'routeName'),
            effectiveFrom: BuiltValueNullFieldError.checkNotNull(
                effectiveFrom, r'MembershipCommute', 'effectiveFrom'),
            effectiveTo: effectiveTo,
            legs: legs.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'legs';
        legs.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'MembershipCommute', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
