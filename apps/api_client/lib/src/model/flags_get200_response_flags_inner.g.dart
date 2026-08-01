// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flags_get200_response_flags_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$FlagsGet200ResponseFlagsInner extends FlagsGet200ResponseFlagsInner {
  @override
  final String key;
  @override
  final bool enabled;
  @override
  final int rolloutPercentage;

  factory _$FlagsGet200ResponseFlagsInner(
          [void Function(FlagsGet200ResponseFlagsInnerBuilder)? updates]) =>
      (FlagsGet200ResponseFlagsInnerBuilder()..update(updates))._build();

  _$FlagsGet200ResponseFlagsInner._(
      {required this.key,
      required this.enabled,
      required this.rolloutPercentage})
      : super._();
  @override
  FlagsGet200ResponseFlagsInner rebuild(
          void Function(FlagsGet200ResponseFlagsInnerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FlagsGet200ResponseFlagsInnerBuilder toBuilder() =>
      FlagsGet200ResponseFlagsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FlagsGet200ResponseFlagsInner &&
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
    return (newBuiltValueToStringHelper(r'FlagsGet200ResponseFlagsInner')
          ..add('key', key)
          ..add('enabled', enabled)
          ..add('rolloutPercentage', rolloutPercentage))
        .toString();
  }
}

class FlagsGet200ResponseFlagsInnerBuilder
    implements
        Builder<FlagsGet200ResponseFlagsInner,
            FlagsGet200ResponseFlagsInnerBuilder> {
  _$FlagsGet200ResponseFlagsInner? _$v;

  String? _key;
  String? get key => _$this._key;
  set key(String? key) => _$this._key = key;

  bool? _enabled;
  bool? get enabled => _$this._enabled;
  set enabled(bool? enabled) => _$this._enabled = enabled;

  int? _rolloutPercentage;
  int? get rolloutPercentage => _$this._rolloutPercentage;
  set rolloutPercentage(int? rolloutPercentage) =>
      _$this._rolloutPercentage = rolloutPercentage;

  FlagsGet200ResponseFlagsInnerBuilder() {
    FlagsGet200ResponseFlagsInner._defaults(this);
  }

  FlagsGet200ResponseFlagsInnerBuilder get _$this {
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
  void replace(FlagsGet200ResponseFlagsInner other) {
    _$v = other as _$FlagsGet200ResponseFlagsInner;
  }

  @override
  void update(void Function(FlagsGet200ResponseFlagsInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FlagsGet200ResponseFlagsInner build() => _build();

  _$FlagsGet200ResponseFlagsInner _build() {
    final _$result = _$v ??
        _$FlagsGet200ResponseFlagsInner._(
          key: BuiltValueNullFieldError.checkNotNull(
              key, r'FlagsGet200ResponseFlagsInner', 'key'),
          enabled: BuiltValueNullFieldError.checkNotNull(
              enabled, r'FlagsGet200ResponseFlagsInner', 'enabled'),
          rolloutPercentage: BuiltValueNullFieldError.checkNotNull(
              rolloutPercentage,
              r'FlagsGet200ResponseFlagsInner',
              'rolloutPercentage'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
