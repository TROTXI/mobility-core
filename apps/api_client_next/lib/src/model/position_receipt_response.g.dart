// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'position_receipt_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PositionReceiptResponse extends PositionReceiptResponse {
  @override
  final PositionReceipt data;

  factory _$PositionReceiptResponse(
          [void Function(PositionReceiptResponseBuilder)? updates]) =>
      (PositionReceiptResponseBuilder()..update(updates))._build();

  _$PositionReceiptResponse._({required this.data}) : super._();
  @override
  PositionReceiptResponse rebuild(
          void Function(PositionReceiptResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PositionReceiptResponseBuilder toBuilder() =>
      PositionReceiptResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PositionReceiptResponse && data == other.data;
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
    return (newBuiltValueToStringHelper(r'PositionReceiptResponse')
          ..add('data', data))
        .toString();
  }
}

class PositionReceiptResponseBuilder
    implements
        Builder<PositionReceiptResponse, PositionReceiptResponseBuilder> {
  _$PositionReceiptResponse? _$v;

  PositionReceiptBuilder? _data;
  PositionReceiptBuilder get data => _$this._data ??= PositionReceiptBuilder();
  set data(PositionReceiptBuilder? data) => _$this._data = data;

  PositionReceiptResponseBuilder() {
    PositionReceiptResponse._defaults(this);
  }

  PositionReceiptResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PositionReceiptResponse other) {
    _$v = other as _$PositionReceiptResponse;
  }

  @override
  void update(void Function(PositionReceiptResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PositionReceiptResponse build() => _build();

  _$PositionReceiptResponse _build() {
    _$PositionReceiptResponse _$result;
    try {
      _$result = _$v ??
          _$PositionReceiptResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PositionReceiptResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
