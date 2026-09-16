// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const WorkRequestStatusEnum _$workRequestStatusEnum_pending =
    const WorkRequestStatusEnum._('pending');
const WorkRequestStatusEnum _$workRequestStatusEnum_approved =
    const WorkRequestStatusEnum._('approved');
const WorkRequestStatusEnum _$workRequestStatusEnum_declined =
    const WorkRequestStatusEnum._('declined');
const WorkRequestStatusEnum _$workRequestStatusEnum_withdrawn =
    const WorkRequestStatusEnum._('withdrawn');

WorkRequestStatusEnum _$workRequestStatusEnumValueOf(String name) {
  switch (name) {
    case 'pending':
      return _$workRequestStatusEnum_pending;
    case 'approved':
      return _$workRequestStatusEnum_approved;
    case 'declined':
      return _$workRequestStatusEnum_declined;
    case 'withdrawn':
      return _$workRequestStatusEnum_withdrawn;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<WorkRequestStatusEnum> _$workRequestStatusEnumValues =
    BuiltSet<WorkRequestStatusEnum>(const <WorkRequestStatusEnum>[
  _$workRequestStatusEnum_pending,
  _$workRequestStatusEnum_approved,
  _$workRequestStatusEnum_declined,
  _$workRequestStatusEnum_withdrawn,
]);

Serializer<WorkRequestStatusEnum> _$workRequestStatusEnumSerializer =
    _$WorkRequestStatusEnumSerializer();

class _$WorkRequestStatusEnumSerializer
    implements PrimitiveSerializer<WorkRequestStatusEnum> {
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
  final Iterable<Type> types = const <Type>[WorkRequestStatusEnum];
  @override
  final String wireName = 'WorkRequestStatusEnum';

  @override
  Object serialize(Serializers serializers, WorkRequestStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  WorkRequestStatusEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      WorkRequestStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$WorkRequest extends WorkRequest {
  @override
  final String id;
  @override
  final WorkRequestInput request;
  @override
  final WorkRequestStatusEnum status;
  @override
  final String? decisionNote;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final int version;

  factory _$WorkRequest([void Function(WorkRequestBuilder)? updates]) =>
      (WorkRequestBuilder()..update(updates))._build();

  _$WorkRequest._(
      {required this.id,
      required this.request,
      required this.status,
      this.decisionNote,
      required this.createdAt,
      required this.updatedAt,
      required this.version})
      : super._();
  @override
  WorkRequest rebuild(void Function(WorkRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  WorkRequestBuilder toBuilder() => WorkRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WorkRequest &&
        id == other.id &&
        request == other.request &&
        status == other.status &&
        decisionNote == other.decisionNote &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        version == other.version;
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
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'WorkRequest')
          ..add('id', id)
          ..add('request', request)
          ..add('status', status)
          ..add('decisionNote', decisionNote)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt)
          ..add('version', version))
        .toString();
  }
}

class WorkRequestBuilder implements Builder<WorkRequest, WorkRequestBuilder> {
  _$WorkRequest? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  WorkRequestInputBuilder? _request;
  WorkRequestInputBuilder get request =>
      _$this._request ??= WorkRequestInputBuilder();
  set request(WorkRequestInputBuilder? request) => _$this._request = request;

  WorkRequestStatusEnum? _status;
  WorkRequestStatusEnum? get status => _$this._status;
  set status(WorkRequestStatusEnum? status) => _$this._status = status;

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

  WorkRequestBuilder() {
    WorkRequest._defaults(this);
  }

  WorkRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _request = $v.request.toBuilder();
      _status = $v.status;
      _decisionNote = $v.decisionNote;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _version = $v.version;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WorkRequest other) {
    _$v = other as _$WorkRequest;
  }

  @override
  void update(void Function(WorkRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WorkRequest build() => _build();

  _$WorkRequest _build() {
    _$WorkRequest _$result;
    try {
      _$result = _$v ??
          _$WorkRequest._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'WorkRequest', 'id'),
            request: request.build(),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'WorkRequest', 'status'),
            decisionNote: decisionNote,
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'WorkRequest', 'createdAt'),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
                updatedAt, r'WorkRequest', 'updatedAt'),
            version: BuiltValueNullFieldError.checkNotNull(
                version, r'WorkRequest', 'version'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'request';
        request.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'WorkRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
