// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ops_report_summary_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OpsReportSummaryResponse extends OpsReportSummaryResponse {
  @override
  final OpsReportSummary data;

  factory _$OpsReportSummaryResponse(
          [void Function(OpsReportSummaryResponseBuilder)? updates]) =>
      (OpsReportSummaryResponseBuilder()..update(updates))._build();

  _$OpsReportSummaryResponse._({required this.data}) : super._();
  @override
  OpsReportSummaryResponse rebuild(
          void Function(OpsReportSummaryResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OpsReportSummaryResponseBuilder toBuilder() =>
      OpsReportSummaryResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OpsReportSummaryResponse && data == other.data;
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
    return (newBuiltValueToStringHelper(r'OpsReportSummaryResponse')
          ..add('data', data))
        .toString();
  }
}

class OpsReportSummaryResponseBuilder
    implements
        Builder<OpsReportSummaryResponse, OpsReportSummaryResponseBuilder> {
  _$OpsReportSummaryResponse? _$v;

  OpsReportSummaryBuilder? _data;
  OpsReportSummaryBuilder get data =>
      _$this._data ??= OpsReportSummaryBuilder();
  set data(OpsReportSummaryBuilder? data) => _$this._data = data;

  OpsReportSummaryResponseBuilder() {
    OpsReportSummaryResponse._defaults(this);
  }

  OpsReportSummaryResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OpsReportSummaryResponse other) {
    _$v = other as _$OpsReportSummaryResponse;
  }

  @override
  void update(void Function(OpsReportSummaryResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OpsReportSummaryResponse build() => _build();

  _$OpsReportSummaryResponse _build() {
    _$OpsReportSummaryResponse _$result;
    try {
      _$result = _$v ??
          _$OpsReportSummaryResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'OpsReportSummaryResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
