// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'publish_version_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PublishVersionInput extends PublishVersionInput {
  @override
  final String reason;
  @override
  final DateTime effectiveFrom;

  factory _$PublishVersionInput(
          [void Function(PublishVersionInputBuilder)? updates]) =>
      (PublishVersionInputBuilder()..update(updates))._build();

  _$PublishVersionInput._({required this.reason, required this.effectiveFrom})
      : super._();
  @override
  PublishVersionInput rebuild(
          void Function(PublishVersionInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PublishVersionInputBuilder toBuilder() =>
      PublishVersionInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PublishVersionInput &&
        reason == other.reason &&
        effectiveFrom == other.effectiveFrom;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jc(_$hash, effectiveFrom.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PublishVersionInput')
          ..add('reason', reason)
          ..add('effectiveFrom', effectiveFrom))
        .toString();
  }
}

class PublishVersionInputBuilder
    implements Builder<PublishVersionInput, PublishVersionInputBuilder> {
  _$PublishVersionInput? _$v;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  DateTime? _effectiveFrom;
  DateTime? get effectiveFrom => _$this._effectiveFrom;
  set effectiveFrom(DateTime? effectiveFrom) =>
      _$this._effectiveFrom = effectiveFrom;

  PublishVersionInputBuilder() {
    PublishVersionInput._defaults(this);
  }

  PublishVersionInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _reason = $v.reason;
      _effectiveFrom = $v.effectiveFrom;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PublishVersionInput other) {
    _$v = other as _$PublishVersionInput;
  }

  @override
  void update(void Function(PublishVersionInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PublishVersionInput build() => _build();

  _$PublishVersionInput _build() {
    final _$result = _$v ??
        _$PublishVersionInput._(
          reason: BuiltValueNullFieldError.checkNotNull(
              reason, r'PublishVersionInput', 'reason'),
          effectiveFrom: BuiltValueNullFieldError.checkNotNull(
              effectiveFrom, r'PublishVersionInput', 'effectiveFrom'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
