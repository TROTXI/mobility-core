// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_edit.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RouteEdit extends RouteEdit {
  @override
  final String? name;
  @override
  final String? description;
  @override
  final bool? acceptsDriverRequests;
  @override
  final bool? archived;

  factory _$RouteEdit([void Function(RouteEditBuilder)? updates]) =>
      (RouteEditBuilder()..update(updates))._build();

  _$RouteEdit._(
      {this.name, this.description, this.acceptsDriverRequests, this.archived})
      : super._();
  @override
  RouteEdit rebuild(void Function(RouteEditBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RouteEditBuilder toBuilder() => RouteEditBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RouteEdit &&
        name == other.name &&
        description == other.description &&
        acceptsDriverRequests == other.acceptsDriverRequests &&
        archived == other.archived;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, acceptsDriverRequests.hashCode);
    _$hash = $jc(_$hash, archived.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RouteEdit')
          ..add('name', name)
          ..add('description', description)
          ..add('acceptsDriverRequests', acceptsDriverRequests)
          ..add('archived', archived))
        .toString();
  }
}

class RouteEditBuilder implements Builder<RouteEdit, RouteEditBuilder> {
  _$RouteEdit? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  bool? _acceptsDriverRequests;
  bool? get acceptsDriverRequests => _$this._acceptsDriverRequests;
  set acceptsDriverRequests(bool? acceptsDriverRequests) =>
      _$this._acceptsDriverRequests = acceptsDriverRequests;

  bool? _archived;
  bool? get archived => _$this._archived;
  set archived(bool? archived) => _$this._archived = archived;

  RouteEditBuilder() {
    RouteEdit._defaults(this);
  }

  RouteEditBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _description = $v.description;
      _acceptsDriverRequests = $v.acceptsDriverRequests;
      _archived = $v.archived;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RouteEdit other) {
    _$v = other as _$RouteEdit;
  }

  @override
  void update(void Function(RouteEditBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RouteEdit build() => _build();

  _$RouteEdit _build() {
    final _$result = _$v ??
        _$RouteEdit._(
          name: name,
          description: description,
          acceptsDriverRequests: acceptsDriverRequests,
          archived: archived,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
