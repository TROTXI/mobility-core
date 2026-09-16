// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credential_secret_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CredentialSecretResponse extends CredentialSecretResponse {
  @override
  final CredentialSecret data;

  factory _$CredentialSecretResponse(
          [void Function(CredentialSecretResponseBuilder)? updates]) =>
      (CredentialSecretResponseBuilder()..update(updates))._build();

  _$CredentialSecretResponse._({required this.data}) : super._();
  @override
  CredentialSecretResponse rebuild(
          void Function(CredentialSecretResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CredentialSecretResponseBuilder toBuilder() =>
      CredentialSecretResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CredentialSecretResponse && data == other.data;
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
    return (newBuiltValueToStringHelper(r'CredentialSecretResponse')
          ..add('data', data))
        .toString();
  }
}

class CredentialSecretResponseBuilder
    implements
        Builder<CredentialSecretResponse, CredentialSecretResponseBuilder> {
  _$CredentialSecretResponse? _$v;

  CredentialSecretBuilder? _data;
  CredentialSecretBuilder get data =>
      _$this._data ??= CredentialSecretBuilder();
  set data(CredentialSecretBuilder? data) => _$this._data = data;

  CredentialSecretResponseBuilder() {
    CredentialSecretResponse._defaults(this);
  }

  CredentialSecretResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CredentialSecretResponse other) {
    _$v = other as _$CredentialSecretResponse;
  }

  @override
  void update(void Function(CredentialSecretResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CredentialSecretResponse build() => _build();

  _$CredentialSecretResponse _build() {
    _$CredentialSecretResponse _$result;
    try {
      _$result = _$v ??
          _$CredentialSecretResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'CredentialSecretResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
