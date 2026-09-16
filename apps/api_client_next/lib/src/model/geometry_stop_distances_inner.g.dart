// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geometry_stop_distances_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GeometryStopDistancesInner extends GeometryStopDistancesInner {
  @override
  final String stopOccurrenceId;
  @override
  final num distanceMeters;

  factory _$GeometryStopDistancesInner(
          [void Function(GeometryStopDistancesInnerBuilder)? updates]) =>
      (GeometryStopDistancesInnerBuilder()..update(updates))._build();

  _$GeometryStopDistancesInner._(
      {required this.stopOccurrenceId, required this.distanceMeters})
      : super._();
  @override
  GeometryStopDistancesInner rebuild(
          void Function(GeometryStopDistancesInnerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GeometryStopDistancesInnerBuilder toBuilder() =>
      GeometryStopDistancesInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GeometryStopDistancesInner &&
        stopOccurrenceId == other.stopOccurrenceId &&
        distanceMeters == other.distanceMeters;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, stopOccurrenceId.hashCode);
    _$hash = $jc(_$hash, distanceMeters.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GeometryStopDistancesInner')
          ..add('stopOccurrenceId', stopOccurrenceId)
          ..add('distanceMeters', distanceMeters))
        .toString();
  }
}

class GeometryStopDistancesInnerBuilder
    implements
        Builder<GeometryStopDistancesInner, GeometryStopDistancesInnerBuilder> {
  _$GeometryStopDistancesInner? _$v;

  String? _stopOccurrenceId;
  String? get stopOccurrenceId => _$this._stopOccurrenceId;
  set stopOccurrenceId(String? stopOccurrenceId) =>
      _$this._stopOccurrenceId = stopOccurrenceId;

  num? _distanceMeters;
  num? get distanceMeters => _$this._distanceMeters;
  set distanceMeters(num? distanceMeters) =>
      _$this._distanceMeters = distanceMeters;

  GeometryStopDistancesInnerBuilder() {
    GeometryStopDistancesInner._defaults(this);
  }

  GeometryStopDistancesInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _stopOccurrenceId = $v.stopOccurrenceId;
      _distanceMeters = $v.distanceMeters;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GeometryStopDistancesInner other) {
    _$v = other as _$GeometryStopDistancesInner;
  }

  @override
  void update(void Function(GeometryStopDistancesInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GeometryStopDistancesInner build() => _build();

  _$GeometryStopDistancesInner _build() {
    final _$result = _$v ??
        _$GeometryStopDistancesInner._(
          stopOccurrenceId: BuiltValueNullFieldError.checkNotNull(
              stopOccurrenceId,
              r'GeometryStopDistancesInner',
              'stopOccurrenceId'),
          distanceMeters: BuiltValueNullFieldError.checkNotNull(
              distanceMeters, r'GeometryStopDistancesInner', 'distanceMeters'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
