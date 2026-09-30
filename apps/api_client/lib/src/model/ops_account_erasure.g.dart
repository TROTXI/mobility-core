// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ops_account_erasure.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const OpsAccountErasureTrackedCleanupStateEnum
    _$opsAccountErasureTrackedCleanupStateEnum_pending =
    const OpsAccountErasureTrackedCleanupStateEnum._('pending');
const OpsAccountErasureTrackedCleanupStateEnum
    _$opsAccountErasureTrackedCleanupStateEnum_retryNeeded =
    const OpsAccountErasureTrackedCleanupStateEnum._('retryNeeded');
const OpsAccountErasureTrackedCleanupStateEnum
    _$opsAccountErasureTrackedCleanupStateEnum_trackedComplete =
    const OpsAccountErasureTrackedCleanupStateEnum._('trackedComplete');

OpsAccountErasureTrackedCleanupStateEnum
    _$opsAccountErasureTrackedCleanupStateEnumValueOf(String name) {
  switch (name) {
    case 'pending':
      return _$opsAccountErasureTrackedCleanupStateEnum_pending;
    case 'retryNeeded':
      return _$opsAccountErasureTrackedCleanupStateEnum_retryNeeded;
    case 'trackedComplete':
      return _$opsAccountErasureTrackedCleanupStateEnum_trackedComplete;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<OpsAccountErasureTrackedCleanupStateEnum>
    _$opsAccountErasureTrackedCleanupStateEnumValues = BuiltSet<
        OpsAccountErasureTrackedCleanupStateEnum>(const <OpsAccountErasureTrackedCleanupStateEnum>[
  _$opsAccountErasureTrackedCleanupStateEnum_pending,
  _$opsAccountErasureTrackedCleanupStateEnum_retryNeeded,
  _$opsAccountErasureTrackedCleanupStateEnum_trackedComplete,
]);

Serializer<OpsAccountErasureTrackedCleanupStateEnum>
    _$opsAccountErasureTrackedCleanupStateEnumSerializer =
    _$OpsAccountErasureTrackedCleanupStateEnumSerializer();

class _$OpsAccountErasureTrackedCleanupStateEnumSerializer
    implements PrimitiveSerializer<OpsAccountErasureTrackedCleanupStateEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'pending': 'pending',
    'retryNeeded': 'retry_needed',
    'trackedComplete': 'tracked_complete',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'pending': 'pending',
    'retry_needed': 'retryNeeded',
    'tracked_complete': 'trackedComplete',
  };

  @override
  final Iterable<Type> types = const <Type>[
    OpsAccountErasureTrackedCleanupStateEnum
  ];
  @override
  final String wireName = 'OpsAccountErasureTrackedCleanupStateEnum';

  @override
  Object serialize(Serializers serializers,
          OpsAccountErasureTrackedCleanupStateEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  OpsAccountErasureTrackedCleanupStateEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      OpsAccountErasureTrackedCleanupStateEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$OpsAccountErasure extends OpsAccountErasure {
  @override
  final String userId;
  @override
  final DateTime erasedAt;
  @override
  final int sessionsRevoked;
  @override
  final int devicesRevoked;
  @override
  final int identitiesScrubbed;
  @override
  final int trackedTasks;
  @override
  final int trackedDone;
  @override
  final int trackedCancelled;
  @override
  final int trackedPending;
  @override
  final int trackedUnavailable;
  @override
  final OpsAccountErasureTrackedCleanupStateEnum trackedCleanupState;

  factory _$OpsAccountErasure(
          [void Function(OpsAccountErasureBuilder)? updates]) =>
      (OpsAccountErasureBuilder()..update(updates))._build();

  _$OpsAccountErasure._(
      {required this.userId,
      required this.erasedAt,
      required this.sessionsRevoked,
      required this.devicesRevoked,
      required this.identitiesScrubbed,
      required this.trackedTasks,
      required this.trackedDone,
      required this.trackedCancelled,
      required this.trackedPending,
      required this.trackedUnavailable,
      required this.trackedCleanupState})
      : super._();
  @override
  OpsAccountErasure rebuild(void Function(OpsAccountErasureBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OpsAccountErasureBuilder toBuilder() =>
      OpsAccountErasureBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OpsAccountErasure &&
        userId == other.userId &&
        erasedAt == other.erasedAt &&
        sessionsRevoked == other.sessionsRevoked &&
        devicesRevoked == other.devicesRevoked &&
        identitiesScrubbed == other.identitiesScrubbed &&
        trackedTasks == other.trackedTasks &&
        trackedDone == other.trackedDone &&
        trackedCancelled == other.trackedCancelled &&
        trackedPending == other.trackedPending &&
        trackedUnavailable == other.trackedUnavailable &&
        trackedCleanupState == other.trackedCleanupState;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, erasedAt.hashCode);
    _$hash = $jc(_$hash, sessionsRevoked.hashCode);
    _$hash = $jc(_$hash, devicesRevoked.hashCode);
    _$hash = $jc(_$hash, identitiesScrubbed.hashCode);
    _$hash = $jc(_$hash, trackedTasks.hashCode);
    _$hash = $jc(_$hash, trackedDone.hashCode);
    _$hash = $jc(_$hash, trackedCancelled.hashCode);
    _$hash = $jc(_$hash, trackedPending.hashCode);
    _$hash = $jc(_$hash, trackedUnavailable.hashCode);
    _$hash = $jc(_$hash, trackedCleanupState.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OpsAccountErasure')
          ..add('userId', userId)
          ..add('erasedAt', erasedAt)
          ..add('sessionsRevoked', sessionsRevoked)
          ..add('devicesRevoked', devicesRevoked)
          ..add('identitiesScrubbed', identitiesScrubbed)
          ..add('trackedTasks', trackedTasks)
          ..add('trackedDone', trackedDone)
          ..add('trackedCancelled', trackedCancelled)
          ..add('trackedPending', trackedPending)
          ..add('trackedUnavailable', trackedUnavailable)
          ..add('trackedCleanupState', trackedCleanupState))
        .toString();
  }
}

class OpsAccountErasureBuilder
    implements Builder<OpsAccountErasure, OpsAccountErasureBuilder> {
  _$OpsAccountErasure? _$v;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

  DateTime? _erasedAt;
  DateTime? get erasedAt => _$this._erasedAt;
  set erasedAt(DateTime? erasedAt) => _$this._erasedAt = erasedAt;

  int? _sessionsRevoked;
  int? get sessionsRevoked => _$this._sessionsRevoked;
  set sessionsRevoked(int? sessionsRevoked) =>
      _$this._sessionsRevoked = sessionsRevoked;

  int? _devicesRevoked;
  int? get devicesRevoked => _$this._devicesRevoked;
  set devicesRevoked(int? devicesRevoked) =>
      _$this._devicesRevoked = devicesRevoked;

  int? _identitiesScrubbed;
  int? get identitiesScrubbed => _$this._identitiesScrubbed;
  set identitiesScrubbed(int? identitiesScrubbed) =>
      _$this._identitiesScrubbed = identitiesScrubbed;

  int? _trackedTasks;
  int? get trackedTasks => _$this._trackedTasks;
  set trackedTasks(int? trackedTasks) => _$this._trackedTasks = trackedTasks;

  int? _trackedDone;
  int? get trackedDone => _$this._trackedDone;
  set trackedDone(int? trackedDone) => _$this._trackedDone = trackedDone;

  int? _trackedCancelled;
  int? get trackedCancelled => _$this._trackedCancelled;
  set trackedCancelled(int? trackedCancelled) =>
      _$this._trackedCancelled = trackedCancelled;

  int? _trackedPending;
  int? get trackedPending => _$this._trackedPending;
  set trackedPending(int? trackedPending) =>
      _$this._trackedPending = trackedPending;

  int? _trackedUnavailable;
  int? get trackedUnavailable => _$this._trackedUnavailable;
  set trackedUnavailable(int? trackedUnavailable) =>
      _$this._trackedUnavailable = trackedUnavailable;

  OpsAccountErasureTrackedCleanupStateEnum? _trackedCleanupState;
  OpsAccountErasureTrackedCleanupStateEnum? get trackedCleanupState =>
      _$this._trackedCleanupState;
  set trackedCleanupState(
          OpsAccountErasureTrackedCleanupStateEnum? trackedCleanupState) =>
      _$this._trackedCleanupState = trackedCleanupState;

  OpsAccountErasureBuilder() {
    OpsAccountErasure._defaults(this);
  }

  OpsAccountErasureBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _userId = $v.userId;
      _erasedAt = $v.erasedAt;
      _sessionsRevoked = $v.sessionsRevoked;
      _devicesRevoked = $v.devicesRevoked;
      _identitiesScrubbed = $v.identitiesScrubbed;
      _trackedTasks = $v.trackedTasks;
      _trackedDone = $v.trackedDone;
      _trackedCancelled = $v.trackedCancelled;
      _trackedPending = $v.trackedPending;
      _trackedUnavailable = $v.trackedUnavailable;
      _trackedCleanupState = $v.trackedCleanupState;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OpsAccountErasure other) {
    _$v = other as _$OpsAccountErasure;
  }

  @override
  void update(void Function(OpsAccountErasureBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OpsAccountErasure build() => _build();

  _$OpsAccountErasure _build() {
    final _$result = _$v ??
        _$OpsAccountErasure._(
          userId: BuiltValueNullFieldError.checkNotNull(
              userId, r'OpsAccountErasure', 'userId'),
          erasedAt: BuiltValueNullFieldError.checkNotNull(
              erasedAt, r'OpsAccountErasure', 'erasedAt'),
          sessionsRevoked: BuiltValueNullFieldError.checkNotNull(
              sessionsRevoked, r'OpsAccountErasure', 'sessionsRevoked'),
          devicesRevoked: BuiltValueNullFieldError.checkNotNull(
              devicesRevoked, r'OpsAccountErasure', 'devicesRevoked'),
          identitiesScrubbed: BuiltValueNullFieldError.checkNotNull(
              identitiesScrubbed, r'OpsAccountErasure', 'identitiesScrubbed'),
          trackedTasks: BuiltValueNullFieldError.checkNotNull(
              trackedTasks, r'OpsAccountErasure', 'trackedTasks'),
          trackedDone: BuiltValueNullFieldError.checkNotNull(
              trackedDone, r'OpsAccountErasure', 'trackedDone'),
          trackedCancelled: BuiltValueNullFieldError.checkNotNull(
              trackedCancelled, r'OpsAccountErasure', 'trackedCancelled'),
          trackedPending: BuiltValueNullFieldError.checkNotNull(
              trackedPending, r'OpsAccountErasure', 'trackedPending'),
          trackedUnavailable: BuiltValueNullFieldError.checkNotNull(
              trackedUnavailable, r'OpsAccountErasure', 'trackedUnavailable'),
          trackedCleanupState: BuiltValueNullFieldError.checkNotNull(
              trackedCleanupState, r'OpsAccountErasure', 'trackedCleanupState'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
