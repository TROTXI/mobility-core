// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trace_hold.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const TraceHoldStateEnum _$traceHoldStateEnum_active =
    const TraceHoldStateEnum._('active');
const TraceHoldStateEnum _$traceHoldStateEnum_released =
    const TraceHoldStateEnum._('released');

TraceHoldStateEnum _$traceHoldStateEnumValueOf(String name) {
  switch (name) {
    case 'active':
      return _$traceHoldStateEnum_active;
    case 'released':
      return _$traceHoldStateEnum_released;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<TraceHoldStateEnum> _$traceHoldStateEnumValues =
    BuiltSet<TraceHoldStateEnum>(const <TraceHoldStateEnum>[
  _$traceHoldStateEnum_active,
  _$traceHoldStateEnum_released,
]);

Serializer<TraceHoldStateEnum> _$traceHoldStateEnumSerializer =
    _$TraceHoldStateEnumSerializer();

class _$TraceHoldStateEnumSerializer
    implements PrimitiveSerializer<TraceHoldStateEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'active': 'active',
    'released': 'released',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'active': 'active',
    'released': 'released',
  };

  @override
  final Iterable<Type> types = const <Type>[TraceHoldStateEnum];
  @override
  final String wireName = 'TraceHoldStateEnum';

  @override
  Object serialize(Serializers serializers, TraceHoldStateEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  TraceHoldStateEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      TraceHoldStateEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$TraceHold extends TraceHold {
  @override
  final String incidentId;
  @override
  final String tripId;
  @override
  final DateTime receivedFrom;
  @override
  final DateTime receivedTo;
  @override
  final String reason;
  @override
  final DateTime reviewAt;
  @override
  final String id;
  @override
  final TraceHoldStateEnum state;
  @override
  final String editToken;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final int version;

  factory _$TraceHold([void Function(TraceHoldBuilder)? updates]) =>
      (TraceHoldBuilder()..update(updates))._build();

  _$TraceHold._(
      {required this.incidentId,
      required this.tripId,
      required this.receivedFrom,
      required this.receivedTo,
      required this.reason,
      required this.reviewAt,
      required this.id,
      required this.state,
      required this.editToken,
      required this.createdAt,
      required this.updatedAt,
      required this.version})
      : super._();
  @override
  TraceHold rebuild(void Function(TraceHoldBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TraceHoldBuilder toBuilder() => TraceHoldBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TraceHold &&
        incidentId == other.incidentId &&
        tripId == other.tripId &&
        receivedFrom == other.receivedFrom &&
        receivedTo == other.receivedTo &&
        reason == other.reason &&
        reviewAt == other.reviewAt &&
        id == other.id &&
        state == other.state &&
        editToken == other.editToken &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        version == other.version;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, incidentId.hashCode);
    _$hash = $jc(_$hash, tripId.hashCode);
    _$hash = $jc(_$hash, receivedFrom.hashCode);
    _$hash = $jc(_$hash, receivedTo.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jc(_$hash, reviewAt.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, state.hashCode);
    _$hash = $jc(_$hash, editToken.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TraceHold')
          ..add('incidentId', incidentId)
          ..add('tripId', tripId)
          ..add('receivedFrom', receivedFrom)
          ..add('receivedTo', receivedTo)
          ..add('reason', reason)
          ..add('reviewAt', reviewAt)
          ..add('id', id)
          ..add('state', state)
          ..add('editToken', editToken)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt)
          ..add('version', version))
        .toString();
  }
}

class TraceHoldBuilder implements Builder<TraceHold, TraceHoldBuilder> {
  _$TraceHold? _$v;

  String? _incidentId;
  String? get incidentId => _$this._incidentId;
  set incidentId(String? incidentId) => _$this._incidentId = incidentId;

  String? _tripId;
  String? get tripId => _$this._tripId;
  set tripId(String? tripId) => _$this._tripId = tripId;

  DateTime? _receivedFrom;
  DateTime? get receivedFrom => _$this._receivedFrom;
  set receivedFrom(DateTime? receivedFrom) =>
      _$this._receivedFrom = receivedFrom;

  DateTime? _receivedTo;
  DateTime? get receivedTo => _$this._receivedTo;
  set receivedTo(DateTime? receivedTo) => _$this._receivedTo = receivedTo;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  DateTime? _reviewAt;
  DateTime? get reviewAt => _$this._reviewAt;
  set reviewAt(DateTime? reviewAt) => _$this._reviewAt = reviewAt;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  TraceHoldStateEnum? _state;
  TraceHoldStateEnum? get state => _$this._state;
  set state(TraceHoldStateEnum? state) => _$this._state = state;

  String? _editToken;
  String? get editToken => _$this._editToken;
  set editToken(String? editToken) => _$this._editToken = editToken;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  int? _version;
  int? get version => _$this._version;
  set version(int? version) => _$this._version = version;

  TraceHoldBuilder() {
    TraceHold._defaults(this);
  }

  TraceHoldBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _incidentId = $v.incidentId;
      _tripId = $v.tripId;
      _receivedFrom = $v.receivedFrom;
      _receivedTo = $v.receivedTo;
      _reason = $v.reason;
      _reviewAt = $v.reviewAt;
      _id = $v.id;
      _state = $v.state;
      _editToken = $v.editToken;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _version = $v.version;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TraceHold other) {
    _$v = other as _$TraceHold;
  }

  @override
  void update(void Function(TraceHoldBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TraceHold build() => _build();

  _$TraceHold _build() {
    final _$result = _$v ??
        _$TraceHold._(
          incidentId: BuiltValueNullFieldError.checkNotNull(
              incidentId, r'TraceHold', 'incidentId'),
          tripId: BuiltValueNullFieldError.checkNotNull(
              tripId, r'TraceHold', 'tripId'),
          receivedFrom: BuiltValueNullFieldError.checkNotNull(
              receivedFrom, r'TraceHold', 'receivedFrom'),
          receivedTo: BuiltValueNullFieldError.checkNotNull(
              receivedTo, r'TraceHold', 'receivedTo'),
          reason: BuiltValueNullFieldError.checkNotNull(
              reason, r'TraceHold', 'reason'),
          reviewAt: BuiltValueNullFieldError.checkNotNull(
              reviewAt, r'TraceHold', 'reviewAt'),
          id: BuiltValueNullFieldError.checkNotNull(id, r'TraceHold', 'id'),
          state: BuiltValueNullFieldError.checkNotNull(
              state, r'TraceHold', 'state'),
          editToken: BuiltValueNullFieldError.checkNotNull(
              editToken, r'TraceHold', 'editToken'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'TraceHold', 'createdAt'),
          updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt, r'TraceHold', 'updatedAt'),
          version: BuiltValueNullFieldError.checkNotNull(
              version, r'TraceHold', 'version'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
