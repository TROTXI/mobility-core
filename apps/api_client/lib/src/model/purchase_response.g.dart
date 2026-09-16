// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PurchaseResponse extends PurchaseResponse {
  @override
  final Purchase data;

  factory _$PurchaseResponse(
          [void Function(PurchaseResponseBuilder)? updates]) =>
      (PurchaseResponseBuilder()..update(updates))._build();

  _$PurchaseResponse._({required this.data}) : super._();
  @override
  PurchaseResponse rebuild(void Function(PurchaseResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PurchaseResponseBuilder toBuilder() =>
      PurchaseResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PurchaseResponse && data == other.data;
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
    return (newBuiltValueToStringHelper(r'PurchaseResponse')..add('data', data))
        .toString();
  }
}

class PurchaseResponseBuilder
    implements Builder<PurchaseResponse, PurchaseResponseBuilder> {
  _$PurchaseResponse? _$v;

  PurchaseBuilder? _data;
  PurchaseBuilder get data => _$this._data ??= PurchaseBuilder();
  set data(PurchaseBuilder? data) => _$this._data = data;

  PurchaseResponseBuilder() {
    PurchaseResponse._defaults(this);
  }

  PurchaseResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PurchaseResponse other) {
    _$v = other as _$PurchaseResponse;
  }

  @override
  void update(void Function(PurchaseResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PurchaseResponse build() => _build();

  _$PurchaseResponse _build() {
    _$PurchaseResponse _$result;
    try {
      _$result = _$v ??
          _$PurchaseResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PurchaseResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
