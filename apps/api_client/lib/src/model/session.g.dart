// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Session extends Session {
  @override
  final String id;
  @override
  final DateTime createdAt;
  @override
  final DateTime expiresAt;
  @override
  final bool current;

  factory _$Session([void Function(SessionBuilder)? updates]) =>
      (SessionBuilder()..update(updates))._build();

  _$Session._(
      {required this.id,
      required this.createdAt,
      required this.expiresAt,
      required this.current})
      : super._();
  @override
  Session rebuild(void Function(SessionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SessionBuilder toBuilder() => SessionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Session &&
        id == other.id &&
        createdAt == other.createdAt &&
        expiresAt == other.expiresAt &&
        current == other.current;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, expiresAt.hashCode);
    _$hash = $jc(_$hash, current.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Session')
          ..add('id', id)
          ..add('createdAt', createdAt)
          ..add('expiresAt', expiresAt)
          ..add('current', current))
        .toString();
  }
}

class SessionBuilder implements Builder<Session, SessionBuilder> {
  _$Session? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _expiresAt;
  DateTime? get expiresAt => _$this._expiresAt;
  set expiresAt(DateTime? expiresAt) => _$this._expiresAt = expiresAt;

  bool? _current;
  bool? get current => _$this._current;
  set current(bool? current) => _$this._current = current;

  SessionBuilder() {
    Session._defaults(this);
  }

  SessionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _createdAt = $v.createdAt;
      _expiresAt = $v.expiresAt;
      _current = $v.current;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Session other) {
    _$v = other as _$Session;
  }

  @override
  void update(void Function(SessionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Session build() => _build();

  _$Session _build() {
    final _$result = _$v ??
        _$Session._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'Session', 'id'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'Session', 'createdAt'),
          expiresAt: BuiltValueNullFieldError.checkNotNull(
              expiresAt, r'Session', 'expiresAt'),
          current: BuiltValueNullFieldError.checkNotNull(
              current, r'Session', 'current'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
