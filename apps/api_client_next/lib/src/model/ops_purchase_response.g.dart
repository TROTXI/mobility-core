// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ops_purchase_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OpsPurchaseResponse extends OpsPurchaseResponse {
  @override
  final OpsPurchase data;

  factory _$OpsPurchaseResponse(
          [void Function(OpsPurchaseResponseBuilder)? updates]) =>
      (OpsPurchaseResponseBuilder()..update(updates))._build();

  _$OpsPurchaseResponse._({required this.data}) : super._();
  @override
  OpsPurchaseResponse rebuild(
          void Function(OpsPurchaseResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OpsPurchaseResponseBuilder toBuilder() =>
      OpsPurchaseResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OpsPurchaseResponse && data == other.data;
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
    return (newBuiltValueToStringHelper(r'OpsPurchaseResponse')
          ..add('data', data))
        .toString();
  }
}

class OpsPurchaseResponseBuilder
    implements Builder<OpsPurchaseResponse, OpsPurchaseResponseBuilder> {
  _$OpsPurchaseResponse? _$v;

  OpsPurchaseBuilder? _data;
  OpsPurchaseBuilder get data => _$this._data ??= OpsPurchaseBuilder();
  set data(OpsPurchaseBuilder? data) => _$this._data = data;

  OpsPurchaseResponseBuilder() {
    OpsPurchaseResponse._defaults(this);
  }

  OpsPurchaseResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OpsPurchaseResponse other) {
    _$v = other as _$OpsPurchaseResponse;
  }

  @override
  void update(void Function(OpsPurchaseResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OpsPurchaseResponse build() => _build();

  _$OpsPurchaseResponse _build() {
    _$OpsPurchaseResponse _$result;
    try {
      _$result = _$v ??
          _$OpsPurchaseResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'OpsPurchaseResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
