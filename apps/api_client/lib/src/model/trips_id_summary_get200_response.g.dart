// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trips_id_summary_get200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TripsIdSummaryGet200Response extends TripsIdSummaryGet200Response {
  @override
  final String tripId;
  @override
  final int boarded;
  @override
  final int notBoarded;
  @override
  final TripsIdSummaryGet200ResponseByMethod byMethod;
  @override
  final DateTime? startedAt;
  @override
  final DateTime? completedAt;
  @override
  final int stopCount;

  factory _$TripsIdSummaryGet200Response(
          [void Function(TripsIdSummaryGet200ResponseBuilder)? updates]) =>
      (TripsIdSummaryGet200ResponseBuilder()..update(updates))._build();

  _$TripsIdSummaryGet200Response._(
      {required this.tripId,
      required this.boarded,
      required this.notBoarded,
      required this.byMethod,
      this.startedAt,
      this.completedAt,
      required this.stopCount})
      : super._();
  @override
  TripsIdSummaryGet200Response rebuild(
          void Function(TripsIdSummaryGet200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TripsIdSummaryGet200ResponseBuilder toBuilder() =>
      TripsIdSummaryGet200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TripsIdSummaryGet200Response &&
        tripId == other.tripId &&
        boarded == other.boarded &&
        notBoarded == other.notBoarded &&
        byMethod == other.byMethod &&
        startedAt == other.startedAt &&
        completedAt == other.completedAt &&
        stopCount == other.stopCount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, tripId.hashCode);
    _$hash = $jc(_$hash, boarded.hashCode);
    _$hash = $jc(_$hash, notBoarded.hashCode);
    _$hash = $jc(_$hash, byMethod.hashCode);
    _$hash = $jc(_$hash, startedAt.hashCode);
    _$hash = $jc(_$hash, completedAt.hashCode);
    _$hash = $jc(_$hash, stopCount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TripsIdSummaryGet200Response')
          ..add('tripId', tripId)
          ..add('boarded', boarded)
          ..add('notBoarded', notBoarded)
          ..add('byMethod', byMethod)
          ..add('startedAt', startedAt)
          ..add('completedAt', completedAt)
          ..add('stopCount', stopCount))
        .toString();
  }
}

class TripsIdSummaryGet200ResponseBuilder
    implements
        Builder<TripsIdSummaryGet200Response,
            TripsIdSummaryGet200ResponseBuilder> {
  _$TripsIdSummaryGet200Response? _$v;

  String? _tripId;
  String? get tripId => _$this._tripId;
  set tripId(String? tripId) => _$this._tripId = tripId;

  int? _boarded;
  int? get boarded => _$this._boarded;
  set boarded(int? boarded) => _$this._boarded = boarded;

  int? _notBoarded;
  int? get notBoarded => _$this._notBoarded;
  set notBoarded(int? notBoarded) => _$this._notBoarded = notBoarded;

  TripsIdSummaryGet200ResponseByMethodBuilder? _byMethod;
  TripsIdSummaryGet200ResponseByMethodBuilder get byMethod =>
      _$this._byMethod ??= TripsIdSummaryGet200ResponseByMethodBuilder();
  set byMethod(TripsIdSummaryGet200ResponseByMethodBuilder? byMethod) =>
      _$this._byMethod = byMethod;

  DateTime? _startedAt;
  DateTime? get startedAt => _$this._startedAt;
  set startedAt(DateTime? startedAt) => _$this._startedAt = startedAt;

  DateTime? _completedAt;
  DateTime? get completedAt => _$this._completedAt;
  set completedAt(DateTime? completedAt) => _$this._completedAt = completedAt;

  int? _stopCount;
  int? get stopCount => _$this._stopCount;
  set stopCount(int? stopCount) => _$this._stopCount = stopCount;

  TripsIdSummaryGet200ResponseBuilder() {
    TripsIdSummaryGet200Response._defaults(this);
  }

  TripsIdSummaryGet200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _tripId = $v.tripId;
      _boarded = $v.boarded;
      _notBoarded = $v.notBoarded;
      _byMethod = $v.byMethod.toBuilder();
      _startedAt = $v.startedAt;
      _completedAt = $v.completedAt;
      _stopCount = $v.stopCount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TripsIdSummaryGet200Response other) {
    _$v = other as _$TripsIdSummaryGet200Response;
  }

  @override
  void update(void Function(TripsIdSummaryGet200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TripsIdSummaryGet200Response build() => _build();

  _$TripsIdSummaryGet200Response _build() {
    _$TripsIdSummaryGet200Response _$result;
    try {
      _$result = _$v ??
          _$TripsIdSummaryGet200Response._(
            tripId: BuiltValueNullFieldError.checkNotNull(
                tripId, r'TripsIdSummaryGet200Response', 'tripId'),
            boarded: BuiltValueNullFieldError.checkNotNull(
                boarded, r'TripsIdSummaryGet200Response', 'boarded'),
            notBoarded: BuiltValueNullFieldError.checkNotNull(
                notBoarded, r'TripsIdSummaryGet200Response', 'notBoarded'),
            byMethod: byMethod.build(),
            startedAt: startedAt,
            completedAt: completedAt,
            stopCount: BuiltValueNullFieldError.checkNotNull(
                stopCount, r'TripsIdSummaryGet200Response', 'stopCount'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'byMethod';
        byMethod.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TripsIdSummaryGet200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
