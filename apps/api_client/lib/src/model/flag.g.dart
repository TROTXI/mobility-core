// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flag.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Flag extends Flag {
  @override
  final String key;
  @override
  final bool enabled;
  @override
  final num rolloutPercentage;
  @override
  final String description;
  @override
  final int version;

  factory _$Flag([void Function(FlagBuilder)? updates]) =>
      (FlagBuilder()..update(updates))._build();

  _$Flag._(
      {required this.key,
      required this.enabled,
      required this.rolloutPercentage,
      required this.description,
      required this.version})
      : super._();
  @override
  Flag rebuild(void Function(FlagBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FlagBuilder toBuilder() => FlagBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Flag &&
        key == other.key &&
        enabled == other.enabled &&
        rolloutPercentage == other.rolloutPercentage &&
        description == other.description &&
        version == other.version;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, key.hashCode);
    _$hash = $jc(_$hash, enabled.hashCode);
    _$hash = $jc(_$hash, rolloutPercentage.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Flag')
          ..add('key', key)
          ..add('enabled', enabled)
          ..add('rolloutPercentage', rolloutPercentage)
          ..add('description', description)
          ..add('version', version))
        .toString();
  }
}

class FlagBuilder implements Builder<Flag, FlagBuilder> {
  _$Flag? _$v;

  String? _key;
  String? get key => _$this._key;
  set key(String? key) => _$this._key = key;

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

  int? _version;
  int? get version => _$this._version;
  set version(int? version) => _$this._version = version;

  FlagBuilder() {
    Flag._defaults(this);
  }

  FlagBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _key = $v.key;
      _enabled = $v.enabled;
      _rolloutPercentage = $v.rolloutPercentage;
      _description = $v.description;
      _version = $v.version;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Flag other) {
    _$v = other as _$Flag;
  }

  @override
  void update(void Function(FlagBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Flag build() => _build();

  _$Flag _build() {
    final _$result = _$v ??
        _$Flag._(
          key: BuiltValueNullFieldError.checkNotNull(key, r'Flag', 'key'),
          enabled: BuiltValueNullFieldError.checkNotNull(
              enabled, r'Flag', 'enabled'),
          rolloutPercentage: BuiltValueNullFieldError.checkNotNull(
              rolloutPercentage, r'Flag', 'rolloutPercentage'),
          description: BuiltValueNullFieldError.checkNotNull(
              description, r'Flag', 'description'),
          version: BuiltValueNullFieldError.checkNotNull(
              version, r'Flag', 'version'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
