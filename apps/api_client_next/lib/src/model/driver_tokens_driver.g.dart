// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_tokens_driver.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DriverTokensDriver extends DriverTokensDriver {
  @override
  final String id;
  @override
  final String name;

  factory _$DriverTokensDriver(
          [void Function(DriverTokensDriverBuilder)? updates]) =>
      (DriverTokensDriverBuilder()..update(updates))._build();

  _$DriverTokensDriver._({required this.id, required this.name}) : super._();
  @override
  DriverTokensDriver rebuild(
          void Function(DriverTokensDriverBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DriverTokensDriverBuilder toBuilder() =>
      DriverTokensDriverBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DriverTokensDriver && id == other.id && name == other.name;
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
    return (newBuiltValueToStringHelper(r'DriverTokensDriver')
          ..add('id', id)
          ..add('name', name))
        .toString();
  }
}

class DriverTokensDriverBuilder
    implements Builder<DriverTokensDriver, DriverTokensDriverBuilder> {
  _$DriverTokensDriver? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  DriverTokensDriverBuilder() {
    DriverTokensDriver._defaults(this);
  }

  DriverTokensDriverBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DriverTokensDriver other) {
    _$v = other as _$DriverTokensDriver;
  }

  @override
  void update(void Function(DriverTokensDriverBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DriverTokensDriver build() => _build();

  _$DriverTokensDriver _build() {
    final _$result = _$v ??
        _$DriverTokensDriver._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'DriverTokensDriver', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'DriverTokensDriver', 'name'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
