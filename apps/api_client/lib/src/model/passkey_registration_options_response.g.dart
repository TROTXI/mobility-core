// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'passkey_registration_options_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PasskeyRegistrationOptionsResponse
    extends PasskeyRegistrationOptionsResponse {
  @override
  final PasskeyRegistrationOptions data;

  factory _$PasskeyRegistrationOptionsResponse(
          [void Function(PasskeyRegistrationOptionsResponseBuilder)?
              updates]) =>
      (PasskeyRegistrationOptionsResponseBuilder()..update(updates))._build();

  _$PasskeyRegistrationOptionsResponse._({required this.data}) : super._();
  @override
  PasskeyRegistrationOptionsResponse rebuild(
          void Function(PasskeyRegistrationOptionsResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PasskeyRegistrationOptionsResponseBuilder toBuilder() =>
      PasskeyRegistrationOptionsResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PasskeyRegistrationOptionsResponse && data == other.data;
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
    return (newBuiltValueToStringHelper(r'PasskeyRegistrationOptionsResponse')
          ..add('data', data))
        .toString();
  }
}

class PasskeyRegistrationOptionsResponseBuilder
    implements
        Builder<PasskeyRegistrationOptionsResponse,
            PasskeyRegistrationOptionsResponseBuilder> {
  _$PasskeyRegistrationOptionsResponse? _$v;

  PasskeyRegistrationOptionsBuilder? _data;
  PasskeyRegistrationOptionsBuilder get data =>
      _$this._data ??= PasskeyRegistrationOptionsBuilder();
  set data(PasskeyRegistrationOptionsBuilder? data) => _$this._data = data;

  PasskeyRegistrationOptionsResponseBuilder() {
    PasskeyRegistrationOptionsResponse._defaults(this);
  }

  PasskeyRegistrationOptionsResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PasskeyRegistrationOptionsResponse other) {
    _$v = other as _$PasskeyRegistrationOptionsResponse;
  }

  @override
  void update(
      void Function(PasskeyRegistrationOptionsResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PasskeyRegistrationOptionsResponse build() => _build();

  _$PasskeyRegistrationOptionsResponse _build() {
    _$PasskeyRegistrationOptionsResponse _$result;
    try {
      _$result = _$v ??
          _$PasskeyRegistrationOptionsResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PasskeyRegistrationOptionsResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
