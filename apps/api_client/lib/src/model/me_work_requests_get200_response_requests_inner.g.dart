// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'me_work_requests_get200_response_requests_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MeWorkRequestsGet200ResponseRequestsInnerKindEnum
    _$meWorkRequestsGet200ResponseRequestsInnerKindEnum_routeChange =
    const MeWorkRequestsGet200ResponseRequestsInnerKindEnum._('routeChange');
const MeWorkRequestsGet200ResponseRequestsInnerKindEnum
    _$meWorkRequestsGet200ResponseRequestsInnerKindEnum_leave =
    const MeWorkRequestsGet200ResponseRequestsInnerKindEnum._('leave');

MeWorkRequestsGet200ResponseRequestsInnerKindEnum
    _$meWorkRequestsGet200ResponseRequestsInnerKindEnumValueOf(String name) {
  switch (name) {
    case 'routeChange':
      return _$meWorkRequestsGet200ResponseRequestsInnerKindEnum_routeChange;
    case 'leave':
      return _$meWorkRequestsGet200ResponseRequestsInnerKindEnum_leave;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<MeWorkRequestsGet200ResponseRequestsInnerKindEnum>
    _$meWorkRequestsGet200ResponseRequestsInnerKindEnumValues = BuiltSet<
        MeWorkRequestsGet200ResponseRequestsInnerKindEnum>(const <MeWorkRequestsGet200ResponseRequestsInnerKindEnum>[
  _$meWorkRequestsGet200ResponseRequestsInnerKindEnum_routeChange,
  _$meWorkRequestsGet200ResponseRequestsInnerKindEnum_leave,
]);

const MeWorkRequestsGet200ResponseRequestsInnerStatusEnum
    _$meWorkRequestsGet200ResponseRequestsInnerStatusEnum_pending =
    const MeWorkRequestsGet200ResponseRequestsInnerStatusEnum._('pending');
const MeWorkRequestsGet200ResponseRequestsInnerStatusEnum
    _$meWorkRequestsGet200ResponseRequestsInnerStatusEnum_approved =
    const MeWorkRequestsGet200ResponseRequestsInnerStatusEnum._('approved');
const MeWorkRequestsGet200ResponseRequestsInnerStatusEnum
    _$meWorkRequestsGet200ResponseRequestsInnerStatusEnum_declined =
    const MeWorkRequestsGet200ResponseRequestsInnerStatusEnum._('declined');
const MeWorkRequestsGet200ResponseRequestsInnerStatusEnum
    _$meWorkRequestsGet200ResponseRequestsInnerStatusEnum_withdrawn =
    const MeWorkRequestsGet200ResponseRequestsInnerStatusEnum._('withdrawn');

MeWorkRequestsGet200ResponseRequestsInnerStatusEnum
    _$meWorkRequestsGet200ResponseRequestsInnerStatusEnumValueOf(String name) {
  switch (name) {
    case 'pending':
      return _$meWorkRequestsGet200ResponseRequestsInnerStatusEnum_pending;
    case 'approved':
      return _$meWorkRequestsGet200ResponseRequestsInnerStatusEnum_approved;
    case 'declined':
      return _$meWorkRequestsGet200ResponseRequestsInnerStatusEnum_declined;
    case 'withdrawn':
      return _$meWorkRequestsGet200ResponseRequestsInnerStatusEnum_withdrawn;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<MeWorkRequestsGet200ResponseRequestsInnerStatusEnum>
    _$meWorkRequestsGet200ResponseRequestsInnerStatusEnumValues = BuiltSet<
        MeWorkRequestsGet200ResponseRequestsInnerStatusEnum>(const <MeWorkRequestsGet200ResponseRequestsInnerStatusEnum>[
  _$meWorkRequestsGet200ResponseRequestsInnerStatusEnum_pending,
  _$meWorkRequestsGet200ResponseRequestsInnerStatusEnum_approved,
  _$meWorkRequestsGet200ResponseRequestsInnerStatusEnum_declined,
  _$meWorkRequestsGet200ResponseRequestsInnerStatusEnum_withdrawn,
]);

Serializer<MeWorkRequestsGet200ResponseRequestsInnerKindEnum>
    _$meWorkRequestsGet200ResponseRequestsInnerKindEnumSerializer =
    _$MeWorkRequestsGet200ResponseRequestsInnerKindEnumSerializer();
Serializer<MeWorkRequestsGet200ResponseRequestsInnerStatusEnum>
    _$meWorkRequestsGet200ResponseRequestsInnerStatusEnumSerializer =
    _$MeWorkRequestsGet200ResponseRequestsInnerStatusEnumSerializer();

class _$MeWorkRequestsGet200ResponseRequestsInnerKindEnumSerializer
    implements
        PrimitiveSerializer<MeWorkRequestsGet200ResponseRequestsInnerKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'routeChange': 'route_change',
    'leave': 'leave',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'route_change': 'routeChange',
    'leave': 'leave',
  };

  @override
  final Iterable<Type> types = const <Type>[
    MeWorkRequestsGet200ResponseRequestsInnerKindEnum
  ];
  @override
  final String wireName = 'MeWorkRequestsGet200ResponseRequestsInnerKindEnum';

  @override
  Object serialize(Serializers serializers,
          MeWorkRequestsGet200ResponseRequestsInnerKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  MeWorkRequestsGet200ResponseRequestsInnerKindEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      MeWorkRequestsGet200ResponseRequestsInnerKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$MeWorkRequestsGet200ResponseRequestsInnerStatusEnumSerializer
    implements
        PrimitiveSerializer<
            MeWorkRequestsGet200ResponseRequestsInnerStatusEnum> {
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
  final Iterable<Type> types = const <Type>[
    MeWorkRequestsGet200ResponseRequestsInnerStatusEnum
  ];
  @override
  final String wireName = 'MeWorkRequestsGet200ResponseRequestsInnerStatusEnum';

  @override
  Object serialize(Serializers serializers,
          MeWorkRequestsGet200ResponseRequestsInnerStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  MeWorkRequestsGet200ResponseRequestsInnerStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      MeWorkRequestsGet200ResponseRequestsInnerStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$MeWorkRequestsGet200ResponseRequestsInner
    extends MeWorkRequestsGet200ResponseRequestsInner {
  @override
  final String id;
  @override
  final MeWorkRequestsGet200ResponseRequestsInnerKindEnum kind;
  @override
  final MeWorkRequestsGet200ResponseRequestsInnerStatusEnum status;
  @override
  final String? routeId;
  @override
  final String? fromDate;
  @override
  final String? toDate;
  @override
  final String? note;
  @override
  final String? decisionNote;
  @override
  final DateTime? decidedAt;
  @override
  final DateTime createdAt;

  factory _$MeWorkRequestsGet200ResponseRequestsInner(
          [void Function(MeWorkRequestsGet200ResponseRequestsInnerBuilder)?
              updates]) =>
      (MeWorkRequestsGet200ResponseRequestsInnerBuilder()..update(updates))
          ._build();

  _$MeWorkRequestsGet200ResponseRequestsInner._(
      {required this.id,
      required this.kind,
      required this.status,
      this.routeId,
      this.fromDate,
      this.toDate,
      this.note,
      this.decisionNote,
      this.decidedAt,
      required this.createdAt})
      : super._();
  @override
  MeWorkRequestsGet200ResponseRequestsInner rebuild(
          void Function(MeWorkRequestsGet200ResponseRequestsInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MeWorkRequestsGet200ResponseRequestsInnerBuilder toBuilder() =>
      MeWorkRequestsGet200ResponseRequestsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MeWorkRequestsGet200ResponseRequestsInner &&
        id == other.id &&
        kind == other.kind &&
        status == other.status &&
        routeId == other.routeId &&
        fromDate == other.fromDate &&
        toDate == other.toDate &&
        note == other.note &&
        decisionNote == other.decisionNote &&
        decidedAt == other.decidedAt &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, routeId.hashCode);
    _$hash = $jc(_$hash, fromDate.hashCode);
    _$hash = $jc(_$hash, toDate.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, decisionNote.hashCode);
    _$hash = $jc(_$hash, decidedAt.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'MeWorkRequestsGet200ResponseRequestsInner')
          ..add('id', id)
          ..add('kind', kind)
          ..add('status', status)
          ..add('routeId', routeId)
          ..add('fromDate', fromDate)
          ..add('toDate', toDate)
          ..add('note', note)
          ..add('decisionNote', decisionNote)
          ..add('decidedAt', decidedAt)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class MeWorkRequestsGet200ResponseRequestsInnerBuilder
    implements
        Builder<MeWorkRequestsGet200ResponseRequestsInner,
            MeWorkRequestsGet200ResponseRequestsInnerBuilder> {
  _$MeWorkRequestsGet200ResponseRequestsInner? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  MeWorkRequestsGet200ResponseRequestsInnerKindEnum? _kind;
  MeWorkRequestsGet200ResponseRequestsInnerKindEnum? get kind => _$this._kind;
  set kind(MeWorkRequestsGet200ResponseRequestsInnerKindEnum? kind) =>
      _$this._kind = kind;

  MeWorkRequestsGet200ResponseRequestsInnerStatusEnum? _status;
  MeWorkRequestsGet200ResponseRequestsInnerStatusEnum? get status =>
      _$this._status;
  set status(MeWorkRequestsGet200ResponseRequestsInnerStatusEnum? status) =>
      _$this._status = status;

  String? _routeId;
  String? get routeId => _$this._routeId;
  set routeId(String? routeId) => _$this._routeId = routeId;

  String? _fromDate;
  String? get fromDate => _$this._fromDate;
  set fromDate(String? fromDate) => _$this._fromDate = fromDate;

  String? _toDate;
  String? get toDate => _$this._toDate;
  set toDate(String? toDate) => _$this._toDate = toDate;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  String? _decisionNote;
  String? get decisionNote => _$this._decisionNote;
  set decisionNote(String? decisionNote) => _$this._decisionNote = decisionNote;

  DateTime? _decidedAt;
  DateTime? get decidedAt => _$this._decidedAt;
  set decidedAt(DateTime? decidedAt) => _$this._decidedAt = decidedAt;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  MeWorkRequestsGet200ResponseRequestsInnerBuilder() {
    MeWorkRequestsGet200ResponseRequestsInner._defaults(this);
  }

  MeWorkRequestsGet200ResponseRequestsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _kind = $v.kind;
      _status = $v.status;
      _routeId = $v.routeId;
      _fromDate = $v.fromDate;
      _toDate = $v.toDate;
      _note = $v.note;
      _decisionNote = $v.decisionNote;
      _decidedAt = $v.decidedAt;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MeWorkRequestsGet200ResponseRequestsInner other) {
    _$v = other as _$MeWorkRequestsGet200ResponseRequestsInner;
  }

  @override
  void update(
      void Function(MeWorkRequestsGet200ResponseRequestsInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  MeWorkRequestsGet200ResponseRequestsInner build() => _build();

  _$MeWorkRequestsGet200ResponseRequestsInner _build() {
    final _$result = _$v ??
        _$MeWorkRequestsGet200ResponseRequestsInner._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'MeWorkRequestsGet200ResponseRequestsInner', 'id'),
          kind: BuiltValueNullFieldError.checkNotNull(
              kind, r'MeWorkRequestsGet200ResponseRequestsInner', 'kind'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'MeWorkRequestsGet200ResponseRequestsInner', 'status'),
          routeId: routeId,
          fromDate: fromDate,
          toDate: toDate,
          note: note,
          decisionNote: decisionNote,
          decidedAt: decidedAt,
          createdAt: BuiltValueNullFieldError.checkNotNull(createdAt,
              r'MeWorkRequestsGet200ResponseRequestsInner', 'createdAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
