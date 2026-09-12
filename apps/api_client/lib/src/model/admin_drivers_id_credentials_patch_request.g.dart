// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_drivers_id_credentials_patch_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminDriversIdCredentialsPatchRequestStatusEnum
    _$adminDriversIdCredentialsPatchRequestStatusEnum_active =
    const AdminDriversIdCredentialsPatchRequestStatusEnum._('active');
const AdminDriversIdCredentialsPatchRequestStatusEnum
    _$adminDriversIdCredentialsPatchRequestStatusEnum_suspended =
    const AdminDriversIdCredentialsPatchRequestStatusEnum._('suspended');

AdminDriversIdCredentialsPatchRequestStatusEnum
    _$adminDriversIdCredentialsPatchRequestStatusEnumValueOf(String name) {
  switch (name) {
    case 'active':
      return _$adminDriversIdCredentialsPatchRequestStatusEnum_active;
    case 'suspended':
      return _$adminDriversIdCredentialsPatchRequestStatusEnum_suspended;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<AdminDriversIdCredentialsPatchRequestStatusEnum>
    _$adminDriversIdCredentialsPatchRequestStatusEnumValues = BuiltSet<
        AdminDriversIdCredentialsPatchRequestStatusEnum>(const <AdminDriversIdCredentialsPatchRequestStatusEnum>[
  _$adminDriversIdCredentialsPatchRequestStatusEnum_active,
  _$adminDriversIdCredentialsPatchRequestStatusEnum_suspended,
]);

Serializer<AdminDriversIdCredentialsPatchRequestStatusEnum>
    _$adminDriversIdCredentialsPatchRequestStatusEnumSerializer =
    _$AdminDriversIdCredentialsPatchRequestStatusEnumSerializer();

class _$AdminDriversIdCredentialsPatchRequestStatusEnumSerializer
    implements
        PrimitiveSerializer<AdminDriversIdCredentialsPatchRequestStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'active': 'active',
    'suspended': 'suspended',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'active': 'active',
    'suspended': 'suspended',
  };

  @override
  final Iterable<Type> types = const <Type>[
    AdminDriversIdCredentialsPatchRequestStatusEnum
  ];
  @override
  final String wireName = 'AdminDriversIdCredentialsPatchRequestStatusEnum';

  @override
  Object serialize(Serializers serializers,
          AdminDriversIdCredentialsPatchRequestStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  AdminDriversIdCredentialsPatchRequestStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      AdminDriversIdCredentialsPatchRequestStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$AdminDriversIdCredentialsPatchRequest
    extends AdminDriversIdCredentialsPatchRequest {
  @override
  final AdminDriversIdCredentialsPatchRequestStatusEnum? status;
  @override
  final bool? unlock;

  factory _$AdminDriversIdCredentialsPatchRequest(
          [void Function(AdminDriversIdCredentialsPatchRequestBuilder)?
              updates]) =>
      (AdminDriversIdCredentialsPatchRequestBuilder()..update(updates))
          ._build();

  _$AdminDriversIdCredentialsPatchRequest._({this.status, this.unlock})
      : super._();
  @override
  AdminDriversIdCredentialsPatchRequest rebuild(
          void Function(AdminDriversIdCredentialsPatchRequestBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminDriversIdCredentialsPatchRequestBuilder toBuilder() =>
      AdminDriversIdCredentialsPatchRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminDriversIdCredentialsPatchRequest &&
        status == other.status &&
        unlock == other.unlock;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, unlock.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'AdminDriversIdCredentialsPatchRequest')
          ..add('status', status)
          ..add('unlock', unlock))
        .toString();
  }
}

class AdminDriversIdCredentialsPatchRequestBuilder
    implements
        Builder<AdminDriversIdCredentialsPatchRequest,
            AdminDriversIdCredentialsPatchRequestBuilder> {
  _$AdminDriversIdCredentialsPatchRequest? _$v;

  AdminDriversIdCredentialsPatchRequestStatusEnum? _status;
  AdminDriversIdCredentialsPatchRequestStatusEnum? get status => _$this._status;
  set status(AdminDriversIdCredentialsPatchRequestStatusEnum? status) =>
      _$this._status = status;

  bool? _unlock;
  bool? get unlock => _$this._unlock;
  set unlock(bool? unlock) => _$this._unlock = unlock;

  AdminDriversIdCredentialsPatchRequestBuilder() {
    AdminDriversIdCredentialsPatchRequest._defaults(this);
  }

  AdminDriversIdCredentialsPatchRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _status = $v.status;
      _unlock = $v.unlock;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminDriversIdCredentialsPatchRequest other) {
    _$v = other as _$AdminDriversIdCredentialsPatchRequest;
  }

  @override
  void update(
      void Function(AdminDriversIdCredentialsPatchRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminDriversIdCredentialsPatchRequest build() => _build();

  _$AdminDriversIdCredentialsPatchRequest _build() {
    final _$result = _$v ??
        _$AdminDriversIdCredentialsPatchRequest._(
          status: status,
          unlock: unlock,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
