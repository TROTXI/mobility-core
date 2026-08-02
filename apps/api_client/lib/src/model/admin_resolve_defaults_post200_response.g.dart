// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_resolve_defaults_post200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminResolveDefaultsPost200Response
    extends AdminResolveDefaultsPost200Response {
  @override
  final int defaulted;

  factory _$AdminResolveDefaultsPost200Response(
          [void Function(AdminResolveDefaultsPost200ResponseBuilder)?
              updates]) =>
      (AdminResolveDefaultsPost200ResponseBuilder()..update(updates))._build();

  _$AdminResolveDefaultsPost200Response._({required this.defaulted})
      : super._();
  @override
  AdminResolveDefaultsPost200Response rebuild(
          void Function(AdminResolveDefaultsPost200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminResolveDefaultsPost200ResponseBuilder toBuilder() =>
      AdminResolveDefaultsPost200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminResolveDefaultsPost200Response &&
        defaulted == other.defaulted;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, defaulted.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminResolveDefaultsPost200Response')
          ..add('defaulted', defaulted))
        .toString();
  }
}

class AdminResolveDefaultsPost200ResponseBuilder
    implements
        Builder<AdminResolveDefaultsPost200Response,
            AdminResolveDefaultsPost200ResponseBuilder> {
  _$AdminResolveDefaultsPost200Response? _$v;

  int? _defaulted;
  int? get defaulted => _$this._defaulted;
  set defaulted(int? defaulted) => _$this._defaulted = defaulted;

  AdminResolveDefaultsPost200ResponseBuilder() {
    AdminResolveDefaultsPost200Response._defaults(this);
  }

  AdminResolveDefaultsPost200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _defaulted = $v.defaulted;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminResolveDefaultsPost200Response other) {
    _$v = other as _$AdminResolveDefaultsPost200Response;
  }

  @override
  void update(
      void Function(AdminResolveDefaultsPost200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminResolveDefaultsPost200Response build() => _build();

  _$AdminResolveDefaultsPost200Response _build() {
    final _$result = _$v ??
        _$AdminResolveDefaultsPost200Response._(
          defaulted: BuiltValueNullFieldError.checkNotNull(
              defaulted, r'AdminResolveDefaultsPost200Response', 'defaulted'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
