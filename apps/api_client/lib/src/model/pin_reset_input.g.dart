// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pin_reset_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PinResetInput extends PinResetInput {
  @override
  final String reason;
  @override
  final bool? emailInstructions;

  factory _$PinResetInput([void Function(PinResetInputBuilder)? updates]) =>
      (PinResetInputBuilder()..update(updates))._build();

  _$PinResetInput._({required this.reason, this.emailInstructions}) : super._();
  @override
  PinResetInput rebuild(void Function(PinResetInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PinResetInputBuilder toBuilder() => PinResetInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PinResetInput &&
        reason == other.reason &&
        emailInstructions == other.emailInstructions;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jc(_$hash, emailInstructions.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PinResetInput')
          ..add('reason', reason)
          ..add('emailInstructions', emailInstructions))
        .toString();
  }
}

class PinResetInputBuilder
    implements Builder<PinResetInput, PinResetInputBuilder> {
  _$PinResetInput? _$v;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  bool? _emailInstructions;
  bool? get emailInstructions => _$this._emailInstructions;
  set emailInstructions(bool? emailInstructions) =>
      _$this._emailInstructions = emailInstructions;

  PinResetInputBuilder() {
    PinResetInput._defaults(this);
  }

  PinResetInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _reason = $v.reason;
      _emailInstructions = $v.emailInstructions;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PinResetInput other) {
    _$v = other as _$PinResetInput;
  }

  @override
  void update(void Function(PinResetInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PinResetInput build() => _build();

  _$PinResetInput _build() {
    final _$result = _$v ??
        _$PinResetInput._(
          reason: BuiltValueNullFieldError.checkNotNull(
              reason, r'PinResetInput', 'reason'),
          emailInstructions: emailInstructions,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
