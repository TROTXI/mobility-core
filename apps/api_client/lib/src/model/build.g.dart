// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'build.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Build extends Build {
  @override
  final String service;
  @override
  final String version;
  @override
  final String commit;

  factory _$Build([void Function(BuildBuilder)? updates]) =>
      (BuildBuilder()..update(updates))._build();

  _$Build._(
      {required this.service, required this.version, required this.commit})
      : super._();
  @override
  Build rebuild(void Function(BuildBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BuildBuilder toBuilder() => BuildBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Build &&
        service == other.service &&
        version == other.version &&
        commit == other.commit;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, service.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jc(_$hash, commit.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Build')
          ..add('service', service)
          ..add('version', version)
          ..add('commit', commit))
        .toString();
  }
}

class BuildBuilder implements Builder<Build, BuildBuilder> {
  _$Build? _$v;

  String? _service;
  String? get service => _$this._service;
  set service(String? service) => _$this._service = service;

  String? _version;
  String? get version => _$this._version;
  set version(String? version) => _$this._version = version;

  String? _commit;
  String? get commit => _$this._commit;
  set commit(String? commit) => _$this._commit = commit;

  BuildBuilder() {
    Build._defaults(this);
  }

  BuildBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _service = $v.service;
      _version = $v.version;
      _commit = $v.commit;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Build other) {
    _$v = other as _$Build;
  }

  @override
  void update(void Function(BuildBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Build build() => _build();

  _$Build _build() {
    final _$result = _$v ??
        _$Build._(
          service: BuiltValueNullFieldError.checkNotNull(
              service, r'Build', 'service'),
          version: BuiltValueNullFieldError.checkNotNull(
              version, r'Build', 'version'),
          commit:
              BuiltValueNullFieldError.checkNotNull(commit, r'Build', 'commit'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
