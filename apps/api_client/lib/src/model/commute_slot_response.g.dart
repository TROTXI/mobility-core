// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commute_slot_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CommuteSlotResponse extends CommuteSlotResponse {
  @override
  final CommuteSlot data;

  factory _$CommuteSlotResponse(
          [void Function(CommuteSlotResponseBuilder)? updates]) =>
      (CommuteSlotResponseBuilder()..update(updates))._build();

  _$CommuteSlotResponse._({required this.data}) : super._();
  @override
  CommuteSlotResponse rebuild(
          void Function(CommuteSlotResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CommuteSlotResponseBuilder toBuilder() =>
      CommuteSlotResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CommuteSlotResponse && data == other.data;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CommuteSlotResponse')
          ..add('data', data))
        .toString();
  }
}

class CommuteSlotResponseBuilder
    implements Builder<CommuteSlotResponse, CommuteSlotResponseBuilder> {
  _$CommuteSlotResponse? _$v;

  CommuteSlotBuilder? _data;
  CommuteSlotBuilder get data => _$this._data ??= CommuteSlotBuilder();
  set data(CommuteSlotBuilder? data) => _$this._data = data;

  CommuteSlotResponseBuilder() {
    CommuteSlotResponse._defaults(this);
  }

  CommuteSlotResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CommuteSlotResponse other) {
    _$v = other as _$CommuteSlotResponse;
  }

  @override
  void update(void Function(CommuteSlotResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CommuteSlotResponse build() => _build();

  _$CommuteSlotResponse _build() {
    _$CommuteSlotResponse _$result;
    try {
      _$result = _$v ??
          _$CommuteSlotResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'CommuteSlotResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
