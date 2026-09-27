// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'passkey_registration_options_user.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PasskeyRegistrationOptionsUser extends PasskeyRegistrationOptionsUser {
  @override
  final String id;
  @override
  final String name;
  @override
  final String displayName;

  factory _$PasskeyRegistrationOptionsUser(
          [void Function(PasskeyRegistrationOptionsUserBuilder)? updates]) =>
      (PasskeyRegistrationOptionsUserBuilder()..update(updates))._build();

  _$PasskeyRegistrationOptionsUser._(
      {required this.id, required this.name, required this.displayName})
      : super._();
  @override
  PasskeyRegistrationOptionsUser rebuild(
          void Function(PasskeyRegistrationOptionsUserBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PasskeyRegistrationOptionsUserBuilder toBuilder() =>
      PasskeyRegistrationOptionsUserBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PasskeyRegistrationOptionsUser &&
        id == other.id &&
        name == other.name &&
        displayName == other.displayName;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PasskeyRegistrationOptionsUser')
          ..add('id', id)
          ..add('name', name)
          ..add('displayName', displayName))
        .toString();
  }
}

class PasskeyRegistrationOptionsUserBuilder
    implements
        Builder<PasskeyRegistrationOptionsUser,
            PasskeyRegistrationOptionsUserBuilder> {
  _$PasskeyRegistrationOptionsUser? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _displayName;
  String? get displayName => _$this._displayName;
  set displayName(String? displayName) => _$this._displayName = displayName;

  PasskeyRegistrationOptionsUserBuilder() {
    PasskeyRegistrationOptionsUser._defaults(this);
  }

  PasskeyRegistrationOptionsUserBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _displayName = $v.displayName;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PasskeyRegistrationOptionsUser other) {
    _$v = other as _$PasskeyRegistrationOptionsUser;
  }

  @override
  void update(void Function(PasskeyRegistrationOptionsUserBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PasskeyRegistrationOptionsUser build() => _build();

  _$PasskeyRegistrationOptionsUser _build() {
    final _$result = _$v ??
        _$PasskeyRegistrationOptionsUser._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'PasskeyRegistrationOptionsUser', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'PasskeyRegistrationOptionsUser', 'name'),
          displayName: BuiltValueNullFieldError.checkNotNull(
              displayName, r'PasskeyRegistrationOptionsUser', 'displayName'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
