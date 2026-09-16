// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_maintenance_result_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PaymentMaintenanceResultResponse
    extends PaymentMaintenanceResultResponse {
  @override
  final PaymentMaintenanceResult data;

  factory _$PaymentMaintenanceResultResponse(
          [void Function(PaymentMaintenanceResultResponseBuilder)? updates]) =>
      (PaymentMaintenanceResultResponseBuilder()..update(updates))._build();

  _$PaymentMaintenanceResultResponse._({required this.data}) : super._();
  @override
  PaymentMaintenanceResultResponse rebuild(
          void Function(PaymentMaintenanceResultResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PaymentMaintenanceResultResponseBuilder toBuilder() =>
      PaymentMaintenanceResultResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PaymentMaintenanceResultResponse && data == other.data;
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
    return (newBuiltValueToStringHelper(r'PaymentMaintenanceResultResponse')
          ..add('data', data))
        .toString();
  }
}

class PaymentMaintenanceResultResponseBuilder
    implements
        Builder<PaymentMaintenanceResultResponse,
            PaymentMaintenanceResultResponseBuilder> {
  _$PaymentMaintenanceResultResponse? _$v;

  PaymentMaintenanceResultBuilder? _data;
  PaymentMaintenanceResultBuilder get data =>
      _$this._data ??= PaymentMaintenanceResultBuilder();
  set data(PaymentMaintenanceResultBuilder? data) => _$this._data = data;

  PaymentMaintenanceResultResponseBuilder() {
    PaymentMaintenanceResultResponse._defaults(this);
  }

  PaymentMaintenanceResultResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PaymentMaintenanceResultResponse other) {
    _$v = other as _$PaymentMaintenanceResultResponse;
  }

  @override
  void update(void Function(PaymentMaintenanceResultResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PaymentMaintenanceResultResponse build() => _build();

  _$PaymentMaintenanceResultResponse _build() {
    _$PaymentMaintenanceResultResponse _$result;
    try {
      _$result = _$v ??
          _$PaymentMaintenanceResultResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PaymentMaintenanceResultResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
