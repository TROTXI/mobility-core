// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'arrival_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ArrivalInput extends ArrivalInput {
  @override
  final String stopOccurrenceId;
  @override
  final bool correction;

  factory _$ArrivalInput([void Function(ArrivalInputBuilder)? updates]) =>
      (ArrivalInputBuilder()..update(updates))._build();

  _$ArrivalInput._({required this.stopOccurrenceId, required this.correction})
      : super._();
  @override
  ArrivalInput rebuild(void Function(ArrivalInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ArrivalInputBuilder toBuilder() => ArrivalInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ArrivalInput &&
        stopOccurrenceId == other.stopOccurrenceId &&
        correction == other.correction;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, stopOccurrenceId.hashCode);
    _$hash = $jc(_$hash, correction.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ArrivalInput')
          ..add('stopOccurrenceId', stopOccurrenceId)
          ..add('correction', correction))
        .toString();
  }
}

class ArrivalInputBuilder
    implements Builder<ArrivalInput, ArrivalInputBuilder> {
  _$ArrivalInput? _$v;

  String? _stopOccurrenceId;
  String? get stopOccurrenceId => _$this._stopOccurrenceId;
  set stopOccurrenceId(String? stopOccurrenceId) =>
      _$this._stopOccurrenceId = stopOccurrenceId;

  bool? _correction;
  bool? get correction => _$this._correction;
  set correction(bool? correction) => _$this._correction = correction;

  ArrivalInputBuilder() {
    ArrivalInput._defaults(this);
  }

  ArrivalInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _stopOccurrenceId = $v.stopOccurrenceId;
      _correction = $v.correction;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ArrivalInput other) {
    _$v = other as _$ArrivalInput;
  }

  @override
  void update(void Function(ArrivalInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ArrivalInput build() => _build();

  _$ArrivalInput _build() {
    final _$result = _$v ??
        _$ArrivalInput._(
          stopOccurrenceId: BuiltValueNullFieldError.checkNotNull(
              stopOccurrenceId, r'ArrivalInput', 'stopOccurrenceId'),
          correction: BuiltValueNullFieldError.checkNotNull(
              correction, r'ArrivalInput', 'correction'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
