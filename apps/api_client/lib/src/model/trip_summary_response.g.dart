// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_summary_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TripSummaryResponse extends TripSummaryResponse {
  @override
  final TripSummary data;

  factory _$TripSummaryResponse(
          [void Function(TripSummaryResponseBuilder)? updates]) =>
      (TripSummaryResponseBuilder()..update(updates))._build();

  _$TripSummaryResponse._({required this.data}) : super._();
  @override
  TripSummaryResponse rebuild(
          void Function(TripSummaryResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TripSummaryResponseBuilder toBuilder() =>
      TripSummaryResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TripSummaryResponse && data == other.data;
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
    return (newBuiltValueToStringHelper(r'TripSummaryResponse')
          ..add('data', data))
        .toString();
  }
}

class TripSummaryResponseBuilder
    implements Builder<TripSummaryResponse, TripSummaryResponseBuilder> {
  _$TripSummaryResponse? _$v;

  TripSummaryBuilder? _data;
  TripSummaryBuilder get data => _$this._data ??= TripSummaryBuilder();
  set data(TripSummaryBuilder? data) => _$this._data = data;

  TripSummaryResponseBuilder() {
    TripSummaryResponse._defaults(this);
  }

  TripSummaryResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TripSummaryResponse other) {
    _$v = other as _$TripSummaryResponse;
  }

  @override
  void update(void Function(TripSummaryResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TripSummaryResponse build() => _build();

  _$TripSummaryResponse _build() {
    _$TripSummaryResponse _$result;
    try {
      _$result = _$v ??
          _$TripSummaryResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TripSummaryResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
