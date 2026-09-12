// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_driver_requests_get200_response_requests_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminDriverRequestsGet200ResponseRequestsInnerKindEnum
    _$adminDriverRequestsGet200ResponseRequestsInnerKindEnum_routeChange =
    const AdminDriverRequestsGet200ResponseRequestsInnerKindEnum._(
        'routeChange');
const AdminDriverRequestsGet200ResponseRequestsInnerKindEnum
    _$adminDriverRequestsGet200ResponseRequestsInnerKindEnum_leave =
    const AdminDriverRequestsGet200ResponseRequestsInnerKindEnum._('leave');

AdminDriverRequestsGet200ResponseRequestsInnerKindEnum
    _$adminDriverRequestsGet200ResponseRequestsInnerKindEnumValueOf(
        String name) {
  switch (name) {
    case 'routeChange':
      return _$adminDriverRequestsGet200ResponseRequestsInnerKindEnum_routeChange;
    case 'leave':
      return _$adminDriverRequestsGet200ResponseRequestsInnerKindEnum_leave;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<AdminDriverRequestsGet200ResponseRequestsInnerKindEnum>
    _$adminDriverRequestsGet200ResponseRequestsInnerKindEnumValues = BuiltSet<
        AdminDriverRequestsGet200ResponseRequestsInnerKindEnum>(const <AdminDriverRequestsGet200ResponseRequestsInnerKindEnum>[
  _$adminDriverRequestsGet200ResponseRequestsInnerKindEnum_routeChange,
  _$adminDriverRequestsGet200ResponseRequestsInnerKindEnum_leave,
]);

const AdminDriverRequestsGet200ResponseRequestsInnerStatusEnum
    _$adminDriverRequestsGet200ResponseRequestsInnerStatusEnum_pending =
    const AdminDriverRequestsGet200ResponseRequestsInnerStatusEnum._('pending');
const AdminDriverRequestsGet200ResponseRequestsInnerStatusEnum
    _$adminDriverRequestsGet200ResponseRequestsInnerStatusEnum_approved =
    const AdminDriverRequestsGet200ResponseRequestsInnerStatusEnum._(
        'approved');
const AdminDriverRequestsGet200ResponseRequestsInnerStatusEnum
    _$adminDriverRequestsGet200ResponseRequestsInnerStatusEnum_declined =
    const AdminDriverRequestsGet200ResponseRequestsInnerStatusEnum._(
        'declined');
const AdminDriverRequestsGet200ResponseRequestsInnerStatusEnum
    _$adminDriverRequestsGet200ResponseRequestsInnerStatusEnum_withdrawn =
    const AdminDriverRequestsGet200ResponseRequestsInnerStatusEnum._(
        'withdrawn');

AdminDriverRequestsGet200ResponseRequestsInnerStatusEnum
    _$adminDriverRequestsGet200ResponseRequestsInnerStatusEnumValueOf(
        String name) {
  switch (name) {
    case 'pending':
      return _$adminDriverRequestsGet200ResponseRequestsInnerStatusEnum_pending;
    case 'approved':
      return _$adminDriverRequestsGet200ResponseRequestsInnerStatusEnum_approved;
    case 'declined':
      return _$adminDriverRequestsGet200ResponseRequestsInnerStatusEnum_declined;
    case 'withdrawn':
      return _$adminDriverRequestsGet200ResponseRequestsInnerStatusEnum_withdrawn;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<AdminDriverRequestsGet200ResponseRequestsInnerStatusEnum>
    _$adminDriverRequestsGet200ResponseRequestsInnerStatusEnumValues = BuiltSet<
        AdminDriverRequestsGet200ResponseRequestsInnerStatusEnum>(const <AdminDriverRequestsGet200ResponseRequestsInnerStatusEnum>[
  _$adminDriverRequestsGet200ResponseRequestsInnerStatusEnum_pending,
  _$adminDriverRequestsGet200ResponseRequestsInnerStatusEnum_approved,
  _$adminDriverRequestsGet200ResponseRequestsInnerStatusEnum_declined,
  _$adminDriverRequestsGet200ResponseRequestsInnerStatusEnum_withdrawn,
]);

Serializer<AdminDriverRequestsGet200ResponseRequestsInnerKindEnum>
    _$adminDriverRequestsGet200ResponseRequestsInnerKindEnumSerializer =
    _$AdminDriverRequestsGet200ResponseRequestsInnerKindEnumSerializer();
Serializer<AdminDriverRequestsGet200ResponseRequestsInnerStatusEnum>
    _$adminDriverRequestsGet200ResponseRequestsInnerStatusEnumSerializer =
    _$AdminDriverRequestsGet200ResponseRequestsInnerStatusEnumSerializer();

class _$AdminDriverRequestsGet200ResponseRequestsInnerKindEnumSerializer
    implements
        PrimitiveSerializer<
            AdminDriverRequestsGet200ResponseRequestsInnerKindEnum> {
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
    AdminDriverRequestsGet200ResponseRequestsInnerKindEnum
  ];
  @override
  final String wireName =
      'AdminDriverRequestsGet200ResponseRequestsInnerKindEnum';

  @override
  Object serialize(Serializers serializers,
          AdminDriverRequestsGet200ResponseRequestsInnerKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  AdminDriverRequestsGet200ResponseRequestsInnerKindEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      AdminDriverRequestsGet200ResponseRequestsInnerKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$AdminDriverRequestsGet200ResponseRequestsInnerStatusEnumSerializer
    implements
        PrimitiveSerializer<
            AdminDriverRequestsGet200ResponseRequestsInnerStatusEnum> {
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
    AdminDriverRequestsGet200ResponseRequestsInnerStatusEnum
  ];
  @override
  final String wireName =
      'AdminDriverRequestsGet200ResponseRequestsInnerStatusEnum';

  @override
  Object serialize(Serializers serializers,
          AdminDriverRequestsGet200ResponseRequestsInnerStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  AdminDriverRequestsGet200ResponseRequestsInnerStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      AdminDriverRequestsGet200ResponseRequestsInnerStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$AdminDriverRequestsGet200ResponseRequestsInner
    extends AdminDriverRequestsGet200ResponseRequestsInner {
  @override
  final String id;
  @override
  final AdminDriverRequestsGet200ResponseRequestsInnerKindEnum kind;
  @override
  final AdminDriverRequestsGet200ResponseRequestsInnerStatusEnum status;
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
  @override
  final String driverId;
  @override
  final String? decidedBy;

  factory _$AdminDriverRequestsGet200ResponseRequestsInner(
          [void Function(AdminDriverRequestsGet200ResponseRequestsInnerBuilder)?
              updates]) =>
      (AdminDriverRequestsGet200ResponseRequestsInnerBuilder()..update(updates))
          ._build();

  _$AdminDriverRequestsGet200ResponseRequestsInner._(
      {required this.id,
      required this.kind,
      required this.status,
      this.routeId,
      this.fromDate,
      this.toDate,
      this.note,
      this.decisionNote,
      this.decidedAt,
      required this.createdAt,
      required this.driverId,
      this.decidedBy})
      : super._();
  @override
  AdminDriverRequestsGet200ResponseRequestsInner rebuild(
          void Function(AdminDriverRequestsGet200ResponseRequestsInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminDriverRequestsGet200ResponseRequestsInnerBuilder toBuilder() =>
      AdminDriverRequestsGet200ResponseRequestsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminDriverRequestsGet200ResponseRequestsInner &&
        id == other.id &&
        kind == other.kind &&
        status == other.status &&
        routeId == other.routeId &&
        fromDate == other.fromDate &&
        toDate == other.toDate &&
        note == other.note &&
        decisionNote == other.decisionNote &&
        decidedAt == other.decidedAt &&
        createdAt == other.createdAt &&
        driverId == other.driverId &&
        decidedBy == other.decidedBy;
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
    _$hash = $jc(_$hash, driverId.hashCode);
    _$hash = $jc(_$hash, decidedBy.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'AdminDriverRequestsGet200ResponseRequestsInner')
          ..add('id', id)
          ..add('kind', kind)
          ..add('status', status)
          ..add('routeId', routeId)
          ..add('fromDate', fromDate)
          ..add('toDate', toDate)
          ..add('note', note)
          ..add('decisionNote', decisionNote)
          ..add('decidedAt', decidedAt)
          ..add('createdAt', createdAt)
          ..add('driverId', driverId)
          ..add('decidedBy', decidedBy))
        .toString();
  }
}

class AdminDriverRequestsGet200ResponseRequestsInnerBuilder
    implements
        Builder<AdminDriverRequestsGet200ResponseRequestsInner,
            AdminDriverRequestsGet200ResponseRequestsInnerBuilder> {
  _$AdminDriverRequestsGet200ResponseRequestsInner? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  AdminDriverRequestsGet200ResponseRequestsInnerKindEnum? _kind;
  AdminDriverRequestsGet200ResponseRequestsInnerKindEnum? get kind =>
      _$this._kind;
  set kind(AdminDriverRequestsGet200ResponseRequestsInnerKindEnum? kind) =>
      _$this._kind = kind;

  AdminDriverRequestsGet200ResponseRequestsInnerStatusEnum? _status;
  AdminDriverRequestsGet200ResponseRequestsInnerStatusEnum? get status =>
      _$this._status;
  set status(
          AdminDriverRequestsGet200ResponseRequestsInnerStatusEnum? status) =>
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

  String? _driverId;
  String? get driverId => _$this._driverId;
  set driverId(String? driverId) => _$this._driverId = driverId;

  String? _decidedBy;
  String? get decidedBy => _$this._decidedBy;
  set decidedBy(String? decidedBy) => _$this._decidedBy = decidedBy;

  AdminDriverRequestsGet200ResponseRequestsInnerBuilder() {
    AdminDriverRequestsGet200ResponseRequestsInner._defaults(this);
  }

  AdminDriverRequestsGet200ResponseRequestsInnerBuilder get _$this {
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
      _driverId = $v.driverId;
      _decidedBy = $v.decidedBy;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminDriverRequestsGet200ResponseRequestsInner other) {
    _$v = other as _$AdminDriverRequestsGet200ResponseRequestsInner;
  }

  @override
  void update(
      void Function(AdminDriverRequestsGet200ResponseRequestsInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminDriverRequestsGet200ResponseRequestsInner build() => _build();

  _$AdminDriverRequestsGet200ResponseRequestsInner _build() {
    final _$result = _$v ??
        _$AdminDriverRequestsGet200ResponseRequestsInner._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'AdminDriverRequestsGet200ResponseRequestsInner', 'id'),
          kind: BuiltValueNullFieldError.checkNotNull(
              kind, r'AdminDriverRequestsGet200ResponseRequestsInner', 'kind'),
          status: BuiltValueNullFieldError.checkNotNull(status,
              r'AdminDriverRequestsGet200ResponseRequestsInner', 'status'),
          routeId: routeId,
          fromDate: fromDate,
          toDate: toDate,
          note: note,
          decisionNote: decisionNote,
          decidedAt: decidedAt,
          createdAt: BuiltValueNullFieldError.checkNotNull(createdAt,
              r'AdminDriverRequestsGet200ResponseRequestsInner', 'createdAt'),
          driverId: BuiltValueNullFieldError.checkNotNull(driverId,
              r'AdminDriverRequestsGet200ResponseRequestsInner', 'driverId'),
          decidedBy: decidedBy,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
