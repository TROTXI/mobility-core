// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phone_verification_result_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PhoneVerificationResultResponse
    extends PhoneVerificationResultResponse {
  @override
  final PhoneVerificationResult data;

  factory _$PhoneVerificationResultResponse(
          [void Function(PhoneVerificationResultResponseBuilder)? updates]) =>
      (PhoneVerificationResultResponseBuilder()..update(updates))._build();

  _$PhoneVerificationResultResponse._({required this.data}) : super._();
  @override
  PhoneVerificationResultResponse rebuild(
          void Function(PhoneVerificationResultResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PhoneVerificationResultResponseBuilder toBuilder() =>
      PhoneVerificationResultResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PhoneVerificationResultResponse && data == other.data;
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
    return (newBuiltValueToStringHelper(r'PhoneVerificationResultResponse')
          ..add('data', data))
        .toString();
  }
}

class PhoneVerificationResultResponseBuilder
    implements
        Builder<PhoneVerificationResultResponse,
            PhoneVerificationResultResponseBuilder> {
  _$PhoneVerificationResultResponse? _$v;

  PhoneVerificationResultBuilder? _data;
  PhoneVerificationResultBuilder get data =>
      _$this._data ??= PhoneVerificationResultBuilder();
  set data(PhoneVerificationResultBuilder? data) => _$this._data = data;

  PhoneVerificationResultResponseBuilder() {
    PhoneVerificationResultResponse._defaults(this);
  }

  PhoneVerificationResultResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PhoneVerificationResultResponse other) {
    _$v = other as _$PhoneVerificationResultResponse;
  }

  @override
  void update(void Function(PhoneVerificationResultResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PhoneVerificationResultResponse build() => _build();

  _$PhoneVerificationResultResponse _build() {
    _$PhoneVerificationResultResponse _$result;
    try {
      _$result = _$v ??
          _$PhoneVerificationResultResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PhoneVerificationResultResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
