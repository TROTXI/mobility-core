// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Route extends Route {
  @override
  final String id;
  @override
  final String name;
  @override
  final String? description;
  @override
  final BuiltList<String> patternIds;
  @override
  final bool acceptsDriverRequests;
  @override
  final bool archived;
  @override
  final String editToken;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final int version;

  factory _$Route([void Function(RouteBuilder)? updates]) =>
      (RouteBuilder()..update(updates))._build();

  _$Route._(
      {required this.id,
      required this.name,
      this.description,
      required this.patternIds,
      required this.acceptsDriverRequests,
      required this.archived,
      required this.editToken,
      required this.createdAt,
      required this.updatedAt,
      required this.version})
      : super._();
  @override
  Route rebuild(void Function(RouteBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RouteBuilder toBuilder() => RouteBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Route &&
        id == other.id &&
        name == other.name &&
        description == other.description &&
        patternIds == other.patternIds &&
        acceptsDriverRequests == other.acceptsDriverRequests &&
        archived == other.archived &&
        editToken == other.editToken &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        version == other.version;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, patternIds.hashCode);
    _$hash = $jc(_$hash, acceptsDriverRequests.hashCode);
    _$hash = $jc(_$hash, archived.hashCode);
    _$hash = $jc(_$hash, editToken.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Route')
          ..add('id', id)
          ..add('name', name)
          ..add('description', description)
          ..add('patternIds', patternIds)
          ..add('acceptsDriverRequests', acceptsDriverRequests)
          ..add('archived', archived)
          ..add('editToken', editToken)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt)
          ..add('version', version))
        .toString();
  }
}

class RouteBuilder implements Builder<Route, RouteBuilder> {
  _$Route? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  ListBuilder<String>? _patternIds;
  ListBuilder<String> get patternIds =>
      _$this._patternIds ??= ListBuilder<String>();
  set patternIds(ListBuilder<String>? patternIds) =>
      _$this._patternIds = patternIds;

  bool? _acceptsDriverRequests;
  bool? get acceptsDriverRequests => _$this._acceptsDriverRequests;
  set acceptsDriverRequests(bool? acceptsDriverRequests) =>
      _$this._acceptsDriverRequests = acceptsDriverRequests;

  bool? _archived;
  bool? get archived => _$this._archived;
  set archived(bool? archived) => _$this._archived = archived;

  String? _editToken;
  String? get editToken => _$this._editToken;
  set editToken(String? editToken) => _$this._editToken = editToken;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  int? _version;
  int? get version => _$this._version;
  set version(int? version) => _$this._version = version;

  RouteBuilder() {
    Route._defaults(this);
  }

  RouteBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _description = $v.description;
      _patternIds = $v.patternIds.toBuilder();
      _acceptsDriverRequests = $v.acceptsDriverRequests;
      _archived = $v.archived;
      _editToken = $v.editToken;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _version = $v.version;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Route other) {
    _$v = other as _$Route;
  }

  @override
  void update(void Function(RouteBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Route build() => _build();

  _$Route _build() {
    _$Route _$result;
    try {
      _$result = _$v ??
          _$Route._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'Route', 'id'),
            name: BuiltValueNullFieldError.checkNotNull(name, r'Route', 'name'),
            description: description,
            patternIds: patternIds.build(),
            acceptsDriverRequests: BuiltValueNullFieldError.checkNotNull(
                acceptsDriverRequests, r'Route', 'acceptsDriverRequests'),
            archived: BuiltValueNullFieldError.checkNotNull(
                archived, r'Route', 'archived'),
            editToken: BuiltValueNullFieldError.checkNotNull(
                editToken, r'Route', 'editToken'),
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'Route', 'createdAt'),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
                updatedAt, r'Route', 'updatedAt'),
            version: BuiltValueNullFieldError.checkNotNull(
                version, r'Route', 'version'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'patternIds';
        patternIds.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(r'Route', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
