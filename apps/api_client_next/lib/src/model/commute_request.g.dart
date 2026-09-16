// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commute_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CommuteRequestStatusEnum _$commuteRequestStatusEnum_submitted =
    const CommuteRequestStatusEnum._('submitted');
const CommuteRequestStatusEnum _$commuteRequestStatusEnum_waitlisted =
    const CommuteRequestStatusEnum._('waitlisted');
const CommuteRequestStatusEnum _$commuteRequestStatusEnum_approved =
    const CommuteRequestStatusEnum._('approved');
const CommuteRequestStatusEnum _$commuteRequestStatusEnum_applied =
    const CommuteRequestStatusEnum._('applied');
const CommuteRequestStatusEnum _$commuteRequestStatusEnum_rejected =
    const CommuteRequestStatusEnum._('rejected');
const CommuteRequestStatusEnum _$commuteRequestStatusEnum_cancelled =
    const CommuteRequestStatusEnum._('cancelled');

CommuteRequestStatusEnum _$commuteRequestStatusEnumValueOf(String name) {
  switch (name) {
    case 'submitted':
      return _$commuteRequestStatusEnum_submitted;
    case 'waitlisted':
      return _$commuteRequestStatusEnum_waitlisted;
    case 'approved':
      return _$commuteRequestStatusEnum_approved;
    case 'applied':
      return _$commuteRequestStatusEnum_applied;
    case 'rejected':
      return _$commuteRequestStatusEnum_rejected;
    case 'cancelled':
      return _$commuteRequestStatusEnum_cancelled;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CommuteRequestStatusEnum> _$commuteRequestStatusEnumValues =
    BuiltSet<CommuteRequestStatusEnum>(const <CommuteRequestStatusEnum>[
  _$commuteRequestStatusEnum_submitted,
  _$commuteRequestStatusEnum_waitlisted,
  _$commuteRequestStatusEnum_approved,
  _$commuteRequestStatusEnum_applied,
  _$commuteRequestStatusEnum_rejected,
  _$commuteRequestStatusEnum_cancelled,
]);

Serializer<CommuteRequestStatusEnum> _$commuteRequestStatusEnumSerializer =
    _$CommuteRequestStatusEnumSerializer();

class _$CommuteRequestStatusEnumSerializer
    implements PrimitiveSerializer<CommuteRequestStatusEnum> {
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
  final Iterable<Type> types = const <Type>[CommuteRequestStatusEnum];
  @override
  final String wireName = 'CommuteRequestStatusEnum';

  @override
  Object serialize(Serializers serializers, CommuteRequestStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CommuteRequestStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CommuteRequestStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$CommuteRequest extends CommuteRequest {
  @override
  final String id;
  @override
  final CommuteRequestStatusEnum status;
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

  factory _$CommuteRequest([void Function(CommuteRequestBuilder)? updates]) =>
      (CommuteRequestBuilder()..update(updates))._build();

  _$CommuteRequest._(
      {required this.id,
      required this.status,
      required this.requested,
      this.effectiveDate,
      required this.paused,
      this.decisionNote,
      required this.createdAt,
      required this.updatedAt,
      required this.version})
      : super._();
  @override
  CommuteRequest rebuild(void Function(CommuteRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CommuteRequestBuilder toBuilder() => CommuteRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CommuteRequest &&
        id == other.id &&
        status == other.status &&
        requested == other.requested &&
        effectiveDate == other.effectiveDate &&
        paused == other.paused &&
        decisionNote == other.decisionNote &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        version == other.version;
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
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CommuteRequest')
          ..add('id', id)
          ..add('status', status)
          ..add('requested', requested)
          ..add('effectiveDate', effectiveDate)
          ..add('paused', paused)
          ..add('decisionNote', decisionNote)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt)
          ..add('version', version))
        .toString();
  }
}

class CommuteRequestBuilder
    implements Builder<CommuteRequest, CommuteRequestBuilder> {
  _$CommuteRequest? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  CommuteRequestStatusEnum? _status;
  CommuteRequestStatusEnum? get status => _$this._status;
  set status(CommuteRequestStatusEnum? status) => _$this._status = status;

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

  CommuteRequestBuilder() {
    CommuteRequest._defaults(this);
  }

  CommuteRequestBuilder get _$this {
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
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CommuteRequest other) {
    _$v = other as _$CommuteRequest;
  }

  @override
  void update(void Function(CommuteRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CommuteRequest build() => _build();

  _$CommuteRequest _build() {
    _$CommuteRequest _$result;
    try {
      _$result = _$v ??
          _$CommuteRequest._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'CommuteRequest', 'id'),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'CommuteRequest', 'status'),
            requested: requested.build(),
            effectiveDate: effectiveDate,
            paused: BuiltValueNullFieldError.checkNotNull(
                paused, r'CommuteRequest', 'paused'),
            decisionNote: decisionNote,
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'CommuteRequest', 'createdAt'),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
                updatedAt, r'CommuteRequest', 'updatedAt'),
            version: BuiltValueNullFieldError.checkNotNull(
                version, r'CommuteRequest', 'version'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'requested';
        requested.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'CommuteRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
