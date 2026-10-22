// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'terms_status_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TermsStatusResponse extends TermsStatusResponse {
  @override
  final TermsStatus data;

  factory _$TermsStatusResponse(
          [void Function(TermsStatusResponseBuilder)? updates]) =>
      (TermsStatusResponseBuilder()..update(updates))._build();

  _$TermsStatusResponse._({required this.data}) : super._();
  @override
  TermsStatusResponse rebuild(
          void Function(TermsStatusResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TermsStatusResponseBuilder toBuilder() =>
      TermsStatusResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TermsStatusResponse && data == other.data;
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
    return (newBuiltValueToStringHelper(r'TermsStatusResponse')
          ..add('data', data))
        .toString();
  }
}

class TermsStatusResponseBuilder
    implements Builder<TermsStatusResponse, TermsStatusResponseBuilder> {
  _$TermsStatusResponse? _$v;

  TermsStatusBuilder? _data;
  TermsStatusBuilder get data => _$this._data ??= TermsStatusBuilder();
  set data(TermsStatusBuilder? data) => _$this._data = data;

  TermsStatusResponseBuilder() {
    TermsStatusResponse._defaults(this);
  }

  TermsStatusResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TermsStatusResponse other) {
    _$v = other as _$TermsStatusResponse;
  }

  @override
  void update(void Function(TermsStatusResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TermsStatusResponse build() => _build();

  _$TermsStatusResponse _build() {
    _$TermsStatusResponse _$result;
    try {
      _$result = _$v ??
          _$TermsStatusResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TermsStatusResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
