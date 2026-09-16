// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_review_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PaymentReviewResponse extends PaymentReviewResponse {
  @override
  final PaymentReview data;

  factory _$PaymentReviewResponse(
          [void Function(PaymentReviewResponseBuilder)? updates]) =>
      (PaymentReviewResponseBuilder()..update(updates))._build();

  _$PaymentReviewResponse._({required this.data}) : super._();
  @override
  PaymentReviewResponse rebuild(
          void Function(PaymentReviewResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PaymentReviewResponseBuilder toBuilder() =>
      PaymentReviewResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PaymentReviewResponse && data == other.data;
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
    return (newBuiltValueToStringHelper(r'PaymentReviewResponse')
          ..add('data', data))
        .toString();
  }
}

class PaymentReviewResponseBuilder
    implements Builder<PaymentReviewResponse, PaymentReviewResponseBuilder> {
  _$PaymentReviewResponse? _$v;

  PaymentReviewBuilder? _data;
  PaymentReviewBuilder get data => _$this._data ??= PaymentReviewBuilder();
  set data(PaymentReviewBuilder? data) => _$this._data = data;

  PaymentReviewResponseBuilder() {
    PaymentReviewResponse._defaults(this);
  }

  PaymentReviewResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PaymentReviewResponse other) {
    _$v = other as _$PaymentReviewResponse;
  }

  @override
  void update(void Function(PaymentReviewResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PaymentReviewResponse build() => _build();

  _$PaymentReviewResponse _build() {
    _$PaymentReviewResponse _$result;
    try {
      _$result = _$v ??
          _$PaymentReviewResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PaymentReviewResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
