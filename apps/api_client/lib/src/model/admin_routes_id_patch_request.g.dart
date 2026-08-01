// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_routes_id_patch_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminRoutesIdPatchRequest extends AdminRoutesIdPatchRequest {
  @override
  final String? name;
  @override
  final String? description;

  factory _$AdminRoutesIdPatchRequest(
          [void Function(AdminRoutesIdPatchRequestBuilder)? updates]) =>
      (AdminRoutesIdPatchRequestBuilder()..update(updates))._build();

  _$AdminRoutesIdPatchRequest._({this.name, this.description}) : super._();
  @override
  AdminRoutesIdPatchRequest rebuild(
          void Function(AdminRoutesIdPatchRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminRoutesIdPatchRequestBuilder toBuilder() =>
      AdminRoutesIdPatchRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminRoutesIdPatchRequest &&
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
    return (newBuiltValueToStringHelper(r'AdminRoutesIdPatchRequest')
          ..add('name', name)
          ..add('description', description))
        .toString();
  }
}

class AdminRoutesIdPatchRequestBuilder
    implements
        Builder<AdminRoutesIdPatchRequest, AdminRoutesIdPatchRequestBuilder> {
  _$AdminRoutesIdPatchRequest? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  AdminRoutesIdPatchRequestBuilder() {
    AdminRoutesIdPatchRequest._defaults(this);
  }

  AdminRoutesIdPatchRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _description = $v.description;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminRoutesIdPatchRequest other) {
    _$v = other as _$AdminRoutesIdPatchRequest;
  }

  @override
  void update(void Function(AdminRoutesIdPatchRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminRoutesIdPatchRequest build() => _build();

  _$AdminRoutesIdPatchRequest _build() {
    final _$result = _$v ??
        _$AdminRoutesIdPatchRequest._(
          name: name,
          description: description,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
