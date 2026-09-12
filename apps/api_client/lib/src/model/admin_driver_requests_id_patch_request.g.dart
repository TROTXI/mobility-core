// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_driver_requests_id_patch_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminDriverRequestsIdPatchRequestStatusEnum
    _$adminDriverRequestsIdPatchRequestStatusEnum_approved =
    const AdminDriverRequestsIdPatchRequestStatusEnum._('approved');
const AdminDriverRequestsIdPatchRequestStatusEnum
    _$adminDriverRequestsIdPatchRequestStatusEnum_declined =
    const AdminDriverRequestsIdPatchRequestStatusEnum._('declined');

AdminDriverRequestsIdPatchRequestStatusEnum
    _$adminDriverRequestsIdPatchRequestStatusEnumValueOf(String name) {
  switch (name) {
    case 'approved':
      return _$adminDriverRequestsIdPatchRequestStatusEnum_approved;
    case 'declined':
      return _$adminDriverRequestsIdPatchRequestStatusEnum_declined;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<AdminDriverRequestsIdPatchRequestStatusEnum>
    _$adminDriverRequestsIdPatchRequestStatusEnumValues = BuiltSet<
        AdminDriverRequestsIdPatchRequestStatusEnum>(const <AdminDriverRequestsIdPatchRequestStatusEnum>[
  _$adminDriverRequestsIdPatchRequestStatusEnum_approved,
  _$adminDriverRequestsIdPatchRequestStatusEnum_declined,
]);

Serializer<AdminDriverRequestsIdPatchRequestStatusEnum>
    _$adminDriverRequestsIdPatchRequestStatusEnumSerializer =
    _$AdminDriverRequestsIdPatchRequestStatusEnumSerializer();

class _$AdminDriverRequestsIdPatchRequestStatusEnumSerializer
    implements
        PrimitiveSerializer<AdminDriverRequestsIdPatchRequestStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'approved': 'approved',
    'declined': 'declined',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'approved': 'approved',
    'declined': 'declined',
  };

  @override
  final Iterable<Type> types = const <Type>[
    AdminDriverRequestsIdPatchRequestStatusEnum
  ];
  @override
  final String wireName = 'AdminDriverRequestsIdPatchRequestStatusEnum';

  @override
  Object serialize(Serializers serializers,
          AdminDriverRequestsIdPatchRequestStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  AdminDriverRequestsIdPatchRequestStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      AdminDriverRequestsIdPatchRequestStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$AdminDriverRequestsIdPatchRequest
    extends AdminDriverRequestsIdPatchRequest {
  @override
  final AdminDriverRequestsIdPatchRequestStatusEnum status;
  @override
  final String? decisionNote;

  factory _$AdminDriverRequestsIdPatchRequest(
          [void Function(AdminDriverRequestsIdPatchRequestBuilder)? updates]) =>
      (AdminDriverRequestsIdPatchRequestBuilder()..update(updates))._build();

  _$AdminDriverRequestsIdPatchRequest._(
      {required this.status, this.decisionNote})
      : super._();
  @override
  AdminDriverRequestsIdPatchRequest rebuild(
          void Function(AdminDriverRequestsIdPatchRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminDriverRequestsIdPatchRequestBuilder toBuilder() =>
      AdminDriverRequestsIdPatchRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminDriverRequestsIdPatchRequest &&
        status == other.status &&
        decisionNote == other.decisionNote;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, decisionNote.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminDriverRequestsIdPatchRequest')
          ..add('status', status)
          ..add('decisionNote', decisionNote))
        .toString();
  }
}

class AdminDriverRequestsIdPatchRequestBuilder
    implements
        Builder<AdminDriverRequestsIdPatchRequest,
            AdminDriverRequestsIdPatchRequestBuilder> {
  _$AdminDriverRequestsIdPatchRequest? _$v;

  AdminDriverRequestsIdPatchRequestStatusEnum? _status;
  AdminDriverRequestsIdPatchRequestStatusEnum? get status => _$this._status;
  set status(AdminDriverRequestsIdPatchRequestStatusEnum? status) =>
      _$this._status = status;

  String? _decisionNote;
  String? get decisionNote => _$this._decisionNote;
  set decisionNote(String? decisionNote) => _$this._decisionNote = decisionNote;

  AdminDriverRequestsIdPatchRequestBuilder() {
    AdminDriverRequestsIdPatchRequest._defaults(this);
  }

  AdminDriverRequestsIdPatchRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _status = $v.status;
      _decisionNote = $v.decisionNote;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminDriverRequestsIdPatchRequest other) {
    _$v = other as _$AdminDriverRequestsIdPatchRequest;
  }

  @override
  void update(
      void Function(AdminDriverRequestsIdPatchRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminDriverRequestsIdPatchRequest build() => _build();

  _$AdminDriverRequestsIdPatchRequest _build() {
    final _$result = _$v ??
        _$AdminDriverRequestsIdPatchRequest._(
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'AdminDriverRequestsIdPatchRequest', 'status'),
          decisionNote: decisionNote,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
