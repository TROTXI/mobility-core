// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ops_operator.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OpsOperator extends OpsOperator {
  @override
  final String id;
  @override
  final String displayName;
  @override
  final String? email;
  @override
  final int passkeyCount;
  @override
  final int activeSessions;
  @override
  final DateTime? lastPasskeyUsedAt;
  @override
  final DateTime joinedAt;
  @override
  final String editToken;

  factory _$OpsOperator([void Function(OpsOperatorBuilder)? updates]) =>
      (OpsOperatorBuilder()..update(updates))._build();

  _$OpsOperator._(
      {required this.id,
      required this.displayName,
      this.email,
      required this.passkeyCount,
      required this.activeSessions,
      this.lastPasskeyUsedAt,
      required this.joinedAt,
      required this.editToken})
      : super._();
  @override
  OpsOperator rebuild(void Function(OpsOperatorBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OpsOperatorBuilder toBuilder() => OpsOperatorBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OpsOperator &&
        id == other.id &&
        displayName == other.displayName &&
        email == other.email &&
        passkeyCount == other.passkeyCount &&
        activeSessions == other.activeSessions &&
        lastPasskeyUsedAt == other.lastPasskeyUsedAt &&
        joinedAt == other.joinedAt &&
        editToken == other.editToken;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, passkeyCount.hashCode);
    _$hash = $jc(_$hash, activeSessions.hashCode);
    _$hash = $jc(_$hash, lastPasskeyUsedAt.hashCode);
    _$hash = $jc(_$hash, joinedAt.hashCode);
    _$hash = $jc(_$hash, editToken.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OpsOperator')
          ..add('id', id)
          ..add('displayName', displayName)
          ..add('email', email)
          ..add('passkeyCount', passkeyCount)
          ..add('activeSessions', activeSessions)
          ..add('lastPasskeyUsedAt', lastPasskeyUsedAt)
          ..add('joinedAt', joinedAt)
          ..add('editToken', editToken))
        .toString();
  }
}

class OpsOperatorBuilder implements Builder<OpsOperator, OpsOperatorBuilder> {
  _$OpsOperator? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _displayName;
  String? get displayName => _$this._displayName;
  set displayName(String? displayName) => _$this._displayName = displayName;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  int? _passkeyCount;
  int? get passkeyCount => _$this._passkeyCount;
  set passkeyCount(int? passkeyCount) => _$this._passkeyCount = passkeyCount;

  int? _activeSessions;
  int? get activeSessions => _$this._activeSessions;
  set activeSessions(int? activeSessions) =>
      _$this._activeSessions = activeSessions;

  DateTime? _lastPasskeyUsedAt;
  DateTime? get lastPasskeyUsedAt => _$this._lastPasskeyUsedAt;
  set lastPasskeyUsedAt(DateTime? lastPasskeyUsedAt) =>
      _$this._lastPasskeyUsedAt = lastPasskeyUsedAt;

  DateTime? _joinedAt;
  DateTime? get joinedAt => _$this._joinedAt;
  set joinedAt(DateTime? joinedAt) => _$this._joinedAt = joinedAt;

  String? _editToken;
  String? get editToken => _$this._editToken;
  set editToken(String? editToken) => _$this._editToken = editToken;

  OpsOperatorBuilder() {
    OpsOperator._defaults(this);
  }

  OpsOperatorBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _displayName = $v.displayName;
      _email = $v.email;
      _passkeyCount = $v.passkeyCount;
      _activeSessions = $v.activeSessions;
      _lastPasskeyUsedAt = $v.lastPasskeyUsedAt;
      _joinedAt = $v.joinedAt;
      _editToken = $v.editToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OpsOperator other) {
    _$v = other as _$OpsOperator;
  }

  @override
  void update(void Function(OpsOperatorBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OpsOperator build() => _build();

  _$OpsOperator _build() {
    final _$result = _$v ??
        _$OpsOperator._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'OpsOperator', 'id'),
          displayName: BuiltValueNullFieldError.checkNotNull(
              displayName, r'OpsOperator', 'displayName'),
          email: email,
          passkeyCount: BuiltValueNullFieldError.checkNotNull(
              passkeyCount, r'OpsOperator', 'passkeyCount'),
          activeSessions: BuiltValueNullFieldError.checkNotNull(
              activeSessions, r'OpsOperator', 'activeSessions'),
          lastPasskeyUsedAt: lastPasskeyUsedAt,
          joinedAt: BuiltValueNullFieldError.checkNotNull(
              joinedAt, r'OpsOperator', 'joinedAt'),
          editToken: BuiltValueNullFieldError.checkNotNull(
              editToken, r'OpsOperator', 'editToken'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
