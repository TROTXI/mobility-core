// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'email_access_status_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$EmailAccessStatusResponse extends EmailAccessStatusResponse {
  @override
  final EmailAccessStatus data;

  factory _$EmailAccessStatusResponse(
          [void Function(EmailAccessStatusResponseBuilder)? updates]) =>
      (EmailAccessStatusResponseBuilder()..update(updates))._build();

  _$EmailAccessStatusResponse._({required this.data}) : super._();
  @override
  EmailAccessStatusResponse rebuild(
          void Function(EmailAccessStatusResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  EmailAccessStatusResponseBuilder toBuilder() =>
      EmailAccessStatusResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is EmailAccessStatusResponse && data == other.data;
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
    return (newBuiltValueToStringHelper(r'EmailAccessStatusResponse')
          ..add('data', data))
        .toString();
  }
}

class EmailAccessStatusResponseBuilder
    implements
        Builder<EmailAccessStatusResponse, EmailAccessStatusResponseBuilder> {
  _$EmailAccessStatusResponse? _$v;

  EmailAccessStatusBuilder? _data;
  EmailAccessStatusBuilder get data =>
      _$this._data ??= EmailAccessStatusBuilder();
  set data(EmailAccessStatusBuilder? data) => _$this._data = data;

  EmailAccessStatusResponseBuilder() {
    EmailAccessStatusResponse._defaults(this);
  }

  EmailAccessStatusResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(EmailAccessStatusResponse other) {
    _$v = other as _$EmailAccessStatusResponse;
  }

  @override
  void update(void Function(EmailAccessStatusResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  EmailAccessStatusResponse build() => _build();

  _$EmailAccessStatusResponse _build() {
    _$EmailAccessStatusResponse _$result;
    try {
      _$result = _$v ??
          _$EmailAccessStatusResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'EmailAccessStatusResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
