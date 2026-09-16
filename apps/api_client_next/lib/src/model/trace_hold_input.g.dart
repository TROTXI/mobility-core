// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trace_hold_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TraceHoldInput extends TraceHoldInput {
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

  factory _$TraceHoldInput([void Function(TraceHoldInputBuilder)? updates]) =>
      (TraceHoldInputBuilder()..update(updates))._build();

  _$TraceHoldInput._(
      {required this.incidentId,
      required this.tripId,
      required this.receivedFrom,
      required this.receivedTo,
      required this.reason,
      required this.reviewAt})
      : super._();
  @override
  TraceHoldInput rebuild(void Function(TraceHoldInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TraceHoldInputBuilder toBuilder() => TraceHoldInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TraceHoldInput &&
        incidentId == other.incidentId &&
        tripId == other.tripId &&
        receivedFrom == other.receivedFrom &&
        receivedTo == other.receivedTo &&
        reason == other.reason &&
        reviewAt == other.reviewAt;
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
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TraceHoldInput')
          ..add('incidentId', incidentId)
          ..add('tripId', tripId)
          ..add('receivedFrom', receivedFrom)
          ..add('receivedTo', receivedTo)
          ..add('reason', reason)
          ..add('reviewAt', reviewAt))
        .toString();
  }
}

class TraceHoldInputBuilder
    implements Builder<TraceHoldInput, TraceHoldInputBuilder> {
  _$TraceHoldInput? _$v;

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

  TraceHoldInputBuilder() {
    TraceHoldInput._defaults(this);
  }

  TraceHoldInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _incidentId = $v.incidentId;
      _tripId = $v.tripId;
      _receivedFrom = $v.receivedFrom;
      _receivedTo = $v.receivedTo;
      _reason = $v.reason;
      _reviewAt = $v.reviewAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TraceHoldInput other) {
    _$v = other as _$TraceHoldInput;
  }

  @override
  void update(void Function(TraceHoldInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TraceHoldInput build() => _build();

  _$TraceHoldInput _build() {
    final _$result = _$v ??
        _$TraceHoldInput._(
          incidentId: BuiltValueNullFieldError.checkNotNull(
              incidentId, r'TraceHoldInput', 'incidentId'),
          tripId: BuiltValueNullFieldError.checkNotNull(
              tripId, r'TraceHoldInput', 'tripId'),
          receivedFrom: BuiltValueNullFieldError.checkNotNull(
              receivedFrom, r'TraceHoldInput', 'receivedFrom'),
          receivedTo: BuiltValueNullFieldError.checkNotNull(
              receivedTo, r'TraceHoldInput', 'receivedTo'),
          reason: BuiltValueNullFieldError.checkNotNull(
              reason, r'TraceHoldInput', 'reason'),
          reviewAt: BuiltValueNullFieldError.checkNotNull(
              reviewAt, r'TraceHoldInput', 'reviewAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
