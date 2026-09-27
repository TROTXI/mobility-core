// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ops_rider_summary_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OpsRiderSummaryResponse extends OpsRiderSummaryResponse {
  @override
  final OpsRiderSummary data;

  factory _$OpsRiderSummaryResponse(
          [void Function(OpsRiderSummaryResponseBuilder)? updates]) =>
      (OpsRiderSummaryResponseBuilder()..update(updates))._build();

  _$OpsRiderSummaryResponse._({required this.data}) : super._();
  @override
  OpsRiderSummaryResponse rebuild(
          void Function(OpsRiderSummaryResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OpsRiderSummaryResponseBuilder toBuilder() =>
      OpsRiderSummaryResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OpsRiderSummaryResponse && data == other.data;
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
    return (newBuiltValueToStringHelper(r'OpsRiderSummaryResponse')
          ..add('data', data))
        .toString();
  }
}

class OpsRiderSummaryResponseBuilder
    implements
        Builder<OpsRiderSummaryResponse, OpsRiderSummaryResponseBuilder> {
  _$OpsRiderSummaryResponse? _$v;

  OpsRiderSummaryBuilder? _data;
  OpsRiderSummaryBuilder get data => _$this._data ??= OpsRiderSummaryBuilder();
  set data(OpsRiderSummaryBuilder? data) => _$this._data = data;

  OpsRiderSummaryResponseBuilder() {
    OpsRiderSummaryResponse._defaults(this);
  }

  OpsRiderSummaryResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OpsRiderSummaryResponse other) {
    _$v = other as _$OpsRiderSummaryResponse;
  }

  @override
  void update(void Function(OpsRiderSummaryResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OpsRiderSummaryResponse build() => _build();

  _$OpsRiderSummaryResponse _build() {
    _$OpsRiderSummaryResponse _$result;
    try {
      _$result = _$v ??
          _$OpsRiderSummaryResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'OpsRiderSummaryResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
