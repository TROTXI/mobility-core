// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'maintenance_result_failures_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MaintenanceResultFailuresInner extends MaintenanceResultFailuresInner {
  @override
  final String resourceId;
  @override
  final String reason;

  factory _$MaintenanceResultFailuresInner(
          [void Function(MaintenanceResultFailuresInnerBuilder)? updates]) =>
      (MaintenanceResultFailuresInnerBuilder()..update(updates))._build();

  _$MaintenanceResultFailuresInner._(
      {required this.resourceId, required this.reason})
      : super._();
  @override
  MaintenanceResultFailuresInner rebuild(
          void Function(MaintenanceResultFailuresInnerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MaintenanceResultFailuresInnerBuilder toBuilder() =>
      MaintenanceResultFailuresInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MaintenanceResultFailuresInner &&
        resourceId == other.resourceId &&
        reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, resourceId.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MaintenanceResultFailuresInner')
          ..add('resourceId', resourceId)
          ..add('reason', reason))
        .toString();
  }
}

class MaintenanceResultFailuresInnerBuilder
    implements
        Builder<MaintenanceResultFailuresInner,
            MaintenanceResultFailuresInnerBuilder> {
  _$MaintenanceResultFailuresInner? _$v;

  String? _resourceId;
  String? get resourceId => _$this._resourceId;
  set resourceId(String? resourceId) => _$this._resourceId = resourceId;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  MaintenanceResultFailuresInnerBuilder() {
    MaintenanceResultFailuresInner._defaults(this);
  }

  MaintenanceResultFailuresInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _resourceId = $v.resourceId;
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MaintenanceResultFailuresInner other) {
    _$v = other as _$MaintenanceResultFailuresInner;
  }

  @override
  void update(void Function(MaintenanceResultFailuresInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MaintenanceResultFailuresInner build() => _build();

  _$MaintenanceResultFailuresInner _build() {
    final _$result = _$v ??
        _$MaintenanceResultFailuresInner._(
          resourceId: BuiltValueNullFieldError.checkNotNull(
              resourceId, r'MaintenanceResultFailuresInner', 'resourceId'),
          reason: BuiltValueNullFieldError.checkNotNull(
              reason, r'MaintenanceResultFailuresInner', 'reason'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
