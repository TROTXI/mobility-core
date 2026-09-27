// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'passkey_registration_options_rp.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PasskeyRegistrationOptionsRp extends PasskeyRegistrationOptionsRp {
  @override
  final String id;
  @override
  final String name;

  factory _$PasskeyRegistrationOptionsRp(
          [void Function(PasskeyRegistrationOptionsRpBuilder)? updates]) =>
      (PasskeyRegistrationOptionsRpBuilder()..update(updates))._build();

  _$PasskeyRegistrationOptionsRp._({required this.id, required this.name})
      : super._();
  @override
  PasskeyRegistrationOptionsRp rebuild(
          void Function(PasskeyRegistrationOptionsRpBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PasskeyRegistrationOptionsRpBuilder toBuilder() =>
      PasskeyRegistrationOptionsRpBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PasskeyRegistrationOptionsRp &&
        id == other.id &&
        name == other.name;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PasskeyRegistrationOptionsRp')
          ..add('id', id)
          ..add('name', name))
        .toString();
  }
}

class PasskeyRegistrationOptionsRpBuilder
    implements
        Builder<PasskeyRegistrationOptionsRp,
            PasskeyRegistrationOptionsRpBuilder> {
  _$PasskeyRegistrationOptionsRp? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  PasskeyRegistrationOptionsRpBuilder() {
    PasskeyRegistrationOptionsRp._defaults(this);
  }

  PasskeyRegistrationOptionsRpBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PasskeyRegistrationOptionsRp other) {
    _$v = other as _$PasskeyRegistrationOptionsRp;
  }

  @override
  void update(void Function(PasskeyRegistrationOptionsRpBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PasskeyRegistrationOptionsRp build() => _build();

  _$PasskeyRegistrationOptionsRp _build() {
    final _$result = _$v ??
        _$PasskeyRegistrationOptionsRp._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'PasskeyRegistrationOptionsRp', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'PasskeyRegistrationOptionsRp', 'name'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
