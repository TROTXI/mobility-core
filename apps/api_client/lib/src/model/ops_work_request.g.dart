// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ops_work_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const OpsWorkRequestStatusEnum _$opsWorkRequestStatusEnum_pending =
    const OpsWorkRequestStatusEnum._('pending');
const OpsWorkRequestStatusEnum _$opsWorkRequestStatusEnum_approved =
    const OpsWorkRequestStatusEnum._('approved');
const OpsWorkRequestStatusEnum _$opsWorkRequestStatusEnum_declined =
    const OpsWorkRequestStatusEnum._('declined');
const OpsWorkRequestStatusEnum _$opsWorkRequestStatusEnum_withdrawn =
    const OpsWorkRequestStatusEnum._('withdrawn');

OpsWorkRequestStatusEnum _$opsWorkRequestStatusEnumValueOf(String name) {
  switch (name) {
    case 'pending':
      return _$opsWorkRequestStatusEnum_pending;
    case 'approved':
      return _$opsWorkRequestStatusEnum_approved;
    case 'declined':
      return _$opsWorkRequestStatusEnum_declined;
    case 'withdrawn':
      return _$opsWorkRequestStatusEnum_withdrawn;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<OpsWorkRequestStatusEnum> _$opsWorkRequestStatusEnumValues =
    BuiltSet<OpsWorkRequestStatusEnum>(const <OpsWorkRequestStatusEnum>[
  _$opsWorkRequestStatusEnum_pending,
  _$opsWorkRequestStatusEnum_approved,
  _$opsWorkRequestStatusEnum_declined,
  _$opsWorkRequestStatusEnum_withdrawn,
]);

Serializer<OpsWorkRequestStatusEnum> _$opsWorkRequestStatusEnumSerializer =
    _$OpsWorkRequestStatusEnumSerializer();

class _$OpsWorkRequestStatusEnumSerializer
    implements PrimitiveSerializer<OpsWorkRequestStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'pending': 'pending',
    'approved': 'approved',
    'declined': 'declined',
    'withdrawn': 'withdrawn',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'pending': 'pending',
    'approved': 'approved',
    'declined': 'declined',
    'withdrawn': 'withdrawn',
  };

  @override
  final Iterable<Type> types = const <Type>[OpsWorkRequestStatusEnum];
  @override
  final String wireName = 'OpsWorkRequestStatusEnum';

  @override
  Object serialize(Serializers serializers, OpsWorkRequestStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  OpsWorkRequestStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      OpsWorkRequestStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$OpsWorkRequest extends OpsWorkRequest {
  @override
  final String id;
  @override
  final WorkRequestInput request;
  @override
  final OpsWorkRequestStatusEnum status;
  @override
  final String? decisionNote;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final int version;
  @override
  final String driverId;
  @override
  final String? decidedBy;
  @override
  final String editToken;

  factory _$OpsWorkRequest([void Function(OpsWorkRequestBuilder)? updates]) =>
      (OpsWorkRequestBuilder()..update(updates))._build();

  _$OpsWorkRequest._(
      {required this.id,
      required this.request,
      required this.status,
      this.decisionNote,
      required this.createdAt,
      required this.updatedAt,
      required this.version,
      required this.driverId,
      this.decidedBy,
      required this.editToken})
      : super._();
  @override
  OpsWorkRequest rebuild(void Function(OpsWorkRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OpsWorkRequestBuilder toBuilder() => OpsWorkRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OpsWorkRequest &&
        id == other.id &&
        request == other.request &&
        status == other.status &&
        decisionNote == other.decisionNote &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        version == other.version &&
        driverId == other.driverId &&
        decidedBy == other.decidedBy &&
        editToken == other.editToken;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, request.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, decisionNote.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jc(_$hash, driverId.hashCode);
    _$hash = $jc(_$hash, decidedBy.hashCode);
    _$hash = $jc(_$hash, editToken.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OpsWorkRequest')
          ..add('id', id)
          ..add('request', request)
          ..add('status', status)
          ..add('decisionNote', decisionNote)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt)
          ..add('version', version)
          ..add('driverId', driverId)
          ..add('decidedBy', decidedBy)
          ..add('editToken', editToken))
        .toString();
  }
}

class OpsWorkRequestBuilder
    implements Builder<OpsWorkRequest, OpsWorkRequestBuilder> {
  _$OpsWorkRequest? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  WorkRequestInputBuilder? _request;
  WorkRequestInputBuilder get request =>
      _$this._request ??= WorkRequestInputBuilder();
  set request(WorkRequestInputBuilder? request) => _$this._request = request;

  OpsWorkRequestStatusEnum? _status;
  OpsWorkRequestStatusEnum? get status => _$this._status;
  set status(OpsWorkRequestStatusEnum? status) => _$this._status = status;

  String? _decisionNote;
  String? get decisionNote => _$this._decisionNote;
  set decisionNote(String? decisionNote) => _$this._decisionNote = decisionNote;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  int? _version;
  int? get version => _$this._version;
  set version(int? version) => _$this._version = version;

  String? _driverId;
  String? get driverId => _$this._driverId;
  set driverId(String? driverId) => _$this._driverId = driverId;

  String? _decidedBy;
  String? get decidedBy => _$this._decidedBy;
  set decidedBy(String? decidedBy) => _$this._decidedBy = decidedBy;

  String? _editToken;
  String? get editToken => _$this._editToken;
  set editToken(String? editToken) => _$this._editToken = editToken;

  OpsWorkRequestBuilder() {
    OpsWorkRequest._defaults(this);
  }

  OpsWorkRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _request = $v.request.toBuilder();
      _status = $v.status;
      _decisionNote = $v.decisionNote;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _version = $v.version;
      _driverId = $v.driverId;
      _decidedBy = $v.decidedBy;
      _editToken = $v.editToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OpsWorkRequest other) {
    _$v = other as _$OpsWorkRequest;
  }

  @override
  void update(void Function(OpsWorkRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OpsWorkRequest build() => _build();

  _$OpsWorkRequest _build() {
    _$OpsWorkRequest _$result;
    try {
      _$result = _$v ??
          _$OpsWorkRequest._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'OpsWorkRequest', 'id'),
            request: request.build(),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'OpsWorkRequest', 'status'),
            decisionNote: decisionNote,
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'OpsWorkRequest', 'createdAt'),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
                updatedAt, r'OpsWorkRequest', 'updatedAt'),
            version: BuiltValueNullFieldError.checkNotNull(
                version, r'OpsWorkRequest', 'version'),
            driverId: BuiltValueNullFieldError.checkNotNull(
                driverId, r'OpsWorkRequest', 'driverId'),
            decidedBy: decidedBy,
            editToken: BuiltValueNullFieldError.checkNotNull(
                editToken, r'OpsWorkRequest', 'editToken'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'request';
        request.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'OpsWorkRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
