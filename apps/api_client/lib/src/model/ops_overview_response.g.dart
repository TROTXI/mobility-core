// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ops_overview_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OpsOverviewResponse extends OpsOverviewResponse {
  @override
  final OpsOverview data;

  factory _$OpsOverviewResponse(
          [void Function(OpsOverviewResponseBuilder)? updates]) =>
      (OpsOverviewResponseBuilder()..update(updates))._build();

  _$OpsOverviewResponse._({required this.data}) : super._();
  @override
  OpsOverviewResponse rebuild(
          void Function(OpsOverviewResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OpsOverviewResponseBuilder toBuilder() =>
      OpsOverviewResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OpsOverviewResponse && data == other.data;
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
    return (newBuiltValueToStringHelper(r'OpsOverviewResponse')
          ..add('data', data))
        .toString();
  }
}

class OpsOverviewResponseBuilder
    implements Builder<OpsOverviewResponse, OpsOverviewResponseBuilder> {
  _$OpsOverviewResponse? _$v;

  OpsOverviewBuilder? _data;
  OpsOverviewBuilder get data => _$this._data ??= OpsOverviewBuilder();
  set data(OpsOverviewBuilder? data) => _$this._data = data;

  OpsOverviewResponseBuilder() {
    OpsOverviewResponse._defaults(this);
  }

  OpsOverviewResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OpsOverviewResponse other) {
    _$v = other as _$OpsOverviewResponse;
  }

  @override
  void update(void Function(OpsOverviewResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OpsOverviewResponse build() => _build();

  _$OpsOverviewResponse _build() {
    _$OpsOverviewResponse _$result;
    try {
      _$result = _$v ??
          _$OpsOverviewResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'OpsOverviewResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
