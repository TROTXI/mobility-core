// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restriction_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RestrictionInput extends RestrictionInput {
  @override
  final String reason;
  @override
  final DateTime reviewAt;

  factory _$RestrictionInput(
          [void Function(RestrictionInputBuilder)? updates]) =>
      (RestrictionInputBuilder()..update(updates))._build();

  _$RestrictionInput._({required this.reason, required this.reviewAt})
      : super._();
  @override
  RestrictionInput rebuild(void Function(RestrictionInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RestrictionInputBuilder toBuilder() =>
      RestrictionInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RestrictionInput &&
        reason == other.reason &&
        reviewAt == other.reviewAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jc(_$hash, reviewAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RestrictionInput')
          ..add('reason', reason)
          ..add('reviewAt', reviewAt))
        .toString();
  }
}

class RestrictionInputBuilder
    implements Builder<RestrictionInput, RestrictionInputBuilder> {
  _$RestrictionInput? _$v;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  DateTime? _reviewAt;
  DateTime? get reviewAt => _$this._reviewAt;
  set reviewAt(DateTime? reviewAt) => _$this._reviewAt = reviewAt;

  RestrictionInputBuilder() {
    RestrictionInput._defaults(this);
  }

  RestrictionInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _reason = $v.reason;
      _reviewAt = $v.reviewAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RestrictionInput other) {
    _$v = other as _$RestrictionInput;
  }

  @override
  void update(void Function(RestrictionInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RestrictionInput build() => _build();

  _$RestrictionInput _build() {
    final _$result = _$v ??
        _$RestrictionInput._(
          reason: BuiltValueNullFieldError.checkNotNull(
              reason, r'RestrictionInput', 'reason'),
          reviewAt: BuiltValueNullFieldError.checkNotNull(
              reviewAt, r'RestrictionInput', 'reviewAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
