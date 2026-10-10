// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rider_erasure_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RiderErasureInput extends RiderErasureInput {
  @override
  final String reason;
  @override
  final String confirmAccountId;

  factory _$RiderErasureInput(
          [void Function(RiderErasureInputBuilder)? updates]) =>
      (RiderErasureInputBuilder()..update(updates))._build();

  _$RiderErasureInput._({required this.reason, required this.confirmAccountId})
      : super._();
  @override
  RiderErasureInput rebuild(void Function(RiderErasureInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RiderErasureInputBuilder toBuilder() =>
      RiderErasureInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RiderErasureInput &&
        reason == other.reason &&
        confirmAccountId == other.confirmAccountId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jc(_$hash, confirmAccountId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RiderErasureInput')
          ..add('reason', reason)
          ..add('confirmAccountId', confirmAccountId))
        .toString();
  }
}

class RiderErasureInputBuilder
    implements Builder<RiderErasureInput, RiderErasureInputBuilder> {
  _$RiderErasureInput? _$v;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  String? _confirmAccountId;
  String? get confirmAccountId => _$this._confirmAccountId;
  set confirmAccountId(String? confirmAccountId) =>
      _$this._confirmAccountId = confirmAccountId;

  RiderErasureInputBuilder() {
    RiderErasureInput._defaults(this);
  }

  RiderErasureInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _reason = $v.reason;
      _confirmAccountId = $v.confirmAccountId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RiderErasureInput other) {
    _$v = other as _$RiderErasureInput;
  }

  @override
  void update(void Function(RiderErasureInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RiderErasureInput build() => _build();

  _$RiderErasureInput _build() {
    final _$result = _$v ??
        _$RiderErasureInput._(
          reason: BuiltValueNullFieldError.checkNotNull(
              reason, r'RiderErasureInput', 'reason'),
          confirmAccountId: BuiltValueNullFieldError.checkNotNull(
              confirmAccountId, r'RiderErasureInput', 'confirmAccountId'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
