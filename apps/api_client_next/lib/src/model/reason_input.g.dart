// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reason_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ReasonInput extends ReasonInput {
  @override
  final String reason;

  factory _$ReasonInput([void Function(ReasonInputBuilder)? updates]) =>
      (ReasonInputBuilder()..update(updates))._build();

  _$ReasonInput._({required this.reason}) : super._();
  @override
  ReasonInput rebuild(void Function(ReasonInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReasonInputBuilder toBuilder() => ReasonInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReasonInput && reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ReasonInput')..add('reason', reason))
        .toString();
  }
}

class ReasonInputBuilder implements Builder<ReasonInput, ReasonInputBuilder> {
  _$ReasonInput? _$v;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  ReasonInputBuilder() {
    ReasonInput._defaults(this);
  }

  ReasonInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReasonInput other) {
    _$v = other as _$ReasonInput;
  }

  @override
  void update(void Function(ReasonInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReasonInput build() => _build();

  _$ReasonInput _build() {
    final _$result = _$v ??
        _$ReasonInput._(
          reason: BuiltValueNullFieldError.checkNotNull(
              reason, r'ReasonInput', 'reason'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
