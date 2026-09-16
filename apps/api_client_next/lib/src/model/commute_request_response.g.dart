// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commute_request_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CommuteRequestResponse extends CommuteRequestResponse {
  @override
  final CommuteRequest data;

  factory _$CommuteRequestResponse(
          [void Function(CommuteRequestResponseBuilder)? updates]) =>
      (CommuteRequestResponseBuilder()..update(updates))._build();

  _$CommuteRequestResponse._({required this.data}) : super._();
  @override
  CommuteRequestResponse rebuild(
          void Function(CommuteRequestResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CommuteRequestResponseBuilder toBuilder() =>
      CommuteRequestResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CommuteRequestResponse && data == other.data;
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
    return (newBuiltValueToStringHelper(r'CommuteRequestResponse')
          ..add('data', data))
        .toString();
  }
}

class CommuteRequestResponseBuilder
    implements Builder<CommuteRequestResponse, CommuteRequestResponseBuilder> {
  _$CommuteRequestResponse? _$v;

  CommuteRequestBuilder? _data;
  CommuteRequestBuilder get data => _$this._data ??= CommuteRequestBuilder();
  set data(CommuteRequestBuilder? data) => _$this._data = data;

  CommuteRequestResponseBuilder() {
    CommuteRequestResponse._defaults(this);
  }

  CommuteRequestResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CommuteRequestResponse other) {
    _$v = other as _$CommuteRequestResponse;
  }

  @override
  void update(void Function(CommuteRequestResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CommuteRequestResponse build() => _build();

  _$CommuteRequestResponse _build() {
    _$CommuteRequestResponse _$result;
    try {
      _$result = _$v ??
          _$CommuteRequestResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'CommuteRequestResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
