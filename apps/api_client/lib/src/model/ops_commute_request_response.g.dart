// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ops_commute_request_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OpsCommuteRequestResponse extends OpsCommuteRequestResponse {
  @override
  final OpsCommuteRequest data;

  factory _$OpsCommuteRequestResponse(
          [void Function(OpsCommuteRequestResponseBuilder)? updates]) =>
      (OpsCommuteRequestResponseBuilder()..update(updates))._build();

  _$OpsCommuteRequestResponse._({required this.data}) : super._();
  @override
  OpsCommuteRequestResponse rebuild(
          void Function(OpsCommuteRequestResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OpsCommuteRequestResponseBuilder toBuilder() =>
      OpsCommuteRequestResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OpsCommuteRequestResponse && data == other.data;
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
    return (newBuiltValueToStringHelper(r'OpsCommuteRequestResponse')
          ..add('data', data))
        .toString();
  }
}

class OpsCommuteRequestResponseBuilder
    implements
        Builder<OpsCommuteRequestResponse, OpsCommuteRequestResponseBuilder> {
  _$OpsCommuteRequestResponse? _$v;

  OpsCommuteRequestBuilder? _data;
  OpsCommuteRequestBuilder get data =>
      _$this._data ??= OpsCommuteRequestBuilder();
  set data(OpsCommuteRequestBuilder? data) => _$this._data = data;

  OpsCommuteRequestResponseBuilder() {
    OpsCommuteRequestResponse._defaults(this);
  }

  OpsCommuteRequestResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OpsCommuteRequestResponse other) {
    _$v = other as _$OpsCommuteRequestResponse;
  }

  @override
  void update(void Function(OpsCommuteRequestResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OpsCommuteRequestResponse build() => _build();

  _$OpsCommuteRequestResponse _build() {
    _$OpsCommuteRequestResponse _$result;
    try {
      _$result = _$v ??
          _$OpsCommuteRequestResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'OpsCommuteRequestResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
