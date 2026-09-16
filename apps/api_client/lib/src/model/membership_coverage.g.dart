// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membership_coverage.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MembershipCoverageStateEnum _$membershipCoverageStateEnum_open =
    const MembershipCoverageStateEnum._('open');
const MembershipCoverageStateEnum _$membershipCoverageStateEnum_closed =
    const MembershipCoverageStateEnum._('closed');
const MembershipCoverageStateEnum _$membershipCoverageStateEnum_reversed =
    const MembershipCoverageStateEnum._('reversed');

MembershipCoverageStateEnum _$membershipCoverageStateEnumValueOf(String name) {
  switch (name) {
    case 'open':
      return _$membershipCoverageStateEnum_open;
    case 'closed':
      return _$membershipCoverageStateEnum_closed;
    case 'reversed':
      return _$membershipCoverageStateEnum_reversed;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<MembershipCoverageStateEnum>
    _$membershipCoverageStateEnumValues =
    BuiltSet<MembershipCoverageStateEnum>(const <MembershipCoverageStateEnum>[
  _$membershipCoverageStateEnum_open,
  _$membershipCoverageStateEnum_closed,
  _$membershipCoverageStateEnum_reversed,
]);

const MembershipCoverageRenewalModeEnum
    _$membershipCoverageRenewalModeEnum_manual =
    const MembershipCoverageRenewalModeEnum._('manual');

MembershipCoverageRenewalModeEnum _$membershipCoverageRenewalModeEnumValueOf(
    String name) {
  switch (name) {
    case 'manual':
      return _$membershipCoverageRenewalModeEnum_manual;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<MembershipCoverageRenewalModeEnum>
    _$membershipCoverageRenewalModeEnumValues = BuiltSet<
        MembershipCoverageRenewalModeEnum>(const <MembershipCoverageRenewalModeEnum>[
  _$membershipCoverageRenewalModeEnum_manual,
]);

Serializer<MembershipCoverageStateEnum>
    _$membershipCoverageStateEnumSerializer =
    _$MembershipCoverageStateEnumSerializer();
Serializer<MembershipCoverageRenewalModeEnum>
    _$membershipCoverageRenewalModeEnumSerializer =
    _$MembershipCoverageRenewalModeEnumSerializer();

class _$MembershipCoverageStateEnumSerializer
    implements PrimitiveSerializer<MembershipCoverageStateEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'open': 'open',
    'closed': 'closed',
    'reversed': 'reversed',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'open': 'open',
    'closed': 'closed',
    'reversed': 'reversed',
  };

  @override
  final Iterable<Type> types = const <Type>[MembershipCoverageStateEnum];
  @override
  final String wireName = 'MembershipCoverageStateEnum';

  @override
  Object serialize(Serializers serializers, MembershipCoverageStateEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  MembershipCoverageStateEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      MembershipCoverageStateEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$MembershipCoverageRenewalModeEnumSerializer
    implements PrimitiveSerializer<MembershipCoverageRenewalModeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'manual': 'manual',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'manual': 'manual',
  };

  @override
  final Iterable<Type> types = const <Type>[MembershipCoverageRenewalModeEnum];
  @override
  final String wireName = 'MembershipCoverageRenewalModeEnum';

  @override
  Object serialize(
          Serializers serializers, MembershipCoverageRenewalModeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  MembershipCoverageRenewalModeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      MembershipCoverageRenewalModeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$MembershipCoverage extends MembershipCoverage {
  @override
  final String id;
  @override
  final DateTime startsAt;
  @override
  final DateTime? endsAt;
  @override
  final MembershipCoverageStateEnum state;
  @override
  final bool paused;
  @override
  final MembershipCoverageRenewalModeEnum renewalMode;

  factory _$MembershipCoverage(
          [void Function(MembershipCoverageBuilder)? updates]) =>
      (MembershipCoverageBuilder()..update(updates))._build();

  _$MembershipCoverage._(
      {required this.id,
      required this.startsAt,
      this.endsAt,
      required this.state,
      required this.paused,
      required this.renewalMode})
      : super._();
  @override
  MembershipCoverage rebuild(
          void Function(MembershipCoverageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MembershipCoverageBuilder toBuilder() =>
      MembershipCoverageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MembershipCoverage &&
        id == other.id &&
        startsAt == other.startsAt &&
        endsAt == other.endsAt &&
        state == other.state &&
        paused == other.paused &&
        renewalMode == other.renewalMode;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, startsAt.hashCode);
    _$hash = $jc(_$hash, endsAt.hashCode);
    _$hash = $jc(_$hash, state.hashCode);
    _$hash = $jc(_$hash, paused.hashCode);
    _$hash = $jc(_$hash, renewalMode.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MembershipCoverage')
          ..add('id', id)
          ..add('startsAt', startsAt)
          ..add('endsAt', endsAt)
          ..add('state', state)
          ..add('paused', paused)
          ..add('renewalMode', renewalMode))
        .toString();
  }
}

class MembershipCoverageBuilder
    implements Builder<MembershipCoverage, MembershipCoverageBuilder> {
  _$MembershipCoverage? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  DateTime? _startsAt;
  DateTime? get startsAt => _$this._startsAt;
  set startsAt(DateTime? startsAt) => _$this._startsAt = startsAt;

  DateTime? _endsAt;
  DateTime? get endsAt => _$this._endsAt;
  set endsAt(DateTime? endsAt) => _$this._endsAt = endsAt;

  MembershipCoverageStateEnum? _state;
  MembershipCoverageStateEnum? get state => _$this._state;
  set state(MembershipCoverageStateEnum? state) => _$this._state = state;

  bool? _paused;
  bool? get paused => _$this._paused;
  set paused(bool? paused) => _$this._paused = paused;

  MembershipCoverageRenewalModeEnum? _renewalMode;
  MembershipCoverageRenewalModeEnum? get renewalMode => _$this._renewalMode;
  set renewalMode(MembershipCoverageRenewalModeEnum? renewalMode) =>
      _$this._renewalMode = renewalMode;

  MembershipCoverageBuilder() {
    MembershipCoverage._defaults(this);
  }

  MembershipCoverageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _startsAt = $v.startsAt;
      _endsAt = $v.endsAt;
      _state = $v.state;
      _paused = $v.paused;
      _renewalMode = $v.renewalMode;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MembershipCoverage other) {
    _$v = other as _$MembershipCoverage;
  }

  @override
  void update(void Function(MembershipCoverageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MembershipCoverage build() => _build();

  _$MembershipCoverage _build() {
    final _$result = _$v ??
        _$MembershipCoverage._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'MembershipCoverage', 'id'),
          startsAt: BuiltValueNullFieldError.checkNotNull(
              startsAt, r'MembershipCoverage', 'startsAt'),
          endsAt: endsAt,
          state: BuiltValueNullFieldError.checkNotNull(
              state, r'MembershipCoverage', 'state'),
          paused: BuiltValueNullFieldError.checkNotNull(
              paused, r'MembershipCoverage', 'paused'),
          renewalMode: BuiltValueNullFieldError.checkNotNull(
              renewalMode, r'MembershipCoverage', 'renewalMode'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
