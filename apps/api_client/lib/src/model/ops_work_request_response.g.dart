// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ops_work_request_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OpsWorkRequestResponse extends OpsWorkRequestResponse {
  @override
  final OpsWorkRequest data;

  factory _$OpsWorkRequestResponse(
          [void Function(OpsWorkRequestResponseBuilder)? updates]) =>
      (OpsWorkRequestResponseBuilder()..update(updates))._build();

  _$OpsWorkRequestResponse._({required this.data}) : super._();
  @override
  OpsWorkRequestResponse rebuild(
          void Function(OpsWorkRequestResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OpsWorkRequestResponseBuilder toBuilder() =>
      OpsWorkRequestResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OpsWorkRequestResponse && data == other.data;
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
    return (newBuiltValueToStringHelper(r'OpsWorkRequestResponse')
          ..add('data', data))
        .toString();
  }
}

class OpsWorkRequestResponseBuilder
    implements Builder<OpsWorkRequestResponse, OpsWorkRequestResponseBuilder> {
  _$OpsWorkRequestResponse? _$v;

  OpsWorkRequestBuilder? _data;
  OpsWorkRequestBuilder get data => _$this._data ??= OpsWorkRequestBuilder();
  set data(OpsWorkRequestBuilder? data) => _$this._data = data;

  OpsWorkRequestResponseBuilder() {
    OpsWorkRequestResponse._defaults(this);
  }

  OpsWorkRequestResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OpsWorkRequestResponse other) {
    _$v = other as _$OpsWorkRequestResponse;
  }

  @override
  void update(void Function(OpsWorkRequestResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OpsWorkRequestResponse build() => _build();

  _$OpsWorkRequestResponse _build() {
    _$OpsWorkRequestResponse _$result;
    try {
      _$result = _$v ??
          _$OpsWorkRequestResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'OpsWorkRequestResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
