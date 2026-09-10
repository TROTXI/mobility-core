// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_routes_id_fares_get200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminRoutesIdFaresGet200Response
    extends AdminRoutesIdFaresGet200Response {
  @override
  final BuiltList<AdminRoutesIdFaresGet200ResponseFaresInner> fares;

  factory _$AdminRoutesIdFaresGet200Response(
          [void Function(AdminRoutesIdFaresGet200ResponseBuilder)? updates]) =>
      (AdminRoutesIdFaresGet200ResponseBuilder()..update(updates))._build();

  _$AdminRoutesIdFaresGet200Response._({required this.fares}) : super._();
  @override
  AdminRoutesIdFaresGet200Response rebuild(
          void Function(AdminRoutesIdFaresGet200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminRoutesIdFaresGet200ResponseBuilder toBuilder() =>
      AdminRoutesIdFaresGet200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminRoutesIdFaresGet200Response && fares == other.fares;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, fares.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminRoutesIdFaresGet200Response')
          ..add('fares', fares))
        .toString();
  }
}

class AdminRoutesIdFaresGet200ResponseBuilder
    implements
        Builder<AdminRoutesIdFaresGet200Response,
            AdminRoutesIdFaresGet200ResponseBuilder> {
  _$AdminRoutesIdFaresGet200Response? _$v;

  ListBuilder<AdminRoutesIdFaresGet200ResponseFaresInner>? _fares;
  ListBuilder<AdminRoutesIdFaresGet200ResponseFaresInner> get fares =>
      _$this._fares ??=
          ListBuilder<AdminRoutesIdFaresGet200ResponseFaresInner>();
  set fares(ListBuilder<AdminRoutesIdFaresGet200ResponseFaresInner>? fares) =>
      _$this._fares = fares;

  AdminRoutesIdFaresGet200ResponseBuilder() {
    AdminRoutesIdFaresGet200Response._defaults(this);
  }

  AdminRoutesIdFaresGet200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _fares = $v.fares.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminRoutesIdFaresGet200Response other) {
    _$v = other as _$AdminRoutesIdFaresGet200Response;
  }

  @override
  void update(void Function(AdminRoutesIdFaresGet200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminRoutesIdFaresGet200Response build() => _build();

  _$AdminRoutesIdFaresGet200Response _build() {
    _$AdminRoutesIdFaresGet200Response _$result;
    try {
      _$result = _$v ??
          _$AdminRoutesIdFaresGet200Response._(
            fares: fares.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'fares';
        fares.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'AdminRoutesIdFaresGet200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
