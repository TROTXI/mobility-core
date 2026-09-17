// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stop_edit.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$StopEdit extends StopEdit {
  @override
  final String? name;
  @override
  final Point? location;
  @override
  final bool? archived;

  factory _$StopEdit([void Function(StopEditBuilder)? updates]) =>
      (StopEditBuilder()..update(updates))._build();

  _$StopEdit._({this.name, this.location, this.archived}) : super._();
  @override
  StopEdit rebuild(void Function(StopEditBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  StopEditBuilder toBuilder() => StopEditBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is StopEdit &&
        name == other.name &&
        location == other.location &&
        archived == other.archived;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, location.hashCode);
    _$hash = $jc(_$hash, archived.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'StopEdit')
          ..add('name', name)
          ..add('location', location)
          ..add('archived', archived))
        .toString();
  }
}

class StopEditBuilder implements Builder<StopEdit, StopEditBuilder> {
  _$StopEdit? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  PointBuilder? _location;
  PointBuilder get location => _$this._location ??= PointBuilder();
  set location(PointBuilder? location) => _$this._location = location;

  bool? _archived;
  bool? get archived => _$this._archived;
  set archived(bool? archived) => _$this._archived = archived;

  StopEditBuilder() {
    StopEdit._defaults(this);
  }

  StopEditBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _location = $v.location?.toBuilder();
      _archived = $v.archived;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(StopEdit other) {
    _$v = other as _$StopEdit;
  }

  @override
  void update(void Function(StopEditBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  StopEdit build() => _build();

  _$StopEdit _build() {
    _$StopEdit _$result;
    try {
      _$result = _$v ??
          _$StopEdit._(
            name: name,
            location: _location?.build(),
            archived: archived,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'location';
        _location?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'StopEdit', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
