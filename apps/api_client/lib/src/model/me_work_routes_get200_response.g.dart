// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'me_work_routes_get200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MeWorkRoutesGet200Response extends MeWorkRoutesGet200Response {
  @override
  final BuiltList<MeWorkRoutesGet200ResponseRoutesInner> routes;

  factory _$MeWorkRoutesGet200Response(
          [void Function(MeWorkRoutesGet200ResponseBuilder)? updates]) =>
      (MeWorkRoutesGet200ResponseBuilder()..update(updates))._build();

  _$MeWorkRoutesGet200Response._({required this.routes}) : super._();
  @override
  MeWorkRoutesGet200Response rebuild(
          void Function(MeWorkRoutesGet200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MeWorkRoutesGet200ResponseBuilder toBuilder() =>
      MeWorkRoutesGet200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MeWorkRoutesGet200Response && routes == other.routes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, routes.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MeWorkRoutesGet200Response')
          ..add('routes', routes))
        .toString();
  }
}

class MeWorkRoutesGet200ResponseBuilder
    implements
        Builder<MeWorkRoutesGet200Response, MeWorkRoutesGet200ResponseBuilder> {
  _$MeWorkRoutesGet200Response? _$v;

  ListBuilder<MeWorkRoutesGet200ResponseRoutesInner>? _routes;
  ListBuilder<MeWorkRoutesGet200ResponseRoutesInner> get routes =>
      _$this._routes ??= ListBuilder<MeWorkRoutesGet200ResponseRoutesInner>();
  set routes(ListBuilder<MeWorkRoutesGet200ResponseRoutesInner>? routes) =>
      _$this._routes = routes;

  MeWorkRoutesGet200ResponseBuilder() {
    MeWorkRoutesGet200Response._defaults(this);
  }

  MeWorkRoutesGet200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _routes = $v.routes.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MeWorkRoutesGet200Response other) {
    _$v = other as _$MeWorkRoutesGet200Response;
  }

  @override
  void update(void Function(MeWorkRoutesGet200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MeWorkRoutesGet200Response build() => _build();

  _$MeWorkRoutesGet200Response _build() {
    _$MeWorkRoutesGet200Response _$result;
    try {
      _$result = _$v ??
          _$MeWorkRoutesGet200Response._(
            routes: routes.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'routes';
        routes.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'MeWorkRoutesGet200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
