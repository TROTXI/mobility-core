// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_min_versions_platform_put_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminMinVersionsPlatformPutRequest
    extends AdminMinVersionsPlatformPutRequest {
  @override
  final String version;

  factory _$AdminMinVersionsPlatformPutRequest(
          [void Function(AdminMinVersionsPlatformPutRequestBuilder)?
              updates]) =>
      (AdminMinVersionsPlatformPutRequestBuilder()..update(updates))._build();

  _$AdminMinVersionsPlatformPutRequest._({required this.version}) : super._();
  @override
  AdminMinVersionsPlatformPutRequest rebuild(
          void Function(AdminMinVersionsPlatformPutRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminMinVersionsPlatformPutRequestBuilder toBuilder() =>
      AdminMinVersionsPlatformPutRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminMinVersionsPlatformPutRequest &&
        version == other.version;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminMinVersionsPlatformPutRequest')
          ..add('version', version))
        .toString();
  }
}

class AdminMinVersionsPlatformPutRequestBuilder
    implements
        Builder<AdminMinVersionsPlatformPutRequest,
            AdminMinVersionsPlatformPutRequestBuilder> {
  _$AdminMinVersionsPlatformPutRequest? _$v;

  String? _version;
  String? get version => _$this._version;
  set version(String? version) => _$this._version = version;

  AdminMinVersionsPlatformPutRequestBuilder() {
    AdminMinVersionsPlatformPutRequest._defaults(this);
  }

  AdminMinVersionsPlatformPutRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _version = $v.version;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminMinVersionsPlatformPutRequest other) {
    _$v = other as _$AdminMinVersionsPlatformPutRequest;
  }

  @override
  void update(
      void Function(AdminMinVersionsPlatformPutRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminMinVersionsPlatformPutRequest build() => _build();

  _$AdminMinVersionsPlatformPutRequest _build() {
    final _$result = _$v ??
        _$AdminMinVersionsPlatformPutRequest._(
          version: BuiltValueNullFieldError.checkNotNull(
              version, r'AdminMinVersionsPlatformPutRequest', 'version'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
