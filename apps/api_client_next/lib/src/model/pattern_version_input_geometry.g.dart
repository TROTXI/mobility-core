// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pattern_version_input_geometry.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PatternVersionInputGeometry extends PatternVersionInputGeometry {
  @override
  final BuiltList<Point> points;
  @override
  final BuiltList<num> stopDistancesMeters;

  factory _$PatternVersionInputGeometry(
          [void Function(PatternVersionInputGeometryBuilder)? updates]) =>
      (PatternVersionInputGeometryBuilder()..update(updates))._build();

  _$PatternVersionInputGeometry._(
      {required this.points, required this.stopDistancesMeters})
      : super._();
  @override
  PatternVersionInputGeometry rebuild(
          void Function(PatternVersionInputGeometryBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PatternVersionInputGeometryBuilder toBuilder() =>
      PatternVersionInputGeometryBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PatternVersionInputGeometry &&
        points == other.points &&
        stopDistancesMeters == other.stopDistancesMeters;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, points.hashCode);
    _$hash = $jc(_$hash, stopDistancesMeters.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PatternVersionInputGeometry')
          ..add('points', points)
          ..add('stopDistancesMeters', stopDistancesMeters))
        .toString();
  }
}

class PatternVersionInputGeometryBuilder
    implements
        Builder<PatternVersionInputGeometry,
            PatternVersionInputGeometryBuilder> {
  _$PatternVersionInputGeometry? _$v;

  ListBuilder<Point>? _points;
  ListBuilder<Point> get points => _$this._points ??= ListBuilder<Point>();
  set points(ListBuilder<Point>? points) => _$this._points = points;

  ListBuilder<num>? _stopDistancesMeters;
  ListBuilder<num> get stopDistancesMeters =>
      _$this._stopDistancesMeters ??= ListBuilder<num>();
  set stopDistancesMeters(ListBuilder<num>? stopDistancesMeters) =>
      _$this._stopDistancesMeters = stopDistancesMeters;

  PatternVersionInputGeometryBuilder() {
    PatternVersionInputGeometry._defaults(this);
  }

  PatternVersionInputGeometryBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _points = $v.points.toBuilder();
      _stopDistancesMeters = $v.stopDistancesMeters.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PatternVersionInputGeometry other) {
    _$v = other as _$PatternVersionInputGeometry;
  }

  @override
  void update(void Function(PatternVersionInputGeometryBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PatternVersionInputGeometry build() => _build();

  _$PatternVersionInputGeometry _build() {
    _$PatternVersionInputGeometry _$result;
    try {
      _$result = _$v ??
          _$PatternVersionInputGeometry._(
            points: points.build(),
            stopDistancesMeters: stopDistancesMeters.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'points';
        points.build();
        _$failedField = 'stopDistancesMeters';
        stopDistancesMeters.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PatternVersionInputGeometry', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
