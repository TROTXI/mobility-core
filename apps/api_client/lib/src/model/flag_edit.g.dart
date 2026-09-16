// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flag_edit.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$FlagEdit extends FlagEdit {
  @override
  final bool enabled;
  @override
  final num rolloutPercentage;
  @override
  final String description;

  factory _$FlagEdit([void Function(FlagEditBuilder)? updates]) =>
      (FlagEditBuilder()..update(updates))._build();

  _$FlagEdit._(
      {required this.enabled,
      required this.rolloutPercentage,
      required this.description})
      : super._();
  @override
  FlagEdit rebuild(void Function(FlagEditBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FlagEditBuilder toBuilder() => FlagEditBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FlagEdit &&
        enabled == other.enabled &&
        rolloutPercentage == other.rolloutPercentage &&
        description == other.description;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, enabled.hashCode);
    _$hash = $jc(_$hash, rolloutPercentage.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FlagEdit')
          ..add('enabled', enabled)
          ..add('rolloutPercentage', rolloutPercentage)
          ..add('description', description))
        .toString();
  }
}

class FlagEditBuilder implements Builder<FlagEdit, FlagEditBuilder> {
  _$FlagEdit? _$v;

  bool? _enabled;
  bool? get enabled => _$this._enabled;
  set enabled(bool? enabled) => _$this._enabled = enabled;

  num? _rolloutPercentage;
  num? get rolloutPercentage => _$this._rolloutPercentage;
  set rolloutPercentage(num? rolloutPercentage) =>
      _$this._rolloutPercentage = rolloutPercentage;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  FlagEditBuilder() {
    FlagEdit._defaults(this);
  }

  FlagEditBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _enabled = $v.enabled;
      _rolloutPercentage = $v.rolloutPercentage;
      _description = $v.description;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FlagEdit other) {
    _$v = other as _$FlagEdit;
  }

  @override
  void update(void Function(FlagEditBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FlagEdit build() => _build();

  _$FlagEdit _build() {
    final _$result = _$v ??
        _$FlagEdit._(
          enabled: BuiltValueNullFieldError.checkNotNull(
              enabled, r'FlagEdit', 'enabled'),
          rolloutPercentage: BuiltValueNullFieldError.checkNotNull(
              rolloutPercentage, r'FlagEdit', 'rolloutPercentage'),
          description: BuiltValueNullFieldError.checkNotNull(
              description, r'FlagEdit', 'description'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
