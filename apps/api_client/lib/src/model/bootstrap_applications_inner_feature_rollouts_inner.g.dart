// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bootstrap_applications_inner_feature_rollouts_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BootstrapApplicationsInnerFeatureRolloutsInner
    extends BootstrapApplicationsInnerFeatureRolloutsInner {
  @override
  final String key;
  @override
  final int minimumBuild;

  factory _$BootstrapApplicationsInnerFeatureRolloutsInner(
          [void Function(BootstrapApplicationsInnerFeatureRolloutsInnerBuilder)?
              updates]) =>
      (BootstrapApplicationsInnerFeatureRolloutsInnerBuilder()..update(updates))
          ._build();

  _$BootstrapApplicationsInnerFeatureRolloutsInner._(
      {required this.key, required this.minimumBuild})
      : super._();
  @override
  BootstrapApplicationsInnerFeatureRolloutsInner rebuild(
          void Function(BootstrapApplicationsInnerFeatureRolloutsInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BootstrapApplicationsInnerFeatureRolloutsInnerBuilder toBuilder() =>
      BootstrapApplicationsInnerFeatureRolloutsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BootstrapApplicationsInnerFeatureRolloutsInner &&
        key == other.key &&
        minimumBuild == other.minimumBuild;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, key.hashCode);
    _$hash = $jc(_$hash, minimumBuild.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'BootstrapApplicationsInnerFeatureRolloutsInner')
          ..add('key', key)
          ..add('minimumBuild', minimumBuild))
        .toString();
  }
}

class BootstrapApplicationsInnerFeatureRolloutsInnerBuilder
    implements
        Builder<BootstrapApplicationsInnerFeatureRolloutsInner,
            BootstrapApplicationsInnerFeatureRolloutsInnerBuilder> {
  _$BootstrapApplicationsInnerFeatureRolloutsInner? _$v;

  String? _key;
  String? get key => _$this._key;
  set key(String? key) => _$this._key = key;

  int? _minimumBuild;
  int? get minimumBuild => _$this._minimumBuild;
  set minimumBuild(int? minimumBuild) => _$this._minimumBuild = minimumBuild;

  BootstrapApplicationsInnerFeatureRolloutsInnerBuilder() {
    BootstrapApplicationsInnerFeatureRolloutsInner._defaults(this);
  }

  BootstrapApplicationsInnerFeatureRolloutsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _key = $v.key;
      _minimumBuild = $v.minimumBuild;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BootstrapApplicationsInnerFeatureRolloutsInner other) {
    _$v = other as _$BootstrapApplicationsInnerFeatureRolloutsInner;
  }

  @override
  void update(
      void Function(BootstrapApplicationsInnerFeatureRolloutsInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  BootstrapApplicationsInnerFeatureRolloutsInner build() => _build();

  _$BootstrapApplicationsInnerFeatureRolloutsInner _build() {
    final _$result = _$v ??
        _$BootstrapApplicationsInnerFeatureRolloutsInner._(
          key: BuiltValueNullFieldError.checkNotNull(
              key, r'BootstrapApplicationsInnerFeatureRolloutsInner', 'key'),
          minimumBuild: BuiltValueNullFieldError.checkNotNull(
              minimumBuild,
              r'BootstrapApplicationsInnerFeatureRolloutsInner',
              'minimumBuild'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
