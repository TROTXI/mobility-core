// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restriction.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Restriction extends Restriction {
  @override
  final String id;
  @override
  final String userId;
  @override
  final String reason;
  @override
  final DateTime reviewAt;
  @override
  final bool active;
  @override
  final String editToken;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final int version;

  factory _$Restriction([void Function(RestrictionBuilder)? updates]) =>
      (RestrictionBuilder()..update(updates))._build();

  _$Restriction._(
      {required this.id,
      required this.userId,
      required this.reason,
      required this.reviewAt,
      required this.active,
      required this.editToken,
      required this.createdAt,
      required this.updatedAt,
      required this.version})
      : super._();
  @override
  Restriction rebuild(void Function(RestrictionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RestrictionBuilder toBuilder() => RestrictionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Restriction &&
        id == other.id &&
        userId == other.userId &&
        reason == other.reason &&
        reviewAt == other.reviewAt &&
        active == other.active &&
        editToken == other.editToken &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        version == other.version;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jc(_$hash, reviewAt.hashCode);
    _$hash = $jc(_$hash, active.hashCode);
    _$hash = $jc(_$hash, editToken.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Restriction')
          ..add('id', id)
          ..add('userId', userId)
          ..add('reason', reason)
          ..add('reviewAt', reviewAt)
          ..add('active', active)
          ..add('editToken', editToken)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt)
          ..add('version', version))
        .toString();
  }
}

class RestrictionBuilder implements Builder<Restriction, RestrictionBuilder> {
  _$Restriction? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  DateTime? _reviewAt;
  DateTime? get reviewAt => _$this._reviewAt;
  set reviewAt(DateTime? reviewAt) => _$this._reviewAt = reviewAt;

  bool? _active;
  bool? get active => _$this._active;
  set active(bool? active) => _$this._active = active;

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

  RestrictionBuilder() {
    Restriction._defaults(this);
  }

  RestrictionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _userId = $v.userId;
      _reason = $v.reason;
      _reviewAt = $v.reviewAt;
      _active = $v.active;
      _editToken = $v.editToken;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _version = $v.version;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Restriction other) {
    _$v = other as _$Restriction;
  }

  @override
  void update(void Function(RestrictionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Restriction build() => _build();

  _$Restriction _build() {
    final _$result = _$v ??
        _$Restriction._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'Restriction', 'id'),
          userId: BuiltValueNullFieldError.checkNotNull(
              userId, r'Restriction', 'userId'),
          reason: BuiltValueNullFieldError.checkNotNull(
              reason, r'Restriction', 'reason'),
          reviewAt: BuiltValueNullFieldError.checkNotNull(
              reviewAt, r'Restriction', 'reviewAt'),
          active: BuiltValueNullFieldError.checkNotNull(
              active, r'Restriction', 'active'),
          editToken: BuiltValueNullFieldError.checkNotNull(
              editToken, r'Restriction', 'editToken'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'Restriction', 'createdAt'),
          updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt, r'Restriction', 'updatedAt'),
          version: BuiltValueNullFieldError.checkNotNull(
              version, r'Restriction', 'version'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
