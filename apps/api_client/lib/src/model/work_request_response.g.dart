// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_request_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$WorkRequestResponse extends WorkRequestResponse {
  @override
  final WorkRequest data;

  factory _$WorkRequestResponse(
          [void Function(WorkRequestResponseBuilder)? updates]) =>
      (WorkRequestResponseBuilder()..update(updates))._build();

  _$WorkRequestResponse._({required this.data}) : super._();
  @override
  WorkRequestResponse rebuild(
          void Function(WorkRequestResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  WorkRequestResponseBuilder toBuilder() =>
      WorkRequestResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WorkRequestResponse && data == other.data;
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
    return (newBuiltValueToStringHelper(r'WorkRequestResponse')
          ..add('data', data))
        .toString();
  }
}

class WorkRequestResponseBuilder
    implements Builder<WorkRequestResponse, WorkRequestResponseBuilder> {
  _$WorkRequestResponse? _$v;

  WorkRequestBuilder? _data;
  WorkRequestBuilder get data => _$this._data ??= WorkRequestBuilder();
  set data(WorkRequestBuilder? data) => _$this._data = data;

  WorkRequestResponseBuilder() {
    WorkRequestResponse._defaults(this);
  }

  WorkRequestResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WorkRequestResponse other) {
    _$v = other as _$WorkRequestResponse;
  }

  @override
  void update(void Function(WorkRequestResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WorkRequestResponse build() => _build();

  _$WorkRequestResponse _build() {
    _$WorkRequestResponse _$result;
    try {
      _$result = _$v ??
          _$WorkRequestResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'WorkRequestResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
