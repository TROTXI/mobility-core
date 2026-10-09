// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auto_renewal_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AutoRenewalResponse extends AutoRenewalResponse {
  @override
  final AutoRenewal data;

  factory _$AutoRenewalResponse(
          [void Function(AutoRenewalResponseBuilder)? updates]) =>
      (AutoRenewalResponseBuilder()..update(updates))._build();

  _$AutoRenewalResponse._({required this.data}) : super._();
  @override
  AutoRenewalResponse rebuild(
          void Function(AutoRenewalResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AutoRenewalResponseBuilder toBuilder() =>
      AutoRenewalResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AutoRenewalResponse && data == other.data;
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
    return (newBuiltValueToStringHelper(r'AutoRenewalResponse')
          ..add('data', data))
        .toString();
  }
}

class AutoRenewalResponseBuilder
    implements Builder<AutoRenewalResponse, AutoRenewalResponseBuilder> {
  _$AutoRenewalResponse? _$v;

  AutoRenewalBuilder? _data;
  AutoRenewalBuilder get data => _$this._data ??= AutoRenewalBuilder();
  set data(AutoRenewalBuilder? data) => _$this._data = data;

  AutoRenewalResponseBuilder() {
    AutoRenewalResponse._defaults(this);
  }

  AutoRenewalResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AutoRenewalResponse other) {
    _$v = other as _$AutoRenewalResponse;
  }

  @override
  void update(void Function(AutoRenewalResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AutoRenewalResponse build() => _build();

  _$AutoRenewalResponse _build() {
    _$AutoRenewalResponse _$result;
    try {
      _$result = _$v ??
          _$AutoRenewalResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'AutoRenewalResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
