// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_quote_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PurchaseQuoteResponse extends PurchaseQuoteResponse {
  @override
  final PurchaseQuote data;

  factory _$PurchaseQuoteResponse(
          [void Function(PurchaseQuoteResponseBuilder)? updates]) =>
      (PurchaseQuoteResponseBuilder()..update(updates))._build();

  _$PurchaseQuoteResponse._({required this.data}) : super._();
  @override
  PurchaseQuoteResponse rebuild(
          void Function(PurchaseQuoteResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PurchaseQuoteResponseBuilder toBuilder() =>
      PurchaseQuoteResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PurchaseQuoteResponse && data == other.data;
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
    return (newBuiltValueToStringHelper(r'PurchaseQuoteResponse')
          ..add('data', data))
        .toString();
  }
}

class PurchaseQuoteResponseBuilder
    implements Builder<PurchaseQuoteResponse, PurchaseQuoteResponseBuilder> {
  _$PurchaseQuoteResponse? _$v;

  PurchaseQuoteBuilder? _data;
  PurchaseQuoteBuilder get data => _$this._data ??= PurchaseQuoteBuilder();
  set data(PurchaseQuoteBuilder? data) => _$this._data = data;

  PurchaseQuoteResponseBuilder() {
    PurchaseQuoteResponse._defaults(this);
  }

  PurchaseQuoteResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PurchaseQuoteResponse other) {
    _$v = other as _$PurchaseQuoteResponse;
  }

  @override
  void update(void Function(PurchaseQuoteResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PurchaseQuoteResponse build() => _build();

  _$PurchaseQuoteResponse _build() {
    _$PurchaseQuoteResponse _$result;
    try {
      _$result = _$v ??
          _$PurchaseQuoteResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PurchaseQuoteResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
