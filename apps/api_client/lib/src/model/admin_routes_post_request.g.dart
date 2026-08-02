// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_routes_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminRoutesPostRequest extends AdminRoutesPostRequest {
  @override
  final String name;
  @override
  final String? description;

  factory _$AdminRoutesPostRequest(
          [void Function(AdminRoutesPostRequestBuilder)? updates]) =>
      (AdminRoutesPostRequestBuilder()..update(updates))._build();

  _$AdminRoutesPostRequest._({required this.name, this.description})
      : super._();
  @override
  AdminRoutesPostRequest rebuild(
          void Function(AdminRoutesPostRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminRoutesPostRequestBuilder toBuilder() =>
      AdminRoutesPostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminRoutesPostRequest &&
        name == other.name &&
        description == other.description;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminRoutesPostRequest')
          ..add('name', name)
          ..add('description', description))
        .toString();
  }
}

class AdminRoutesPostRequestBuilder
    implements Builder<AdminRoutesPostRequest, AdminRoutesPostRequestBuilder> {
  _$AdminRoutesPostRequest? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  AdminRoutesPostRequestBuilder() {
    AdminRoutesPostRequest._defaults(this);
  }

  AdminRoutesPostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _description = $v.description;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminRoutesPostRequest other) {
    _$v = other as _$AdminRoutesPostRequest;
  }

  @override
  void update(void Function(AdminRoutesPostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminRoutesPostRequest build() => _build();

  _$AdminRoutesPostRequest _build() {
    final _$result = _$v ??
        _$AdminRoutesPostRequest._(
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'AdminRoutesPostRequest', 'name'),
          description: description,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
