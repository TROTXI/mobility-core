// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Get200Response extends Get200Response {
  @override
  final String service;
  @override
  final String version;
  @override
  final String docs;
  @override
  final String health;

  factory _$Get200Response([void Function(Get200ResponseBuilder)? updates]) =>
      (Get200ResponseBuilder()..update(updates))._build();

  _$Get200Response._(
      {required this.service,
      required this.version,
      required this.docs,
      required this.health})
      : super._();
  @override
  Get200Response rebuild(void Function(Get200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  Get200ResponseBuilder toBuilder() => Get200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Get200Response &&
        service == other.service &&
        version == other.version &&
        docs == other.docs &&
        health == other.health;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, service.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jc(_$hash, docs.hashCode);
    _$hash = $jc(_$hash, health.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Get200Response')
          ..add('service', service)
          ..add('version', version)
          ..add('docs', docs)
          ..add('health', health))
        .toString();
  }
}

class Get200ResponseBuilder
    implements Builder<Get200Response, Get200ResponseBuilder> {
  _$Get200Response? _$v;

  String? _service;
  String? get service => _$this._service;
  set service(String? service) => _$this._service = service;

  String? _version;
  String? get version => _$this._version;
  set version(String? version) => _$this._version = version;

  String? _docs;
  String? get docs => _$this._docs;
  set docs(String? docs) => _$this._docs = docs;

  String? _health;
  String? get health => _$this._health;
  set health(String? health) => _$this._health = health;

  Get200ResponseBuilder() {
    Get200Response._defaults(this);
  }

  Get200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _service = $v.service;
      _version = $v.version;
      _docs = $v.docs;
      _health = $v.health;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Get200Response other) {
    _$v = other as _$Get200Response;
  }

  @override
  void update(void Function(Get200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Get200Response build() => _build();

  _$Get200Response _build() {
    final _$result = _$v ??
        _$Get200Response._(
          service: BuiltValueNullFieldError.checkNotNull(
              service, r'Get200Response', 'service'),
          version: BuiltValueNullFieldError.checkNotNull(
              version, r'Get200Response', 'version'),
          docs: BuiltValueNullFieldError.checkNotNull(
              docs, r'Get200Response', 'docs'),
          health: BuiltValueNullFieldError.checkNotNull(
              health, r'Get200Response', 'health'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
