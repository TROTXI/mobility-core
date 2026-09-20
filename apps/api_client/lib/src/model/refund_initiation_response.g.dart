// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'refund_initiation_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RefundInitiationResponse extends RefundInitiationResponse {
  @override
  final RefundInitiation data;

  factory _$RefundInitiationResponse(
          [void Function(RefundInitiationResponseBuilder)? updates]) =>
      (RefundInitiationResponseBuilder()..update(updates))._build();

  _$RefundInitiationResponse._({required this.data}) : super._();
  @override
  RefundInitiationResponse rebuild(
          void Function(RefundInitiationResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RefundInitiationResponseBuilder toBuilder() =>
      RefundInitiationResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RefundInitiationResponse && data == other.data;
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
    return (newBuiltValueToStringHelper(r'RefundInitiationResponse')
          ..add('data', data))
        .toString();
  }
}

class RefundInitiationResponseBuilder
    implements
        Builder<RefundInitiationResponse, RefundInitiationResponseBuilder> {
  _$RefundInitiationResponse? _$v;

  RefundInitiationBuilder? _data;
  RefundInitiationBuilder get data =>
      _$this._data ??= RefundInitiationBuilder();
  set data(RefundInitiationBuilder? data) => _$this._data = data;

  RefundInitiationResponseBuilder() {
    RefundInitiationResponse._defaults(this);
  }

  RefundInitiationResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RefundInitiationResponse other) {
    _$v = other as _$RefundInitiationResponse;
  }

  @override
  void update(void Function(RefundInitiationResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RefundInitiationResponse build() => _build();

  _$RefundInitiationResponse _build() {
    _$RefundInitiationResponse _$result;
    try {
      _$result = _$v ??
          _$RefundInitiationResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'RefundInitiationResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
