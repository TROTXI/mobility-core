// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payments_topup_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PaymentsTopupPostRequest extends PaymentsTopupPostRequest {
  @override
  final int amountPesewas;

  factory _$PaymentsTopupPostRequest(
          [void Function(PaymentsTopupPostRequestBuilder)? updates]) =>
      (PaymentsTopupPostRequestBuilder()..update(updates))._build();

  _$PaymentsTopupPostRequest._({required this.amountPesewas}) : super._();
  @override
  PaymentsTopupPostRequest rebuild(
          void Function(PaymentsTopupPostRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PaymentsTopupPostRequestBuilder toBuilder() =>
      PaymentsTopupPostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PaymentsTopupPostRequest &&
        amountPesewas == other.amountPesewas;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, amountPesewas.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PaymentsTopupPostRequest')
          ..add('amountPesewas', amountPesewas))
        .toString();
  }
}

class PaymentsTopupPostRequestBuilder
    implements
        Builder<PaymentsTopupPostRequest, PaymentsTopupPostRequestBuilder> {
  _$PaymentsTopupPostRequest? _$v;

  int? _amountPesewas;
  int? get amountPesewas => _$this._amountPesewas;
  set amountPesewas(int? amountPesewas) =>
      _$this._amountPesewas = amountPesewas;

  PaymentsTopupPostRequestBuilder() {
    PaymentsTopupPostRequest._defaults(this);
  }

  PaymentsTopupPostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _amountPesewas = $v.amountPesewas;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PaymentsTopupPostRequest other) {
    _$v = other as _$PaymentsTopupPostRequest;
  }

  @override
  void update(void Function(PaymentsTopupPostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PaymentsTopupPostRequest build() => _build();

  _$PaymentsTopupPostRequest _build() {
    final _$result = _$v ??
        _$PaymentsTopupPostRequest._(
          amountPesewas: BuiltValueNullFieldError.checkNotNull(
              amountPesewas, r'PaymentsTopupPostRequest', 'amountPesewas'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
