// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ops_team_entry.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const OpsTeamEntryKindEnum _$opsTeamEntryKindEnum_member =
    const OpsTeamEntryKindEnum._('member');
const OpsTeamEntryKindEnum _$opsTeamEntryKindEnum_invitation =
    const OpsTeamEntryKindEnum._('invitation');

OpsTeamEntryKindEnum _$opsTeamEntryKindEnumValueOf(String name) {
  switch (name) {
    case 'member':
      return _$opsTeamEntryKindEnum_member;
    case 'invitation':
      return _$opsTeamEntryKindEnum_invitation;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<OpsTeamEntryKindEnum> _$opsTeamEntryKindEnumValues =
    BuiltSet<OpsTeamEntryKindEnum>(const <OpsTeamEntryKindEnum>[
  _$opsTeamEntryKindEnum_member,
  _$opsTeamEntryKindEnum_invitation,
]);

const OpsTeamEntryStateEnum _$opsTeamEntryStateEnum_active =
    const OpsTeamEntryStateEnum._('active');
const OpsTeamEntryStateEnum _$opsTeamEntryStateEnum_pending =
    const OpsTeamEntryStateEnum._('pending');
const OpsTeamEntryStateEnum _$opsTeamEntryStateEnum_claimed =
    const OpsTeamEntryStateEnum._('claimed');
const OpsTeamEntryStateEnum _$opsTeamEntryStateEnum_expired =
    const OpsTeamEntryStateEnum._('expired');
const OpsTeamEntryStateEnum _$opsTeamEntryStateEnum_cancelled =
    const OpsTeamEntryStateEnum._('cancelled');

OpsTeamEntryStateEnum _$opsTeamEntryStateEnumValueOf(String name) {
  switch (name) {
    case 'active':
      return _$opsTeamEntryStateEnum_active;
    case 'pending':
      return _$opsTeamEntryStateEnum_pending;
    case 'claimed':
      return _$opsTeamEntryStateEnum_claimed;
    case 'expired':
      return _$opsTeamEntryStateEnum_expired;
    case 'cancelled':
      return _$opsTeamEntryStateEnum_cancelled;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<OpsTeamEntryStateEnum> _$opsTeamEntryStateEnumValues =
    BuiltSet<OpsTeamEntryStateEnum>(const <OpsTeamEntryStateEnum>[
  _$opsTeamEntryStateEnum_active,
  _$opsTeamEntryStateEnum_pending,
  _$opsTeamEntryStateEnum_claimed,
  _$opsTeamEntryStateEnum_expired,
  _$opsTeamEntryStateEnum_cancelled,
]);

const OpsTeamEntryEmailStateEnum _$opsTeamEntryEmailStateEnum_pending =
    const OpsTeamEntryEmailStateEnum._('pending');
const OpsTeamEntryEmailStateEnum _$opsTeamEntryEmailStateEnum_accepted =
    const OpsTeamEntryEmailStateEnum._('accepted');
const OpsTeamEntryEmailStateEnum _$opsTeamEntryEmailStateEnum_cancelled =
    const OpsTeamEntryEmailStateEnum._('cancelled');
const OpsTeamEntryEmailStateEnum _$opsTeamEntryEmailStateEnum_failed =
    const OpsTeamEntryEmailStateEnum._('failed');
const OpsTeamEntryEmailStateEnum _$opsTeamEntryEmailStateEnum_unknown =
    const OpsTeamEntryEmailStateEnum._('unknown');

OpsTeamEntryEmailStateEnum _$opsTeamEntryEmailStateEnumValueOf(String name) {
  switch (name) {
    case 'pending':
      return _$opsTeamEntryEmailStateEnum_pending;
    case 'accepted':
      return _$opsTeamEntryEmailStateEnum_accepted;
    case 'cancelled':
      return _$opsTeamEntryEmailStateEnum_cancelled;
    case 'failed':
      return _$opsTeamEntryEmailStateEnum_failed;
    case 'unknown':
      return _$opsTeamEntryEmailStateEnum_unknown;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<OpsTeamEntryEmailStateEnum> _$opsTeamEntryEmailStateEnumValues =
    BuiltSet<OpsTeamEntryEmailStateEnum>(const <OpsTeamEntryEmailStateEnum>[
  _$opsTeamEntryEmailStateEnum_pending,
  _$opsTeamEntryEmailStateEnum_accepted,
  _$opsTeamEntryEmailStateEnum_cancelled,
  _$opsTeamEntryEmailStateEnum_failed,
  _$opsTeamEntryEmailStateEnum_unknown,
]);

Serializer<OpsTeamEntryKindEnum> _$opsTeamEntryKindEnumSerializer =
    _$OpsTeamEntryKindEnumSerializer();
Serializer<OpsTeamEntryStateEnum> _$opsTeamEntryStateEnumSerializer =
    _$OpsTeamEntryStateEnumSerializer();
Serializer<OpsTeamEntryEmailStateEnum> _$opsTeamEntryEmailStateEnumSerializer =
    _$OpsTeamEntryEmailStateEnumSerializer();

class _$OpsTeamEntryKindEnumSerializer
    implements PrimitiveSerializer<OpsTeamEntryKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'member': 'member',
    'invitation': 'invitation',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'member': 'member',
    'invitation': 'invitation',
  };

  @override
  final Iterable<Type> types = const <Type>[OpsTeamEntryKindEnum];
  @override
  final String wireName = 'OpsTeamEntryKindEnum';

  @override
  Object serialize(Serializers serializers, OpsTeamEntryKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  OpsTeamEntryKindEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      OpsTeamEntryKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$OpsTeamEntryStateEnumSerializer
    implements PrimitiveSerializer<OpsTeamEntryStateEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'active': 'active',
    'pending': 'pending',
    'claimed': 'claimed',
    'expired': 'expired',
    'cancelled': 'cancelled',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'active': 'active',
    'pending': 'pending',
    'claimed': 'claimed',
    'expired': 'expired',
    'cancelled': 'cancelled',
  };

  @override
  final Iterable<Type> types = const <Type>[OpsTeamEntryStateEnum];
  @override
  final String wireName = 'OpsTeamEntryStateEnum';

  @override
  Object serialize(Serializers serializers, OpsTeamEntryStateEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  OpsTeamEntryStateEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      OpsTeamEntryStateEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$OpsTeamEntryEmailStateEnumSerializer
    implements PrimitiveSerializer<OpsTeamEntryEmailStateEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'pending': 'pending',
    'accepted': 'accepted',
    'cancelled': 'cancelled',
    'failed': 'failed',
    'unknown': 'unknown',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'pending': 'pending',
    'accepted': 'accepted',
    'cancelled': 'cancelled',
    'failed': 'failed',
    'unknown': 'unknown',
  };

  @override
  final Iterable<Type> types = const <Type>[OpsTeamEntryEmailStateEnum];
  @override
  final String wireName = 'OpsTeamEntryEmailStateEnum';

  @override
  Object serialize(Serializers serializers, OpsTeamEntryEmailStateEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  OpsTeamEntryEmailStateEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      OpsTeamEntryEmailStateEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$OpsTeamEntry extends OpsTeamEntry {
  @override
  final String id;
  @override
  final String name;
  @override
  final String? email;
  @override
  final OpsTeamEntryKindEnum kind;
  @override
  final OpsTeamEntryStateEnum state;
  @override
  final bool isSuperadmin;
  @override
  final DateTime? expiresAt;
  @override
  final OpsTeamEntryEmailStateEnum? emailState;

  factory _$OpsTeamEntry([void Function(OpsTeamEntryBuilder)? updates]) =>
      (OpsTeamEntryBuilder()..update(updates))._build();

  _$OpsTeamEntry._(
      {required this.id,
      required this.name,
      this.email,
      required this.kind,
      required this.state,
      required this.isSuperadmin,
      this.expiresAt,
      this.emailState})
      : super._();
  @override
  OpsTeamEntry rebuild(void Function(OpsTeamEntryBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OpsTeamEntryBuilder toBuilder() => OpsTeamEntryBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OpsTeamEntry &&
        id == other.id &&
        name == other.name &&
        email == other.email &&
        kind == other.kind &&
        state == other.state &&
        isSuperadmin == other.isSuperadmin &&
        expiresAt == other.expiresAt &&
        emailState == other.emailState;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, state.hashCode);
    _$hash = $jc(_$hash, isSuperadmin.hashCode);
    _$hash = $jc(_$hash, expiresAt.hashCode);
    _$hash = $jc(_$hash, emailState.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OpsTeamEntry')
          ..add('id', id)
          ..add('name', name)
          ..add('email', email)
          ..add('kind', kind)
          ..add('state', state)
          ..add('isSuperadmin', isSuperadmin)
          ..add('expiresAt', expiresAt)
          ..add('emailState', emailState))
        .toString();
  }
}

class OpsTeamEntryBuilder
    implements Builder<OpsTeamEntry, OpsTeamEntryBuilder> {
  _$OpsTeamEntry? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  OpsTeamEntryKindEnum? _kind;
  OpsTeamEntryKindEnum? get kind => _$this._kind;
  set kind(OpsTeamEntryKindEnum? kind) => _$this._kind = kind;

  OpsTeamEntryStateEnum? _state;
  OpsTeamEntryStateEnum? get state => _$this._state;
  set state(OpsTeamEntryStateEnum? state) => _$this._state = state;

  bool? _isSuperadmin;
  bool? get isSuperadmin => _$this._isSuperadmin;
  set isSuperadmin(bool? isSuperadmin) => _$this._isSuperadmin = isSuperadmin;

  DateTime? _expiresAt;
  DateTime? get expiresAt => _$this._expiresAt;
  set expiresAt(DateTime? expiresAt) => _$this._expiresAt = expiresAt;

  OpsTeamEntryEmailStateEnum? _emailState;
  OpsTeamEntryEmailStateEnum? get emailState => _$this._emailState;
  set emailState(OpsTeamEntryEmailStateEnum? emailState) =>
      _$this._emailState = emailState;

  OpsTeamEntryBuilder() {
    OpsTeamEntry._defaults(this);
  }

  OpsTeamEntryBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _email = $v.email;
      _kind = $v.kind;
      _state = $v.state;
      _isSuperadmin = $v.isSuperadmin;
      _expiresAt = $v.expiresAt;
      _emailState = $v.emailState;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OpsTeamEntry other) {
    _$v = other as _$OpsTeamEntry;
  }

  @override
  void update(void Function(OpsTeamEntryBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OpsTeamEntry build() => _build();

  _$OpsTeamEntry _build() {
    final _$result = _$v ??
        _$OpsTeamEntry._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'OpsTeamEntry', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'OpsTeamEntry', 'name'),
          email: email,
          kind: BuiltValueNullFieldError.checkNotNull(
              kind, r'OpsTeamEntry', 'kind'),
          state: BuiltValueNullFieldError.checkNotNull(
              state, r'OpsTeamEntry', 'state'),
          isSuperadmin: BuiltValueNullFieldError.checkNotNull(
              isSuperadmin, r'OpsTeamEntry', 'isSuperadmin'),
          expiresAt: expiresAt,
          emailState: emailState,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
