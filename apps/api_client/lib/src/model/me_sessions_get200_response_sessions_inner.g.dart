// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'me_sessions_get200_response_sessions_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MeSessionsGet200ResponseSessionsInner
    extends MeSessionsGet200ResponseSessionsInner {
  @override
  final String id;
  @override
  final String createdAt;
  @override
  final String expiresAt;

  factory _$MeSessionsGet200ResponseSessionsInner(
          [void Function(MeSessionsGet200ResponseSessionsInnerBuilder)?
              updates]) =>
      (MeSessionsGet200ResponseSessionsInnerBuilder()..update(updates))
          ._build();

  _$MeSessionsGet200ResponseSessionsInner._(
      {required this.id, required this.createdAt, required this.expiresAt})
      : super._();
  @override
  MeSessionsGet200ResponseSessionsInner rebuild(
          void Function(MeSessionsGet200ResponseSessionsInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MeSessionsGet200ResponseSessionsInnerBuilder toBuilder() =>
      MeSessionsGet200ResponseSessionsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MeSessionsGet200ResponseSessionsInner &&
        id == other.id &&
        createdAt == other.createdAt &&
        expiresAt == other.expiresAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, expiresAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'MeSessionsGet200ResponseSessionsInner')
          ..add('id', id)
          ..add('createdAt', createdAt)
          ..add('expiresAt', expiresAt))
        .toString();
  }
}

class MeSessionsGet200ResponseSessionsInnerBuilder
    implements
        Builder<MeSessionsGet200ResponseSessionsInner,
            MeSessionsGet200ResponseSessionsInnerBuilder> {
  _$MeSessionsGet200ResponseSessionsInner? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _createdAt;
  String? get createdAt => _$this._createdAt;
  set createdAt(String? createdAt) => _$this._createdAt = createdAt;

  String? _expiresAt;
  String? get expiresAt => _$this._expiresAt;
  set expiresAt(String? expiresAt) => _$this._expiresAt = expiresAt;

  MeSessionsGet200ResponseSessionsInnerBuilder() {
    MeSessionsGet200ResponseSessionsInner._defaults(this);
  }

  MeSessionsGet200ResponseSessionsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _createdAt = $v.createdAt;
      _expiresAt = $v.expiresAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MeSessionsGet200ResponseSessionsInner other) {
    _$v = other as _$MeSessionsGet200ResponseSessionsInner;
  }

  @override
  void update(
      void Function(MeSessionsGet200ResponseSessionsInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MeSessionsGet200ResponseSessionsInner build() => _build();

  _$MeSessionsGet200ResponseSessionsInner _build() {
    final _$result = _$v ??
        _$MeSessionsGet200ResponseSessionsInner._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'MeSessionsGet200ResponseSessionsInner', 'id'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'MeSessionsGet200ResponseSessionsInner', 'createdAt'),
          expiresAt: BuiltValueNullFieldError.checkNotNull(
              expiresAt, r'MeSessionsGet200ResponseSessionsInner', 'expiresAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
