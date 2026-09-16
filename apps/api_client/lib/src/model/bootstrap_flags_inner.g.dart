// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bootstrap_flags_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BootstrapFlagsInner extends BootstrapFlagsInner {
  @override
  final String key;
  @override
  final bool enabled;
  @override
  final num rolloutPercentage;

  factory _$BootstrapFlagsInner(
          [void Function(BootstrapFlagsInnerBuilder)? updates]) =>
      (BootstrapFlagsInnerBuilder()..update(updates))._build();

  _$BootstrapFlagsInner._(
      {required this.key,
      required this.enabled,
      required this.rolloutPercentage})
      : super._();
  @override
  BootstrapFlagsInner rebuild(
          void Function(BootstrapFlagsInnerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BootstrapFlagsInnerBuilder toBuilder() =>
      BootstrapFlagsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BootstrapFlagsInner &&
        key == other.key &&
        enabled == other.enabled &&
        rolloutPercentage == other.rolloutPercentage;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, key.hashCode);
    _$hash = $jc(_$hash, enabled.hashCode);
    _$hash = $jc(_$hash, rolloutPercentage.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BootstrapFlagsInner')
          ..add('key', key)
          ..add('enabled', enabled)
          ..add('rolloutPercentage', rolloutPercentage))
        .toString();
  }
}

class BootstrapFlagsInnerBuilder
    implements Builder<BootstrapFlagsInner, BootstrapFlagsInnerBuilder> {
  _$BootstrapFlagsInner? _$v;

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

  BootstrapFlagsInnerBuilder() {
    BootstrapFlagsInner._defaults(this);
  }

  BootstrapFlagsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _key = $v.key;
      _enabled = $v.enabled;
      _rolloutPercentage = $v.rolloutPercentage;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BootstrapFlagsInner other) {
    _$v = other as _$BootstrapFlagsInner;
  }

  @override
  void update(void Function(BootstrapFlagsInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BootstrapFlagsInner build() => _build();

  _$BootstrapFlagsInner _build() {
    final _$result = _$v ??
        _$BootstrapFlagsInner._(
          key: BuiltValueNullFieldError.checkNotNull(
              key, r'BootstrapFlagsInner', 'key'),
          enabled: BuiltValueNullFieldError.checkNotNull(
              enabled, r'BootstrapFlagsInner', 'enabled'),
          rolloutPercentage: BuiltValueNullFieldError.checkNotNull(
              rolloutPercentage, r'BootstrapFlagsInner', 'rolloutPercentage'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
