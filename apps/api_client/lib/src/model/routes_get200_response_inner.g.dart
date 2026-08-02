// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routes_get200_response_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RoutesGet200ResponseInner extends RoutesGet200ResponseInner {
  @override
  final String id;
  @override
  final String name;
  @override
  final String? description;
  @override
  final DateTime createdAt;

  factory _$RoutesGet200ResponseInner(
          [void Function(RoutesGet200ResponseInnerBuilder)? updates]) =>
      (RoutesGet200ResponseInnerBuilder()..update(updates))._build();

  _$RoutesGet200ResponseInner._(
      {required this.id,
      required this.name,
      this.description,
      required this.createdAt})
      : super._();
  @override
  RoutesGet200ResponseInner rebuild(
          void Function(RoutesGet200ResponseInnerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RoutesGet200ResponseInnerBuilder toBuilder() =>
      RoutesGet200ResponseInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RoutesGet200ResponseInner &&
        id == other.id &&
        name == other.name &&
        description == other.description &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RoutesGet200ResponseInner')
          ..add('id', id)
          ..add('name', name)
          ..add('description', description)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class RoutesGet200ResponseInnerBuilder
    implements
        Builder<RoutesGet200ResponseInner, RoutesGet200ResponseInnerBuilder> {
  _$RoutesGet200ResponseInner? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  RoutesGet200ResponseInnerBuilder() {
    RoutesGet200ResponseInner._defaults(this);
  }

  RoutesGet200ResponseInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _description = $v.description;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RoutesGet200ResponseInner other) {
    _$v = other as _$RoutesGet200ResponseInner;
  }

  @override
  void update(void Function(RoutesGet200ResponseInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RoutesGet200ResponseInner build() => _build();

  _$RoutesGet200ResponseInner _build() {
    final _$result = _$v ??
        _$RoutesGet200ResponseInner._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'RoutesGet200ResponseInner', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'RoutesGet200ResponseInner', 'name'),
          description: description,
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'RoutesGet200ResponseInner', 'createdAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
