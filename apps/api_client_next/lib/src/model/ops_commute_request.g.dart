// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ops_commute_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const OpsCommuteRequestStatusEnum _$opsCommuteRequestStatusEnum_submitted =
    const OpsCommuteRequestStatusEnum._('submitted');
const OpsCommuteRequestStatusEnum _$opsCommuteRequestStatusEnum_waitlisted =
    const OpsCommuteRequestStatusEnum._('waitlisted');
const OpsCommuteRequestStatusEnum _$opsCommuteRequestStatusEnum_approved =
    const OpsCommuteRequestStatusEnum._('approved');
const OpsCommuteRequestStatusEnum _$opsCommuteRequestStatusEnum_applied =
    const OpsCommuteRequestStatusEnum._('applied');
const OpsCommuteRequestStatusEnum _$opsCommuteRequestStatusEnum_rejected =
    const OpsCommuteRequestStatusEnum._('rejected');
const OpsCommuteRequestStatusEnum _$opsCommuteRequestStatusEnum_cancelled =
    const OpsCommuteRequestStatusEnum._('cancelled');

OpsCommuteRequestStatusEnum _$opsCommuteRequestStatusEnumValueOf(String name) {
  switch (name) {
    case 'submitted':
      return _$opsCommuteRequestStatusEnum_submitted;
    case 'waitlisted':
      return _$opsCommuteRequestStatusEnum_waitlisted;
    case 'approved':
      return _$opsCommuteRequestStatusEnum_approved;
    case 'applied':
      return _$opsCommuteRequestStatusEnum_applied;
    case 'rejected':
      return _$opsCommuteRequestStatusEnum_rejected;
    case 'cancelled':
      return _$opsCommuteRequestStatusEnum_cancelled;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<OpsCommuteRequestStatusEnum>
    _$opsCommuteRequestStatusEnumValues =
    BuiltSet<OpsCommuteRequestStatusEnum>(const <OpsCommuteRequestStatusEnum>[
  _$opsCommuteRequestStatusEnum_submitted,
  _$opsCommuteRequestStatusEnum_waitlisted,
  _$opsCommuteRequestStatusEnum_approved,
  _$opsCommuteRequestStatusEnum_applied,
  _$opsCommuteRequestStatusEnum_rejected,
  _$opsCommuteRequestStatusEnum_cancelled,
]);

Serializer<OpsCommuteRequestStatusEnum>
    _$opsCommuteRequestStatusEnumSerializer =
    _$OpsCommuteRequestStatusEnumSerializer();

class _$OpsCommuteRequestStatusEnumSerializer
    implements PrimitiveSerializer<OpsCommuteRequestStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'submitted': 'submitted',
    'waitlisted': 'waitlisted',
    'approved': 'approved',
    'applied': 'applied',
    'rejected': 'rejected',
    'cancelled': 'cancelled',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'submitted': 'submitted',
    'waitlisted': 'waitlisted',
    'approved': 'approved',
    'applied': 'applied',
    'rejected': 'rejected',
    'cancelled': 'cancelled',
  };

  @override
  final Iterable<Type> types = const <Type>[OpsCommuteRequestStatusEnum];
  @override
  final String wireName = 'OpsCommuteRequestStatusEnum';

  @override
  Object serialize(Serializers serializers, OpsCommuteRequestStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  OpsCommuteRequestStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      OpsCommuteRequestStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$OpsCommuteRequest extends OpsCommuteRequest {
  @override
  final String id;
  @override
  final OpsCommuteRequestStatusEnum status;
  @override
  final CommuteRequestInput requested;
  @override
  final Date? effectiveDate;
  @override
  final bool paused;
  @override
  final String? decisionNote;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final int version;
  @override
  final String riderId;
  @override
  final String? slotId;
  @override
  final String? decidedBy;
  @override
  final String editToken;

  factory _$OpsCommuteRequest(
          [void Function(OpsCommuteRequestBuilder)? updates]) =>
      (OpsCommuteRequestBuilder()..update(updates))._build();

  _$OpsCommuteRequest._(
      {required this.id,
      required this.status,
      required this.requested,
      this.effectiveDate,
      required this.paused,
      this.decisionNote,
      required this.createdAt,
      required this.updatedAt,
      required this.version,
      required this.riderId,
      this.slotId,
      this.decidedBy,
      required this.editToken})
      : super._();
  @override
  OpsCommuteRequest rebuild(void Function(OpsCommuteRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OpsCommuteRequestBuilder toBuilder() =>
      OpsCommuteRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OpsCommuteRequest &&
        id == other.id &&
        status == other.status &&
        requested == other.requested &&
        effectiveDate == other.effectiveDate &&
        paused == other.paused &&
        decisionNote == other.decisionNote &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        version == other.version &&
        riderId == other.riderId &&
        slotId == other.slotId &&
        decidedBy == other.decidedBy &&
        editToken == other.editToken;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, requested.hashCode);
    _$hash = $jc(_$hash, effectiveDate.hashCode);
    _$hash = $jc(_$hash, paused.hashCode);
    _$hash = $jc(_$hash, decisionNote.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jc(_$hash, riderId.hashCode);
    _$hash = $jc(_$hash, slotId.hashCode);
    _$hash = $jc(_$hash, decidedBy.hashCode);
    _$hash = $jc(_$hash, editToken.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OpsCommuteRequest')
          ..add('id', id)
          ..add('status', status)
          ..add('requested', requested)
          ..add('effectiveDate', effectiveDate)
          ..add('paused', paused)
          ..add('decisionNote', decisionNote)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt)
          ..add('version', version)
          ..add('riderId', riderId)
          ..add('slotId', slotId)
          ..add('decidedBy', decidedBy)
          ..add('editToken', editToken))
        .toString();
  }
}

class OpsCommuteRequestBuilder
    implements Builder<OpsCommuteRequest, OpsCommuteRequestBuilder> {
  _$OpsCommuteRequest? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  OpsCommuteRequestStatusEnum? _status;
  OpsCommuteRequestStatusEnum? get status => _$this._status;
  set status(OpsCommuteRequestStatusEnum? status) => _$this._status = status;

  CommuteRequestInputBuilder? _requested;
  CommuteRequestInputBuilder get requested =>
      _$this._requested ??= CommuteRequestInputBuilder();
  set requested(CommuteRequestInputBuilder? requested) =>
      _$this._requested = requested;

  Date? _effectiveDate;
  Date? get effectiveDate => _$this._effectiveDate;
  set effectiveDate(Date? effectiveDate) =>
      _$this._effectiveDate = effectiveDate;

  bool? _paused;
  bool? get paused => _$this._paused;
  set paused(bool? paused) => _$this._paused = paused;

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

  String? _riderId;
  String? get riderId => _$this._riderId;
  set riderId(String? riderId) => _$this._riderId = riderId;

  String? _slotId;
  String? get slotId => _$this._slotId;
  set slotId(String? slotId) => _$this._slotId = slotId;

  String? _decidedBy;
  String? get decidedBy => _$this._decidedBy;
  set decidedBy(String? decidedBy) => _$this._decidedBy = decidedBy;

  String? _editToken;
  String? get editToken => _$this._editToken;
  set editToken(String? editToken) => _$this._editToken = editToken;

  OpsCommuteRequestBuilder() {
    OpsCommuteRequest._defaults(this);
  }

  OpsCommuteRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _status = $v.status;
      _requested = $v.requested.toBuilder();
      _effectiveDate = $v.effectiveDate;
      _paused = $v.paused;
      _decisionNote = $v.decisionNote;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _version = $v.version;
      _riderId = $v.riderId;
      _slotId = $v.slotId;
      _decidedBy = $v.decidedBy;
      _editToken = $v.editToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OpsCommuteRequest other) {
    _$v = other as _$OpsCommuteRequest;
  }

  @override
  void update(void Function(OpsCommuteRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OpsCommuteRequest build() => _build();

  _$OpsCommuteRequest _build() {
    _$OpsCommuteRequest _$result;
    try {
      _$result = _$v ??
          _$OpsCommuteRequest._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'OpsCommuteRequest', 'id'),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'OpsCommuteRequest', 'status'),
            requested: requested.build(),
            effectiveDate: effectiveDate,
            paused: BuiltValueNullFieldError.checkNotNull(
                paused, r'OpsCommuteRequest', 'paused'),
            decisionNote: decisionNote,
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'OpsCommuteRequest', 'createdAt'),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
                updatedAt, r'OpsCommuteRequest', 'updatedAt'),
            version: BuiltValueNullFieldError.checkNotNull(
                version, r'OpsCommuteRequest', 'version'),
            riderId: BuiltValueNullFieldError.checkNotNull(
                riderId, r'OpsCommuteRequest', 'riderId'),
            slotId: slotId,
            decidedBy: decidedBy,
            editToken: BuiltValueNullFieldError.checkNotNull(
                editToken, r'OpsCommuteRequest', 'editToken'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'requested';
        requested.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'OpsCommuteRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
