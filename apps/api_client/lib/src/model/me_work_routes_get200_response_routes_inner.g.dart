// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'me_work_routes_get200_response_routes_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MeWorkRoutesGet200ResponseRoutesInner
    extends MeWorkRoutesGet200ResponseRoutesInner {
  @override
  final String id;
  @override
  final String name;
  @override
  final String? description;

  factory _$MeWorkRoutesGet200ResponseRoutesInner(
          [void Function(MeWorkRoutesGet200ResponseRoutesInnerBuilder)?
              updates]) =>
      (MeWorkRoutesGet200ResponseRoutesInnerBuilder()..update(updates))
          ._build();

  _$MeWorkRoutesGet200ResponseRoutesInner._(
      {required this.id, required this.name, this.description})
      : super._();
  @override
  MeWorkRoutesGet200ResponseRoutesInner rebuild(
          void Function(MeWorkRoutesGet200ResponseRoutesInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MeWorkRoutesGet200ResponseRoutesInnerBuilder toBuilder() =>
      MeWorkRoutesGet200ResponseRoutesInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MeWorkRoutesGet200ResponseRoutesInner &&
        id == other.id &&
        name == other.name &&
        description == other.description;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'MeWorkRoutesGet200ResponseRoutesInner')
          ..add('id', id)
          ..add('name', name)
          ..add('description', description))
        .toString();
  }
}

class MeWorkRoutesGet200ResponseRoutesInnerBuilder
    implements
        Builder<MeWorkRoutesGet200ResponseRoutesInner,
            MeWorkRoutesGet200ResponseRoutesInnerBuilder> {
  _$MeWorkRoutesGet200ResponseRoutesInner? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  MeWorkRoutesGet200ResponseRoutesInnerBuilder() {
    MeWorkRoutesGet200ResponseRoutesInner._defaults(this);
  }

  MeWorkRoutesGet200ResponseRoutesInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _description = $v.description;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MeWorkRoutesGet200ResponseRoutesInner other) {
    _$v = other as _$MeWorkRoutesGet200ResponseRoutesInner;
  }

  @override
  void update(
      void Function(MeWorkRoutesGet200ResponseRoutesInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MeWorkRoutesGet200ResponseRoutesInner build() => _build();

  _$MeWorkRoutesGet200ResponseRoutesInner _build() {
    final _$result = _$v ??
        _$MeWorkRoutesGet200ResponseRoutesInner._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'MeWorkRoutesGet200ResponseRoutesInner', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'MeWorkRoutesGet200ResponseRoutesInner', 'name'),
          description: description,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
