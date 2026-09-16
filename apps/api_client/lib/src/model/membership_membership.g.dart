// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membership_membership.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MembershipMembershipLifecycleEnum
    _$membershipMembershipLifecycleEnum_open =
    const MembershipMembershipLifecycleEnum._('open');
const MembershipMembershipLifecycleEnum
    _$membershipMembershipLifecycleEnum_ended =
    const MembershipMembershipLifecycleEnum._('ended');

MembershipMembershipLifecycleEnum _$membershipMembershipLifecycleEnumValueOf(
    String name) {
  switch (name) {
    case 'open':
      return _$membershipMembershipLifecycleEnum_open;
    case 'ended':
      return _$membershipMembershipLifecycleEnum_ended;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<MembershipMembershipLifecycleEnum>
    _$membershipMembershipLifecycleEnumValues = BuiltSet<
        MembershipMembershipLifecycleEnum>(const <MembershipMembershipLifecycleEnum>[
  _$membershipMembershipLifecycleEnum_open,
  _$membershipMembershipLifecycleEnum_ended,
]);

Serializer<MembershipMembershipLifecycleEnum>
    _$membershipMembershipLifecycleEnumSerializer =
    _$MembershipMembershipLifecycleEnumSerializer();

class _$MembershipMembershipLifecycleEnumSerializer
    implements PrimitiveSerializer<MembershipMembershipLifecycleEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'open': 'open',
    'ended': 'ended',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'open': 'open',
    'ended': 'ended',
  };

  @override
  final Iterable<Type> types = const <Type>[MembershipMembershipLifecycleEnum];
  @override
  final String wireName = 'MembershipMembershipLifecycleEnum';

  @override
  Object serialize(
          Serializers serializers, MembershipMembershipLifecycleEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  MembershipMembershipLifecycleEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      MembershipMembershipLifecycleEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$MembershipMembership extends MembershipMembership {
  @override
  final String id;
  @override
  final MembershipMembershipLifecycleEnum lifecycle;

  factory _$MembershipMembership(
          [void Function(MembershipMembershipBuilder)? updates]) =>
      (MembershipMembershipBuilder()..update(updates))._build();

  _$MembershipMembership._({required this.id, required this.lifecycle})
      : super._();
  @override
  MembershipMembership rebuild(
          void Function(MembershipMembershipBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MembershipMembershipBuilder toBuilder() =>
      MembershipMembershipBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MembershipMembership &&
        id == other.id &&
        lifecycle == other.lifecycle;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, lifecycle.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MembershipMembership')
          ..add('id', id)
          ..add('lifecycle', lifecycle))
        .toString();
  }
}

class MembershipMembershipBuilder
    implements Builder<MembershipMembership, MembershipMembershipBuilder> {
  _$MembershipMembership? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  MembershipMembershipLifecycleEnum? _lifecycle;
  MembershipMembershipLifecycleEnum? get lifecycle => _$this._lifecycle;
  set lifecycle(MembershipMembershipLifecycleEnum? lifecycle) =>
      _$this._lifecycle = lifecycle;

  MembershipMembershipBuilder() {
    MembershipMembership._defaults(this);
  }

  MembershipMembershipBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _lifecycle = $v.lifecycle;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MembershipMembership other) {
    _$v = other as _$MembershipMembership;
  }

  @override
  void update(void Function(MembershipMembershipBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MembershipMembership build() => _build();

  _$MembershipMembership _build() {
    final _$result = _$v ??
        _$MembershipMembership._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'MembershipMembership', 'id'),
          lifecycle: BuiltValueNullFieldError.checkNotNull(
              lifecycle, r'MembershipMembership', 'lifecycle'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
