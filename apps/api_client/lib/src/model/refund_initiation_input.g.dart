// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'refund_initiation_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RefundInitiationInput extends RefundInitiationInput {
  @override
  final Money amount;
  @override
  final String reason;

  factory _$RefundInitiationInput(
          [void Function(RefundInitiationInputBuilder)? updates]) =>
      (RefundInitiationInputBuilder()..update(updates))._build();

  _$RefundInitiationInput._({required this.amount, required this.reason})
      : super._();
  @override
  RefundInitiationInput rebuild(
          void Function(RefundInitiationInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RefundInitiationInputBuilder toBuilder() =>
      RefundInitiationInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RefundInitiationInput &&
        amount == other.amount &&
        reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, amount.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RefundInitiationInput')
          ..add('amount', amount)
          ..add('reason', reason))
        .toString();
  }
}

class RefundInitiationInputBuilder
    implements Builder<RefundInitiationInput, RefundInitiationInputBuilder> {
  _$RefundInitiationInput? _$v;

  MoneyBuilder? _amount;
  MoneyBuilder get amount => _$this._amount ??= MoneyBuilder();
  set amount(MoneyBuilder? amount) => _$this._amount = amount;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  RefundInitiationInputBuilder() {
    RefundInitiationInput._defaults(this);
  }

  RefundInitiationInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _amount = $v.amount.toBuilder();
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RefundInitiationInput other) {
    _$v = other as _$RefundInitiationInput;
  }

  @override
  void update(void Function(RefundInitiationInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RefundInitiationInput build() => _build();

  _$RefundInitiationInput _build() {
    _$RefundInitiationInput _$result;
    try {
      _$result = _$v ??
          _$RefundInitiationInput._(
            amount: amount.build(),
            reason: BuiltValueNullFieldError.checkNotNull(
                reason, r'RefundInitiationInput', 'reason'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'amount';
        amount.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'RefundInitiationInput', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
