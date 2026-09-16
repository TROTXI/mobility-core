// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pattern_version_input_stops_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PatternVersionInputStopsInner extends PatternVersionInputStopsInner {
  @override
  final String stopId;
  @override
  final String name;
  @override
  final Point location;

  factory _$PatternVersionInputStopsInner(
          [void Function(PatternVersionInputStopsInnerBuilder)? updates]) =>
      (PatternVersionInputStopsInnerBuilder()..update(updates))._build();

  _$PatternVersionInputStopsInner._(
      {required this.stopId, required this.name, required this.location})
      : super._();
  @override
  PatternVersionInputStopsInner rebuild(
          void Function(PatternVersionInputStopsInnerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PatternVersionInputStopsInnerBuilder toBuilder() =>
      PatternVersionInputStopsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PatternVersionInputStopsInner &&
        stopId == other.stopId &&
        name == other.name &&
        location == other.location;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, stopId.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, location.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PatternVersionInputStopsInner')
          ..add('stopId', stopId)
          ..add('name', name)
          ..add('location', location))
        .toString();
  }
}

class PatternVersionInputStopsInnerBuilder
    implements
        Builder<PatternVersionInputStopsInner,
            PatternVersionInputStopsInnerBuilder> {
  _$PatternVersionInputStopsInner? _$v;

  String? _stopId;
  String? get stopId => _$this._stopId;
  set stopId(String? stopId) => _$this._stopId = stopId;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  PointBuilder? _location;
  PointBuilder get location => _$this._location ??= PointBuilder();
  set location(PointBuilder? location) => _$this._location = location;

  PatternVersionInputStopsInnerBuilder() {
    PatternVersionInputStopsInner._defaults(this);
  }

  PatternVersionInputStopsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _stopId = $v.stopId;
      _name = $v.name;
      _location = $v.location.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PatternVersionInputStopsInner other) {
    _$v = other as _$PatternVersionInputStopsInner;
  }

  @override
  void update(void Function(PatternVersionInputStopsInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PatternVersionInputStopsInner build() => _build();

  _$PatternVersionInputStopsInner _build() {
    _$PatternVersionInputStopsInner _$result;
    try {
      _$result = _$v ??
          _$PatternVersionInputStopsInner._(
            stopId: BuiltValueNullFieldError.checkNotNull(
                stopId, r'PatternVersionInputStopsInner', 'stopId'),
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'PatternVersionInputStopsInner', 'name'),
            location: location.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'location';
        location.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PatternVersionInputStopsInner', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
