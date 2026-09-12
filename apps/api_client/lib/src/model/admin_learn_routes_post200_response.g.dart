// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_learn_routes_post200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminLearnRoutesPost200Response
    extends AdminLearnRoutesPost200Response {
  @override
  final BuiltList<AdminLearnRoutesPost200ResponseRoutesInner> routes;

  factory _$AdminLearnRoutesPost200Response(
          [void Function(AdminLearnRoutesPost200ResponseBuilder)? updates]) =>
      (AdminLearnRoutesPost200ResponseBuilder()..update(updates))._build();

  _$AdminLearnRoutesPost200Response._({required this.routes}) : super._();
  @override
  AdminLearnRoutesPost200Response rebuild(
          void Function(AdminLearnRoutesPost200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminLearnRoutesPost200ResponseBuilder toBuilder() =>
      AdminLearnRoutesPost200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminLearnRoutesPost200Response && routes == other.routes;
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
    return (newBuiltValueToStringHelper(r'AdminLearnRoutesPost200Response')
          ..add('routes', routes))
        .toString();
  }
}

class AdminLearnRoutesPost200ResponseBuilder
    implements
        Builder<AdminLearnRoutesPost200Response,
            AdminLearnRoutesPost200ResponseBuilder> {
  _$AdminLearnRoutesPost200Response? _$v;

  ListBuilder<AdminLearnRoutesPost200ResponseRoutesInner>? _routes;
  ListBuilder<AdminLearnRoutesPost200ResponseRoutesInner> get routes =>
      _$this._routes ??=
          ListBuilder<AdminLearnRoutesPost200ResponseRoutesInner>();
  set routes(ListBuilder<AdminLearnRoutesPost200ResponseRoutesInner>? routes) =>
      _$this._routes = routes;

  AdminLearnRoutesPost200ResponseBuilder() {
    AdminLearnRoutesPost200Response._defaults(this);
  }

  AdminLearnRoutesPost200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _routes = $v.routes.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminLearnRoutesPost200Response other) {
    _$v = other as _$AdminLearnRoutesPost200Response;
  }

  @override
  void update(void Function(AdminLearnRoutesPost200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminLearnRoutesPost200Response build() => _build();

  _$AdminLearnRoutesPost200Response _build() {
    _$AdminLearnRoutesPost200Response _$result;
    try {
      _$result = _$v ??
          _$AdminLearnRoutesPost200Response._(
            routes: routes.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'routes';
        routes.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'AdminLearnRoutesPost200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
