// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_pricing_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PlanPricingResponse extends PlanPricingResponse {
  @override
  final PlanPricing data;

  factory _$PlanPricingResponse(
          [void Function(PlanPricingResponseBuilder)? updates]) =>
      (PlanPricingResponseBuilder()..update(updates))._build();

  _$PlanPricingResponse._({required this.data}) : super._();
  @override
  PlanPricingResponse rebuild(
          void Function(PlanPricingResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PlanPricingResponseBuilder toBuilder() =>
      PlanPricingResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PlanPricingResponse && data == other.data;
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
    return (newBuiltValueToStringHelper(r'PlanPricingResponse')
          ..add('data', data))
        .toString();
  }
}

class PlanPricingResponseBuilder
    implements Builder<PlanPricingResponse, PlanPricingResponseBuilder> {
  _$PlanPricingResponse? _$v;

  PlanPricingBuilder? _data;
  PlanPricingBuilder get data => _$this._data ??= PlanPricingBuilder();
  set data(PlanPricingBuilder? data) => _$this._data = data;

  PlanPricingResponseBuilder() {
    PlanPricingResponse._defaults(this);
  }

  PlanPricingResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PlanPricingResponse other) {
    _$v = other as _$PlanPricingResponse;
  }

  @override
  void update(void Function(PlanPricingResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PlanPricingResponse build() => _build();

  _$PlanPricingResponse _build() {
    _$PlanPricingResponse _$result;
    try {
      _$result = _$v ??
          _$PlanPricingResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PlanPricingResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
