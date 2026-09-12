// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_incidents_id_patch_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminIncidentsIdPatchRequestStatusEnum
    _$adminIncidentsIdPatchRequestStatusEnum_acknowledged =
    const AdminIncidentsIdPatchRequestStatusEnum._('acknowledged');
const AdminIncidentsIdPatchRequestStatusEnum
    _$adminIncidentsIdPatchRequestStatusEnum_resolved =
    const AdminIncidentsIdPatchRequestStatusEnum._('resolved');

AdminIncidentsIdPatchRequestStatusEnum
    _$adminIncidentsIdPatchRequestStatusEnumValueOf(String name) {
  switch (name) {
    case 'acknowledged':
      return _$adminIncidentsIdPatchRequestStatusEnum_acknowledged;
    case 'resolved':
      return _$adminIncidentsIdPatchRequestStatusEnum_resolved;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<AdminIncidentsIdPatchRequestStatusEnum>
    _$adminIncidentsIdPatchRequestStatusEnumValues = BuiltSet<
        AdminIncidentsIdPatchRequestStatusEnum>(const <AdminIncidentsIdPatchRequestStatusEnum>[
  _$adminIncidentsIdPatchRequestStatusEnum_acknowledged,
  _$adminIncidentsIdPatchRequestStatusEnum_resolved,
]);

Serializer<AdminIncidentsIdPatchRequestStatusEnum>
    _$adminIncidentsIdPatchRequestStatusEnumSerializer =
    _$AdminIncidentsIdPatchRequestStatusEnumSerializer();

class _$AdminIncidentsIdPatchRequestStatusEnumSerializer
    implements PrimitiveSerializer<AdminIncidentsIdPatchRequestStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'acknowledged': 'acknowledged',
    'resolved': 'resolved',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'acknowledged': 'acknowledged',
    'resolved': 'resolved',
  };

  @override
  final Iterable<Type> types = const <Type>[
    AdminIncidentsIdPatchRequestStatusEnum
  ];
  @override
  final String wireName = 'AdminIncidentsIdPatchRequestStatusEnum';

  @override
  Object serialize(Serializers serializers,
          AdminIncidentsIdPatchRequestStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  AdminIncidentsIdPatchRequestStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      AdminIncidentsIdPatchRequestStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$AdminIncidentsIdPatchRequest extends AdminIncidentsIdPatchRequest {
  @override
  final AdminIncidentsIdPatchRequestStatusEnum status;
  @override
  final String? resolution;

  factory _$AdminIncidentsIdPatchRequest(
          [void Function(AdminIncidentsIdPatchRequestBuilder)? updates]) =>
      (AdminIncidentsIdPatchRequestBuilder()..update(updates))._build();

  _$AdminIncidentsIdPatchRequest._({required this.status, this.resolution})
      : super._();
  @override
  AdminIncidentsIdPatchRequest rebuild(
          void Function(AdminIncidentsIdPatchRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminIncidentsIdPatchRequestBuilder toBuilder() =>
      AdminIncidentsIdPatchRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminIncidentsIdPatchRequest &&
        status == other.status &&
        resolution == other.resolution;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, resolution.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminIncidentsIdPatchRequest')
          ..add('status', status)
          ..add('resolution', resolution))
        .toString();
  }
}

class AdminIncidentsIdPatchRequestBuilder
    implements
        Builder<AdminIncidentsIdPatchRequest,
            AdminIncidentsIdPatchRequestBuilder> {
  _$AdminIncidentsIdPatchRequest? _$v;

  AdminIncidentsIdPatchRequestStatusEnum? _status;
  AdminIncidentsIdPatchRequestStatusEnum? get status => _$this._status;
  set status(AdminIncidentsIdPatchRequestStatusEnum? status) =>
      _$this._status = status;

  String? _resolution;
  String? get resolution => _$this._resolution;
  set resolution(String? resolution) => _$this._resolution = resolution;

  AdminIncidentsIdPatchRequestBuilder() {
    AdminIncidentsIdPatchRequest._defaults(this);
  }

  AdminIncidentsIdPatchRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _status = $v.status;
      _resolution = $v.resolution;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminIncidentsIdPatchRequest other) {
    _$v = other as _$AdminIncidentsIdPatchRequest;
  }

  @override
  void update(void Function(AdminIncidentsIdPatchRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminIncidentsIdPatchRequest build() => _build();

  _$AdminIncidentsIdPatchRequest _build() {
    final _$result = _$v ??
        _$AdminIncidentsIdPatchRequest._(
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'AdminIncidentsIdPatchRequest', 'status'),
          resolution: resolution,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
