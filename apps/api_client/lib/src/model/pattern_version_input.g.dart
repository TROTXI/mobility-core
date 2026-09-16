// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pattern_version_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PatternVersionInput extends PatternVersionInput {
  @override
  final BuiltList<PatternVersionInputStopsInner> stops;
  @override
  final PatternVersionInputGeometry geometry;

  factory _$PatternVersionInput(
          [void Function(PatternVersionInputBuilder)? updates]) =>
      (PatternVersionInputBuilder()..update(updates))._build();

  _$PatternVersionInput._({required this.stops, required this.geometry})
      : super._();
  @override
  PatternVersionInput rebuild(
          void Function(PatternVersionInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PatternVersionInputBuilder toBuilder() =>
      PatternVersionInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PatternVersionInput &&
        stops == other.stops &&
        geometry == other.geometry;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, stops.hashCode);
    _$hash = $jc(_$hash, geometry.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PatternVersionInput')
          ..add('stops', stops)
          ..add('geometry', geometry))
        .toString();
  }
}

class PatternVersionInputBuilder
    implements Builder<PatternVersionInput, PatternVersionInputBuilder> {
  _$PatternVersionInput? _$v;

  ListBuilder<PatternVersionInputStopsInner>? _stops;
  ListBuilder<PatternVersionInputStopsInner> get stops =>
      _$this._stops ??= ListBuilder<PatternVersionInputStopsInner>();
  set stops(ListBuilder<PatternVersionInputStopsInner>? stops) =>
      _$this._stops = stops;

  PatternVersionInputGeometryBuilder? _geometry;
  PatternVersionInputGeometryBuilder get geometry =>
      _$this._geometry ??= PatternVersionInputGeometryBuilder();
  set geometry(PatternVersionInputGeometryBuilder? geometry) =>
      _$this._geometry = geometry;

  PatternVersionInputBuilder() {
    PatternVersionInput._defaults(this);
  }

  PatternVersionInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _stops = $v.stops.toBuilder();
      _geometry = $v.geometry.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PatternVersionInput other) {
    _$v = other as _$PatternVersionInput;
  }

  @override
  void update(void Function(PatternVersionInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PatternVersionInput build() => _build();

  _$PatternVersionInput _build() {
    _$PatternVersionInput _$result;
    try {
      _$result = _$v ??
          _$PatternVersionInput._(
            stops: stops.build(),
            geometry: geometry.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'stops';
        stops.build();
        _$failedField = 'geometry';
        geometry.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PatternVersionInput', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
