// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'maintenance_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MaintenanceResult extends MaintenanceResult {
  @override
  final int considered;
  @override
  final int succeeded;
  @override
  final int blocked;
  @override
  final int failed;
  @override
  final BuiltList<MaintenanceResultFailuresInner> failures;

  factory _$MaintenanceResult(
          [void Function(MaintenanceResultBuilder)? updates]) =>
      (MaintenanceResultBuilder()..update(updates))._build();

  _$MaintenanceResult._(
      {required this.considered,
      required this.succeeded,
      required this.blocked,
      required this.failed,
      required this.failures})
      : super._();
  @override
  MaintenanceResult rebuild(void Function(MaintenanceResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MaintenanceResultBuilder toBuilder() =>
      MaintenanceResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MaintenanceResult &&
        considered == other.considered &&
        succeeded == other.succeeded &&
        blocked == other.blocked &&
        failed == other.failed &&
        failures == other.failures;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, considered.hashCode);
    _$hash = $jc(_$hash, succeeded.hashCode);
    _$hash = $jc(_$hash, blocked.hashCode);
    _$hash = $jc(_$hash, failed.hashCode);
    _$hash = $jc(_$hash, failures.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MaintenanceResult')
          ..add('considered', considered)
          ..add('succeeded', succeeded)
          ..add('blocked', blocked)
          ..add('failed', failed)
          ..add('failures', failures))
        .toString();
  }
}

class MaintenanceResultBuilder
    implements Builder<MaintenanceResult, MaintenanceResultBuilder> {
  _$MaintenanceResult? _$v;

  int? _considered;
  int? get considered => _$this._considered;
  set considered(int? considered) => _$this._considered = considered;

  int? _succeeded;
  int? get succeeded => _$this._succeeded;
  set succeeded(int? succeeded) => _$this._succeeded = succeeded;

  int? _blocked;
  int? get blocked => _$this._blocked;
  set blocked(int? blocked) => _$this._blocked = blocked;

  int? _failed;
  int? get failed => _$this._failed;
  set failed(int? failed) => _$this._failed = failed;

  ListBuilder<MaintenanceResultFailuresInner>? _failures;
  ListBuilder<MaintenanceResultFailuresInner> get failures =>
      _$this._failures ??= ListBuilder<MaintenanceResultFailuresInner>();
  set failures(ListBuilder<MaintenanceResultFailuresInner>? failures) =>
      _$this._failures = failures;

  MaintenanceResultBuilder() {
    MaintenanceResult._defaults(this);
  }

  MaintenanceResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _considered = $v.considered;
      _succeeded = $v.succeeded;
      _blocked = $v.blocked;
      _failed = $v.failed;
      _failures = $v.failures.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MaintenanceResult other) {
    _$v = other as _$MaintenanceResult;
  }

  @override
  void update(void Function(MaintenanceResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MaintenanceResult build() => _build();

  _$MaintenanceResult _build() {
    _$MaintenanceResult _$result;
    try {
      _$result = _$v ??
          _$MaintenanceResult._(
            considered: BuiltValueNullFieldError.checkNotNull(
                considered, r'MaintenanceResult', 'considered'),
            succeeded: BuiltValueNullFieldError.checkNotNull(
                succeeded, r'MaintenanceResult', 'succeeded'),
            blocked: BuiltValueNullFieldError.checkNotNull(
                blocked, r'MaintenanceResult', 'blocked'),
            failed: BuiltValueNullFieldError.checkNotNull(
                failed, r'MaintenanceResult', 'failed'),
            failures: failures.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'failures';
        failures.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'MaintenanceResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
