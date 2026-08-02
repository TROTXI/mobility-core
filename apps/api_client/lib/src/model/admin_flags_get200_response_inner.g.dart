// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_flags_get200_response_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminFlagsGet200ResponseInner extends AdminFlagsGet200ResponseInner {
  @override
  final String key;
  @override
  final bool enabled;
  @override
  final int rolloutPercentage;
  @override
  final String? description;
  @override
  final DateTime updatedAt;

  factory _$AdminFlagsGet200ResponseInner(
          [void Function(AdminFlagsGet200ResponseInnerBuilder)? updates]) =>
      (AdminFlagsGet200ResponseInnerBuilder()..update(updates))._build();

  _$AdminFlagsGet200ResponseInner._(
      {required this.key,
      required this.enabled,
      required this.rolloutPercentage,
      this.description,
      required this.updatedAt})
      : super._();
  @override
  AdminFlagsGet200ResponseInner rebuild(
          void Function(AdminFlagsGet200ResponseInnerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminFlagsGet200ResponseInnerBuilder toBuilder() =>
      AdminFlagsGet200ResponseInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminFlagsGet200ResponseInner &&
        key == other.key &&
        enabled == other.enabled &&
        rolloutPercentage == other.rolloutPercentage &&
        description == other.description &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, key.hashCode);
    _$hash = $jc(_$hash, enabled.hashCode);
    _$hash = $jc(_$hash, rolloutPercentage.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminFlagsGet200ResponseInner')
          ..add('key', key)
          ..add('enabled', enabled)
          ..add('rolloutPercentage', rolloutPercentage)
          ..add('description', description)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class AdminFlagsGet200ResponseInnerBuilder
    implements
        Builder<AdminFlagsGet200ResponseInner,
            AdminFlagsGet200ResponseInnerBuilder> {
  _$AdminFlagsGet200ResponseInner? _$v;

  String? _key;
  String? get key => _$this._key;
  set key(String? key) => _$this._key = key;

  bool? _enabled;
  bool? get enabled => _$this._enabled;
  set enabled(bool? enabled) => _$this._enabled = enabled;

  int? _rolloutPercentage;
  int? get rolloutPercentage => _$this._rolloutPercentage;
  set rolloutPercentage(int? rolloutPercentage) =>
      _$this._rolloutPercentage = rolloutPercentage;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  AdminFlagsGet200ResponseInnerBuilder() {
    AdminFlagsGet200ResponseInner._defaults(this);
  }

  AdminFlagsGet200ResponseInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _key = $v.key;
      _enabled = $v.enabled;
      _rolloutPercentage = $v.rolloutPercentage;
      _description = $v.description;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminFlagsGet200ResponseInner other) {
    _$v = other as _$AdminFlagsGet200ResponseInner;
  }

  @override
  void update(void Function(AdminFlagsGet200ResponseInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminFlagsGet200ResponseInner build() => _build();

  _$AdminFlagsGet200ResponseInner _build() {
    final _$result = _$v ??
        _$AdminFlagsGet200ResponseInner._(
          key: BuiltValueNullFieldError.checkNotNull(
              key, r'AdminFlagsGet200ResponseInner', 'key'),
          enabled: BuiltValueNullFieldError.checkNotNull(
              enabled, r'AdminFlagsGet200ResponseInner', 'enabled'),
          rolloutPercentage: BuiltValueNullFieldError.checkNotNull(
              rolloutPercentage,
              r'AdminFlagsGet200ResponseInner',
              'rolloutPercentage'),
          description: description,
          updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt, r'AdminFlagsGet200ResponseInner', 'updatedAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
