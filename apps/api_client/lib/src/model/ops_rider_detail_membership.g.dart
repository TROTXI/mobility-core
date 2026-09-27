// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ops_rider_detail_membership.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const OpsRiderDetailMembershipLifecycleEnum
    _$opsRiderDetailMembershipLifecycleEnum_open =
    const OpsRiderDetailMembershipLifecycleEnum._('open');
const OpsRiderDetailMembershipLifecycleEnum
    _$opsRiderDetailMembershipLifecycleEnum_ended =
    const OpsRiderDetailMembershipLifecycleEnum._('ended');

OpsRiderDetailMembershipLifecycleEnum
    _$opsRiderDetailMembershipLifecycleEnumValueOf(String name) {
  switch (name) {
    case 'open':
      return _$opsRiderDetailMembershipLifecycleEnum_open;
    case 'ended':
      return _$opsRiderDetailMembershipLifecycleEnum_ended;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<OpsRiderDetailMembershipLifecycleEnum>
    _$opsRiderDetailMembershipLifecycleEnumValues = BuiltSet<
        OpsRiderDetailMembershipLifecycleEnum>(const <OpsRiderDetailMembershipLifecycleEnum>[
  _$opsRiderDetailMembershipLifecycleEnum_open,
  _$opsRiderDetailMembershipLifecycleEnum_ended,
]);

Serializer<OpsRiderDetailMembershipLifecycleEnum>
    _$opsRiderDetailMembershipLifecycleEnumSerializer =
    _$OpsRiderDetailMembershipLifecycleEnumSerializer();

class _$OpsRiderDetailMembershipLifecycleEnumSerializer
    implements PrimitiveSerializer<OpsRiderDetailMembershipLifecycleEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'open': 'open',
    'ended': 'ended',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'open': 'open',
    'ended': 'ended',
  };

  @override
  final Iterable<Type> types = const <Type>[
    OpsRiderDetailMembershipLifecycleEnum
  ];
  @override
  final String wireName = 'OpsRiderDetailMembershipLifecycleEnum';

  @override
  Object serialize(
          Serializers serializers, OpsRiderDetailMembershipLifecycleEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  OpsRiderDetailMembershipLifecycleEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      OpsRiderDetailMembershipLifecycleEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$OpsRiderDetailMembership extends OpsRiderDetailMembership {
  @override
  final String id;
  @override
  final OpsRiderDetailMembershipLifecycleEnum lifecycle;
  @override
  final String? periodId;
  @override
  final DateTime? startsAt;
  @override
  final DateTime? endsAt;

  factory _$OpsRiderDetailMembership(
          [void Function(OpsRiderDetailMembershipBuilder)? updates]) =>
      (OpsRiderDetailMembershipBuilder()..update(updates))._build();

  _$OpsRiderDetailMembership._(
      {required this.id,
      required this.lifecycle,
      this.periodId,
      this.startsAt,
      this.endsAt})
      : super._();
  @override
  OpsRiderDetailMembership rebuild(
          void Function(OpsRiderDetailMembershipBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OpsRiderDetailMembershipBuilder toBuilder() =>
      OpsRiderDetailMembershipBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OpsRiderDetailMembership &&
        id == other.id &&
        lifecycle == other.lifecycle &&
        periodId == other.periodId &&
        startsAt == other.startsAt &&
        endsAt == other.endsAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, lifecycle.hashCode);
    _$hash = $jc(_$hash, periodId.hashCode);
    _$hash = $jc(_$hash, startsAt.hashCode);
    _$hash = $jc(_$hash, endsAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OpsRiderDetailMembership')
          ..add('id', id)
          ..add('lifecycle', lifecycle)
          ..add('periodId', periodId)
          ..add('startsAt', startsAt)
          ..add('endsAt', endsAt))
        .toString();
  }
}

class OpsRiderDetailMembershipBuilder
    implements
        Builder<OpsRiderDetailMembership, OpsRiderDetailMembershipBuilder> {
  _$OpsRiderDetailMembership? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  OpsRiderDetailMembershipLifecycleEnum? _lifecycle;
  OpsRiderDetailMembershipLifecycleEnum? get lifecycle => _$this._lifecycle;
  set lifecycle(OpsRiderDetailMembershipLifecycleEnum? lifecycle) =>
      _$this._lifecycle = lifecycle;

  String? _periodId;
  String? get periodId => _$this._periodId;
  set periodId(String? periodId) => _$this._periodId = periodId;

  DateTime? _startsAt;
  DateTime? get startsAt => _$this._startsAt;
  set startsAt(DateTime? startsAt) => _$this._startsAt = startsAt;

  DateTime? _endsAt;
  DateTime? get endsAt => _$this._endsAt;
  set endsAt(DateTime? endsAt) => _$this._endsAt = endsAt;

  OpsRiderDetailMembershipBuilder() {
    OpsRiderDetailMembership._defaults(this);
  }

  OpsRiderDetailMembershipBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _lifecycle = $v.lifecycle;
      _periodId = $v.periodId;
      _startsAt = $v.startsAt;
      _endsAt = $v.endsAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OpsRiderDetailMembership other) {
    _$v = other as _$OpsRiderDetailMembership;
  }

  @override
  void update(void Function(OpsRiderDetailMembershipBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OpsRiderDetailMembership build() => _build();

  _$OpsRiderDetailMembership _build() {
    final _$result = _$v ??
        _$OpsRiderDetailMembership._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'OpsRiderDetailMembership', 'id'),
          lifecycle: BuiltValueNullFieldError.checkNotNull(
              lifecycle, r'OpsRiderDetailMembership', 'lifecycle'),
          periodId: periodId,
          startsAt: startsAt,
          endsAt: endsAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
