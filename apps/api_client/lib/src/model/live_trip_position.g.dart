// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_trip_position.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$LiveTripPosition extends LiveTripPosition {
  @override
  final Point location;
  @override
  final DateTime capturedAt;
  @override
  final DateTime receivedAt;
  @override
  final int ageSeconds;

  factory _$LiveTripPosition(
          [void Function(LiveTripPositionBuilder)? updates]) =>
      (LiveTripPositionBuilder()..update(updates))._build();

  _$LiveTripPosition._(
      {required this.location,
      required this.capturedAt,
      required this.receivedAt,
      required this.ageSeconds})
      : super._();
  @override
  LiveTripPosition rebuild(void Function(LiveTripPositionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  LiveTripPositionBuilder toBuilder() =>
      LiveTripPositionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is LiveTripPosition &&
        location == other.location &&
        capturedAt == other.capturedAt &&
        receivedAt == other.receivedAt &&
        ageSeconds == other.ageSeconds;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, location.hashCode);
    _$hash = $jc(_$hash, capturedAt.hashCode);
    _$hash = $jc(_$hash, receivedAt.hashCode);
    _$hash = $jc(_$hash, ageSeconds.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'LiveTripPosition')
          ..add('location', location)
          ..add('capturedAt', capturedAt)
          ..add('receivedAt', receivedAt)
          ..add('ageSeconds', ageSeconds))
        .toString();
  }
}

class LiveTripPositionBuilder
    implements Builder<LiveTripPosition, LiveTripPositionBuilder> {
  _$LiveTripPosition? _$v;

  PointBuilder? _location;
  PointBuilder get location => _$this._location ??= PointBuilder();
  set location(PointBuilder? location) => _$this._location = location;

  DateTime? _capturedAt;
  DateTime? get capturedAt => _$this._capturedAt;
  set capturedAt(DateTime? capturedAt) => _$this._capturedAt = capturedAt;

  DateTime? _receivedAt;
  DateTime? get receivedAt => _$this._receivedAt;
  set receivedAt(DateTime? receivedAt) => _$this._receivedAt = receivedAt;

  int? _ageSeconds;
  int? get ageSeconds => _$this._ageSeconds;
  set ageSeconds(int? ageSeconds) => _$this._ageSeconds = ageSeconds;

  LiveTripPositionBuilder() {
    LiveTripPosition._defaults(this);
  }

  LiveTripPositionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _location = $v.location.toBuilder();
      _capturedAt = $v.capturedAt;
      _receivedAt = $v.receivedAt;
      _ageSeconds = $v.ageSeconds;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(LiveTripPosition other) {
    _$v = other as _$LiveTripPosition;
  }

  @override
  void update(void Function(LiveTripPositionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  LiveTripPosition build() => _build();

  _$LiveTripPosition _build() {
    _$LiveTripPosition _$result;
    try {
      _$result = _$v ??
          _$LiveTripPosition._(
            location: location.build(),
            capturedAt: BuiltValueNullFieldError.checkNotNull(
                capturedAt, r'LiveTripPosition', 'capturedAt'),
            receivedAt: BuiltValueNullFieldError.checkNotNull(
                receivedAt, r'LiveTripPosition', 'receivedAt'),
            ageSeconds: BuiltValueNullFieldError.checkNotNull(
                ageSeconds, r'LiveTripPosition', 'ageSeconds'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'location';
        location.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'LiveTripPosition', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
