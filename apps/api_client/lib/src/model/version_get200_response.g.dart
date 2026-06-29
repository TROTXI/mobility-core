// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'version_get200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$VersionGet200Response extends VersionGet200Response {
  @override
  final String name;
  @override
  final String version;
  @override
  final String commit;

  factory _$VersionGet200Response(
          [void Function(VersionGet200ResponseBuilder)? updates]) =>
      (VersionGet200ResponseBuilder()..update(updates))._build();

  _$VersionGet200Response._(
      {required this.name, required this.version, required this.commit})
      : super._();
  @override
  VersionGet200Response rebuild(
          void Function(VersionGet200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  VersionGet200ResponseBuilder toBuilder() =>
      VersionGet200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is VersionGet200Response &&
        name == other.name &&
        version == other.version &&
        commit == other.commit;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jc(_$hash, commit.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'VersionGet200Response')
          ..add('name', name)
          ..add('version', version)
          ..add('commit', commit))
        .toString();
  }
}

class VersionGet200ResponseBuilder
    implements Builder<VersionGet200Response, VersionGet200ResponseBuilder> {
  _$VersionGet200Response? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _version;
  String? get version => _$this._version;
  set version(String? version) => _$this._version = version;

  String? _commit;
  String? get commit => _$this._commit;
  set commit(String? commit) => _$this._commit = commit;

  VersionGet200ResponseBuilder() {
    VersionGet200Response._defaults(this);
  }

  VersionGet200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _version = $v.version;
      _commit = $v.commit;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(VersionGet200Response other) {
    _$v = other as _$VersionGet200Response;
  }

  @override
  void update(void Function(VersionGet200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  VersionGet200Response build() => _build();

  _$VersionGet200Response _build() {
    final _$result = _$v ??
        _$VersionGet200Response._(
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'VersionGet200Response', 'name'),
          version: BuiltValueNullFieldError.checkNotNull(
              version, r'VersionGet200Response', 'version'),
          commit: BuiltValueNullFieldError.checkNotNull(
              commit, r'VersionGet200Response', 'commit'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
