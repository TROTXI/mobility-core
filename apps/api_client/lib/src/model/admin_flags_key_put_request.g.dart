// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_flags_key_put_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminFlagsKeyPutRequest extends AdminFlagsKeyPutRequest {
  @override
  final bool? enabled;
  @override
  final int? rolloutPercentage;
  @override
  final String? description;

  factory _$AdminFlagsKeyPutRequest(
          [void Function(AdminFlagsKeyPutRequestBuilder)? updates]) =>
      (AdminFlagsKeyPutRequestBuilder()..update(updates))._build();

  _$AdminFlagsKeyPutRequest._(
      {this.enabled, this.rolloutPercentage, this.description})
      : super._();
  @override
  AdminFlagsKeyPutRequest rebuild(
          void Function(AdminFlagsKeyPutRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminFlagsKeyPutRequestBuilder toBuilder() =>
      AdminFlagsKeyPutRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminFlagsKeyPutRequest &&
        enabled == other.enabled &&
        rolloutPercentage == other.rolloutPercentage &&
        description == other.description;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, enabled.hashCode);
    _$hash = $jc(_$hash, rolloutPercentage.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminFlagsKeyPutRequest')
          ..add('enabled', enabled)
          ..add('rolloutPercentage', rolloutPercentage)
          ..add('description', description))
        .toString();
  }
}

class AdminFlagsKeyPutRequestBuilder
    implements
        Builder<AdminFlagsKeyPutRequest, AdminFlagsKeyPutRequestBuilder> {
  _$AdminFlagsKeyPutRequest? _$v;

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

  AdminFlagsKeyPutRequestBuilder() {
    AdminFlagsKeyPutRequest._defaults(this);
  }

  AdminFlagsKeyPutRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _enabled = $v.enabled;
      _rolloutPercentage = $v.rolloutPercentage;
      _description = $v.description;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminFlagsKeyPutRequest other) {
    _$v = other as _$AdminFlagsKeyPutRequest;
  }

  @override
  void update(void Function(AdminFlagsKeyPutRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminFlagsKeyPutRequest build() => _build();

  _$AdminFlagsKeyPutRequest _build() {
    final _$result = _$v ??
        _$AdminFlagsKeyPutRequest._(
          enabled: enabled,
          rolloutPercentage: rolloutPercentage,
          description: description,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
