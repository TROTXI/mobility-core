// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_driver_post200_response_driver.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AuthDriverPost200ResponseDriver
    extends AuthDriverPost200ResponseDriver {
  @override
  final String id;
  @override
  final String fullName;

  factory _$AuthDriverPost200ResponseDriver(
          [void Function(AuthDriverPost200ResponseDriverBuilder)? updates]) =>
      (AuthDriverPost200ResponseDriverBuilder()..update(updates))._build();

  _$AuthDriverPost200ResponseDriver._(
      {required this.id, required this.fullName})
      : super._();
  @override
  AuthDriverPost200ResponseDriver rebuild(
          void Function(AuthDriverPost200ResponseDriverBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AuthDriverPost200ResponseDriverBuilder toBuilder() =>
      AuthDriverPost200ResponseDriverBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthDriverPost200ResponseDriver &&
        id == other.id &&
        fullName == other.fullName;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, fullName.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AuthDriverPost200ResponseDriver')
          ..add('id', id)
          ..add('fullName', fullName))
        .toString();
  }
}

class AuthDriverPost200ResponseDriverBuilder
    implements
        Builder<AuthDriverPost200ResponseDriver,
            AuthDriverPost200ResponseDriverBuilder> {
  _$AuthDriverPost200ResponseDriver? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _fullName;
  String? get fullName => _$this._fullName;
  set fullName(String? fullName) => _$this._fullName = fullName;

  AuthDriverPost200ResponseDriverBuilder() {
    AuthDriverPost200ResponseDriver._defaults(this);
  }

  AuthDriverPost200ResponseDriverBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _fullName = $v.fullName;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AuthDriverPost200ResponseDriver other) {
    _$v = other as _$AuthDriverPost200ResponseDriver;
  }

  @override
  void update(void Function(AuthDriverPost200ResponseDriverBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuthDriverPost200ResponseDriver build() => _build();

  _$AuthDriverPost200ResponseDriver _build() {
    final _$result = _$v ??
        _$AuthDriverPost200ResponseDriver._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'AuthDriverPost200ResponseDriver', 'id'),
          fullName: BuiltValueNullFieldError.checkNotNull(
              fullName, r'AuthDriverPost200ResponseDriver', 'fullName'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
