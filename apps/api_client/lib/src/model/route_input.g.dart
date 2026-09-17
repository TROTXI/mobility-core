// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RouteInput extends RouteInput {
  @override
  final String name;
  @override
  final String? description;
  @override
  final bool acceptsDriverRequests;

  factory _$RouteInput([void Function(RouteInputBuilder)? updates]) =>
      (RouteInputBuilder()..update(updates))._build();

  _$RouteInput._(
      {required this.name,
      this.description,
      required this.acceptsDriverRequests})
      : super._();
  @override
  RouteInput rebuild(void Function(RouteInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RouteInputBuilder toBuilder() => RouteInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RouteInput &&
        name == other.name &&
        description == other.description &&
        acceptsDriverRequests == other.acceptsDriverRequests;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, acceptsDriverRequests.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RouteInput')
          ..add('name', name)
          ..add('description', description)
          ..add('acceptsDriverRequests', acceptsDriverRequests))
        .toString();
  }
}

class RouteInputBuilder implements Builder<RouteInput, RouteInputBuilder> {
  _$RouteInput? _$v;

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

  RouteInputBuilder() {
    RouteInput._defaults(this);
  }

  RouteInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _description = $v.description;
      _acceptsDriverRequests = $v.acceptsDriverRequests;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RouteInput other) {
    _$v = other as _$RouteInput;
  }

  @override
  void update(void Function(RouteInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RouteInput build() => _build();

  _$RouteInput _build() {
    final _$result = _$v ??
        _$RouteInput._(
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'RouteInput', 'name'),
          description: description,
          acceptsDriverRequests: BuiltValueNullFieldError.checkNotNull(
              acceptsDriverRequests, r'RouteInput', 'acceptsDriverRequests'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
