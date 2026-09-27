// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ops_rider.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const OpsRiderRoleEnum _$opsRiderRoleEnum_commuter =
    const OpsRiderRoleEnum._('commuter');
const OpsRiderRoleEnum _$opsRiderRoleEnum_driver =
    const OpsRiderRoleEnum._('driver');
const OpsRiderRoleEnum _$opsRiderRoleEnum_admin =
    const OpsRiderRoleEnum._('admin');

OpsRiderRoleEnum _$opsRiderRoleEnumValueOf(String name) {
  switch (name) {
    case 'commuter':
      return _$opsRiderRoleEnum_commuter;
    case 'driver':
      return _$opsRiderRoleEnum_driver;
    case 'admin':
      return _$opsRiderRoleEnum_admin;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<OpsRiderRoleEnum> _$opsRiderRoleEnumValues =
    BuiltSet<OpsRiderRoleEnum>(const <OpsRiderRoleEnum>[
  _$opsRiderRoleEnum_commuter,
  _$opsRiderRoleEnum_driver,
  _$opsRiderRoleEnum_admin,
]);

const OpsRiderStatusEnum _$opsRiderStatusEnum_active =
    const OpsRiderStatusEnum._('active');
const OpsRiderStatusEnum _$opsRiderStatusEnum_paused =
    const OpsRiderStatusEnum._('paused');
const OpsRiderStatusEnum _$opsRiderStatusEnum_lapsed =
    const OpsRiderStatusEnum._('lapsed');
const OpsRiderStatusEnum _$opsRiderStatusEnum_none =
    const OpsRiderStatusEnum._('none');

OpsRiderStatusEnum _$opsRiderStatusEnumValueOf(String name) {
  switch (name) {
    case 'active':
      return _$opsRiderStatusEnum_active;
    case 'paused':
      return _$opsRiderStatusEnum_paused;
    case 'lapsed':
      return _$opsRiderStatusEnum_lapsed;
    case 'none':
      return _$opsRiderStatusEnum_none;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<OpsRiderStatusEnum> _$opsRiderStatusEnumValues =
    BuiltSet<OpsRiderStatusEnum>(const <OpsRiderStatusEnum>[
  _$opsRiderStatusEnum_active,
  _$opsRiderStatusEnum_paused,
  _$opsRiderStatusEnum_lapsed,
  _$opsRiderStatusEnum_none,
]);

const OpsRiderPlanEnum _$opsRiderPlanEnum_monthly =
    const OpsRiderPlanEnum._('monthly');
const OpsRiderPlanEnum _$opsRiderPlanEnum_annual =
    const OpsRiderPlanEnum._('annual');

OpsRiderPlanEnum _$opsRiderPlanEnumValueOf(String name) {
  switch (name) {
    case 'monthly':
      return _$opsRiderPlanEnum_monthly;
    case 'annual':
      return _$opsRiderPlanEnum_annual;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<OpsRiderPlanEnum> _$opsRiderPlanEnumValues =
    BuiltSet<OpsRiderPlanEnum>(const <OpsRiderPlanEnum>[
  _$opsRiderPlanEnum_monthly,
  _$opsRiderPlanEnum_annual,
]);

Serializer<OpsRiderRoleEnum> _$opsRiderRoleEnumSerializer =
    _$OpsRiderRoleEnumSerializer();
Serializer<OpsRiderStatusEnum> _$opsRiderStatusEnumSerializer =
    _$OpsRiderStatusEnumSerializer();
Serializer<OpsRiderPlanEnum> _$opsRiderPlanEnumSerializer =
    _$OpsRiderPlanEnumSerializer();

class _$OpsRiderRoleEnumSerializer
    implements PrimitiveSerializer<OpsRiderRoleEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'commuter': 'commuter',
    'driver': 'driver',
    'admin': 'admin',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'commuter': 'commuter',
    'driver': 'driver',
    'admin': 'admin',
  };

  @override
  final Iterable<Type> types = const <Type>[OpsRiderRoleEnum];
  @override
  final String wireName = 'OpsRiderRoleEnum';

  @override
  Object serialize(Serializers serializers, OpsRiderRoleEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  OpsRiderRoleEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      OpsRiderRoleEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$OpsRiderStatusEnumSerializer
    implements PrimitiveSerializer<OpsRiderStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'active': 'active',
    'paused': 'paused',
    'lapsed': 'lapsed',
    'none': 'none',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'active': 'active',
    'paused': 'paused',
    'lapsed': 'lapsed',
    'none': 'none',
  };

  @override
  final Iterable<Type> types = const <Type>[OpsRiderStatusEnum];
  @override
  final String wireName = 'OpsRiderStatusEnum';

  @override
  Object serialize(Serializers serializers, OpsRiderStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  OpsRiderStatusEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      OpsRiderStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$OpsRiderPlanEnumSerializer
    implements PrimitiveSerializer<OpsRiderPlanEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'monthly': 'monthly',
    'annual': 'annual',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'monthly': 'monthly',
    'annual': 'annual',
  };

  @override
  final Iterable<Type> types = const <Type>[OpsRiderPlanEnum];
  @override
  final String wireName = 'OpsRiderPlanEnum';

  @override
  Object serialize(Serializers serializers, OpsRiderPlanEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  OpsRiderPlanEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      OpsRiderPlanEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$OpsRider extends OpsRider {
  @override
  final String id;
  @override
  final String displayName;
  @override
  final String? phone;
  @override
  final String? email;
  @override
  final OpsRiderRoleEnum role;
  @override
  final OpsRiderStatusEnum status;
  @override
  final OpsRiderPlanEnum? plan;
  @override
  final String? routeName;
  @override
  final int? ridesLeft;
  @override
  final Money availableCredit;
  @override
  final DateTime joinedAt;
  @override
  final String editToken;

  factory _$OpsRider([void Function(OpsRiderBuilder)? updates]) =>
      (OpsRiderBuilder()..update(updates))._build();

  _$OpsRider._(
      {required this.id,
      required this.displayName,
      this.phone,
      this.email,
      required this.role,
      required this.status,
      this.plan,
      this.routeName,
      this.ridesLeft,
      required this.availableCredit,
      required this.joinedAt,
      required this.editToken})
      : super._();
  @override
  OpsRider rebuild(void Function(OpsRiderBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OpsRiderBuilder toBuilder() => OpsRiderBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OpsRider &&
        id == other.id &&
        displayName == other.displayName &&
        phone == other.phone &&
        email == other.email &&
        role == other.role &&
        status == other.status &&
        plan == other.plan &&
        routeName == other.routeName &&
        ridesLeft == other.ridesLeft &&
        availableCredit == other.availableCredit &&
        joinedAt == other.joinedAt &&
        editToken == other.editToken;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jc(_$hash, phone.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, plan.hashCode);
    _$hash = $jc(_$hash, routeName.hashCode);
    _$hash = $jc(_$hash, ridesLeft.hashCode);
    _$hash = $jc(_$hash, availableCredit.hashCode);
    _$hash = $jc(_$hash, joinedAt.hashCode);
    _$hash = $jc(_$hash, editToken.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OpsRider')
          ..add('id', id)
          ..add('displayName', displayName)
          ..add('phone', phone)
          ..add('email', email)
          ..add('role', role)
          ..add('status', status)
          ..add('plan', plan)
          ..add('routeName', routeName)
          ..add('ridesLeft', ridesLeft)
          ..add('availableCredit', availableCredit)
          ..add('joinedAt', joinedAt)
          ..add('editToken', editToken))
        .toString();
  }
}

class OpsRiderBuilder implements Builder<OpsRider, OpsRiderBuilder> {
  _$OpsRider? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _displayName;
  String? get displayName => _$this._displayName;
  set displayName(String? displayName) => _$this._displayName = displayName;

  String? _phone;
  String? get phone => _$this._phone;
  set phone(String? phone) => _$this._phone = phone;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  OpsRiderRoleEnum? _role;
  OpsRiderRoleEnum? get role => _$this._role;
  set role(OpsRiderRoleEnum? role) => _$this._role = role;

  OpsRiderStatusEnum? _status;
  OpsRiderStatusEnum? get status => _$this._status;
  set status(OpsRiderStatusEnum? status) => _$this._status = status;

  OpsRiderPlanEnum? _plan;
  OpsRiderPlanEnum? get plan => _$this._plan;
  set plan(OpsRiderPlanEnum? plan) => _$this._plan = plan;

  String? _routeName;
  String? get routeName => _$this._routeName;
  set routeName(String? routeName) => _$this._routeName = routeName;

  int? _ridesLeft;
  int? get ridesLeft => _$this._ridesLeft;
  set ridesLeft(int? ridesLeft) => _$this._ridesLeft = ridesLeft;

  MoneyBuilder? _availableCredit;
  MoneyBuilder get availableCredit =>
      _$this._availableCredit ??= MoneyBuilder();
  set availableCredit(MoneyBuilder? availableCredit) =>
      _$this._availableCredit = availableCredit;

  DateTime? _joinedAt;
  DateTime? get joinedAt => _$this._joinedAt;
  set joinedAt(DateTime? joinedAt) => _$this._joinedAt = joinedAt;

  String? _editToken;
  String? get editToken => _$this._editToken;
  set editToken(String? editToken) => _$this._editToken = editToken;

  OpsRiderBuilder() {
    OpsRider._defaults(this);
  }

  OpsRiderBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _displayName = $v.displayName;
      _phone = $v.phone;
      _email = $v.email;
      _role = $v.role;
      _status = $v.status;
      _plan = $v.plan;
      _routeName = $v.routeName;
      _ridesLeft = $v.ridesLeft;
      _availableCredit = $v.availableCredit.toBuilder();
      _joinedAt = $v.joinedAt;
      _editToken = $v.editToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OpsRider other) {
    _$v = other as _$OpsRider;
  }

  @override
  void update(void Function(OpsRiderBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OpsRider build() => _build();

  _$OpsRider _build() {
    _$OpsRider _$result;
    try {
      _$result = _$v ??
          _$OpsRider._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'OpsRider', 'id'),
            displayName: BuiltValueNullFieldError.checkNotNull(
                displayName, r'OpsRider', 'displayName'),
            phone: phone,
            email: email,
            role: BuiltValueNullFieldError.checkNotNull(
                role, r'OpsRider', 'role'),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'OpsRider', 'status'),
            plan: plan,
            routeName: routeName,
            ridesLeft: ridesLeft,
            availableCredit: availableCredit.build(),
            joinedAt: BuiltValueNullFieldError.checkNotNull(
                joinedAt, r'OpsRider', 'joinedAt'),
            editToken: BuiltValueNullFieldError.checkNotNull(
                editToken, r'OpsRider', 'editToken'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'availableCredit';
        availableCredit.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'OpsRider', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
