// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stop.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Stop extends Stop {
  @override
  final String id;
  @override
  final String name;
  @override
  final Point location;
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

  factory _$Stop([void Function(StopBuilder)? updates]) =>
      (StopBuilder()..update(updates))._build();

  _$Stop._(
      {required this.id,
      required this.name,
      required this.location,
      required this.archived,
      required this.editToken,
      required this.createdAt,
      required this.updatedAt,
      required this.version})
      : super._();
  @override
  Stop rebuild(void Function(StopBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  StopBuilder toBuilder() => StopBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Stop &&
        id == other.id &&
        name == other.name &&
        location == other.location &&
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
    _$hash = $jc(_$hash, location.hashCode);
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
    return (newBuiltValueToStringHelper(r'Stop')
          ..add('id', id)
          ..add('name', name)
          ..add('location', location)
          ..add('archived', archived)
          ..add('editToken', editToken)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt)
          ..add('version', version))
        .toString();
  }
}

class StopBuilder implements Builder<Stop, StopBuilder> {
  _$Stop? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  PointBuilder? _location;
  PointBuilder get location => _$this._location ??= PointBuilder();
  set location(PointBuilder? location) => _$this._location = location;

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

  StopBuilder() {
    Stop._defaults(this);
  }

  StopBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _location = $v.location.toBuilder();
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
  void replace(Stop other) {
    _$v = other as _$Stop;
  }

  @override
  void update(void Function(StopBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Stop build() => _build();

  _$Stop _build() {
    _$Stop _$result;
    try {
      _$result = _$v ??
          _$Stop._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'Stop', 'id'),
            name: BuiltValueNullFieldError.checkNotNull(name, r'Stop', 'name'),
            location: location.build(),
            archived: BuiltValueNullFieldError.checkNotNull(
                archived, r'Stop', 'archived'),
            editToken: BuiltValueNullFieldError.checkNotNull(
                editToken, r'Stop', 'editToken'),
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'Stop', 'createdAt'),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
                updatedAt, r'Stop', 'updatedAt'),
            version: BuiltValueNullFieldError.checkNotNull(
                version, r'Stop', 'version'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'location';
        location.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(r'Stop', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
