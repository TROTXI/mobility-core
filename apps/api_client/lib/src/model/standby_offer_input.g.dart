// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'standby_offer_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$StandbyOfferInput extends StandbyOfferInput {
  @override
  final DateTime expiresAt;

  factory _$StandbyOfferInput(
          [void Function(StandbyOfferInputBuilder)? updates]) =>
      (StandbyOfferInputBuilder()..update(updates))._build();

  _$StandbyOfferInput._({required this.expiresAt}) : super._();
  @override
  StandbyOfferInput rebuild(void Function(StandbyOfferInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  StandbyOfferInputBuilder toBuilder() =>
      StandbyOfferInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is StandbyOfferInput && expiresAt == other.expiresAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, expiresAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'StandbyOfferInput')
          ..add('expiresAt', expiresAt))
        .toString();
  }
}

class StandbyOfferInputBuilder
    implements Builder<StandbyOfferInput, StandbyOfferInputBuilder> {
  _$StandbyOfferInput? _$v;

  DateTime? _expiresAt;
  DateTime? get expiresAt => _$this._expiresAt;
  set expiresAt(DateTime? expiresAt) => _$this._expiresAt = expiresAt;

  StandbyOfferInputBuilder() {
    StandbyOfferInput._defaults(this);
  }

  StandbyOfferInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _expiresAt = $v.expiresAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(StandbyOfferInput other) {
    _$v = other as _$StandbyOfferInput;
  }

  @override
  void update(void Function(StandbyOfferInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  StandbyOfferInput build() => _build();

  _$StandbyOfferInput _build() {
    final _$result = _$v ??
        _$StandbyOfferInput._(
          expiresAt: BuiltValueNullFieldError.checkNotNull(
              expiresAt, r'StandbyOfferInput', 'expiresAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
