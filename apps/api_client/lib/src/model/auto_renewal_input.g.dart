// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auto_renewal_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AutoRenewalInput extends AutoRenewalInput {
  @override
  final bool enabled;

  factory _$AutoRenewalInput(
          [void Function(AutoRenewalInputBuilder)? updates]) =>
      (AutoRenewalInputBuilder()..update(updates))._build();

  _$AutoRenewalInput._({required this.enabled}) : super._();
  @override
  AutoRenewalInput rebuild(void Function(AutoRenewalInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AutoRenewalInputBuilder toBuilder() =>
      AutoRenewalInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AutoRenewalInput && enabled == other.enabled;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, enabled.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AutoRenewalInput')
          ..add('enabled', enabled))
        .toString();
  }
}

class AutoRenewalInputBuilder
    implements Builder<AutoRenewalInput, AutoRenewalInputBuilder> {
  _$AutoRenewalInput? _$v;

  bool? _enabled;
  bool? get enabled => _$this._enabled;
  set enabled(bool? enabled) => _$this._enabled = enabled;

  AutoRenewalInputBuilder() {
    AutoRenewalInput._defaults(this);
  }

  AutoRenewalInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _enabled = $v.enabled;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AutoRenewalInput other) {
    _$v = other as _$AutoRenewalInput;
  }

  @override
  void update(void Function(AutoRenewalInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AutoRenewalInput build() => _build();

  _$AutoRenewalInput _build() {
    final _$result = _$v ??
        _$AutoRenewalInput._(
          enabled: BuiltValueNullFieldError.checkNotNull(
              enabled, r'AutoRenewalInput', 'enabled'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
