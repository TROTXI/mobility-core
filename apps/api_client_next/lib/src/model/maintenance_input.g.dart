// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'maintenance_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MaintenanceInput extends MaintenanceInput {
  @override
  final int limit;

  factory _$MaintenanceInput(
          [void Function(MaintenanceInputBuilder)? updates]) =>
      (MaintenanceInputBuilder()..update(updates))._build();

  _$MaintenanceInput._({required this.limit}) : super._();
  @override
  MaintenanceInput rebuild(void Function(MaintenanceInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MaintenanceInputBuilder toBuilder() =>
      MaintenanceInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MaintenanceInput && limit == other.limit;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, limit.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MaintenanceInput')
          ..add('limit', limit))
        .toString();
  }
}

class MaintenanceInputBuilder
    implements Builder<MaintenanceInput, MaintenanceInputBuilder> {
  _$MaintenanceInput? _$v;

  int? _limit;
  int? get limit => _$this._limit;
  set limit(int? limit) => _$this._limit = limit;

  MaintenanceInputBuilder() {
    MaintenanceInput._defaults(this);
  }

  MaintenanceInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _limit = $v.limit;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MaintenanceInput other) {
    _$v = other as _$MaintenanceInput;
  }

  @override
  void update(void Function(MaintenanceInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MaintenanceInput build() => _build();

  _$MaintenanceInput _build() {
    final _$result = _$v ??
        _$MaintenanceInput._(
          limit: BuiltValueNullFieldError.checkNotNull(
              limit, r'MaintenanceInput', 'limit'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
