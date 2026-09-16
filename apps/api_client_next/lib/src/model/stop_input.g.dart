// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stop_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$StopInput extends StopInput {
  @override
  final String name;
  @override
  final Point location;

  factory _$StopInput([void Function(StopInputBuilder)? updates]) =>
      (StopInputBuilder()..update(updates))._build();

  _$StopInput._({required this.name, required this.location}) : super._();
  @override
  StopInput rebuild(void Function(StopInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  StopInputBuilder toBuilder() => StopInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is StopInput &&
        name == other.name &&
        location == other.location;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, location.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'StopInput')
          ..add('name', name)
          ..add('location', location))
        .toString();
  }
}

class StopInputBuilder implements Builder<StopInput, StopInputBuilder> {
  _$StopInput? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  PointBuilder? _location;
  PointBuilder get location => _$this._location ??= PointBuilder();
  set location(PointBuilder? location) => _$this._location = location;

  StopInputBuilder() {
    StopInput._defaults(this);
  }

  StopInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _location = $v.location.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(StopInput other) {
    _$v = other as _$StopInput;
  }

  @override
  void update(void Function(StopInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  StopInput build() => _build();

  _$StopInput _build() {
    _$StopInput _$result;
    try {
      _$result = _$v ??
          _$StopInput._(
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'StopInput', 'name'),
            location: location.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'location';
        location.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'StopInput', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
