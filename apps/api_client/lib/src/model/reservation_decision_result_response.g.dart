// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation_decision_result_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ReservationDecisionResultResponse
    extends ReservationDecisionResultResponse {
  @override
  final ReservationDecisionResult data;

  factory _$ReservationDecisionResultResponse(
          [void Function(ReservationDecisionResultResponseBuilder)? updates]) =>
      (ReservationDecisionResultResponseBuilder()..update(updates))._build();

  _$ReservationDecisionResultResponse._({required this.data}) : super._();
  @override
  ReservationDecisionResultResponse rebuild(
          void Function(ReservationDecisionResultResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReservationDecisionResultResponseBuilder toBuilder() =>
      ReservationDecisionResultResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReservationDecisionResultResponse && data == other.data;
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
    return (newBuiltValueToStringHelper(r'ReservationDecisionResultResponse')
          ..add('data', data))
        .toString();
  }
}

class ReservationDecisionResultResponseBuilder
    implements
        Builder<ReservationDecisionResultResponse,
            ReservationDecisionResultResponseBuilder> {
  _$ReservationDecisionResultResponse? _$v;

  ReservationDecisionResultBuilder? _data;
  ReservationDecisionResultBuilder get data =>
      _$this._data ??= ReservationDecisionResultBuilder();
  set data(ReservationDecisionResultBuilder? data) => _$this._data = data;

  ReservationDecisionResultResponseBuilder() {
    ReservationDecisionResultResponse._defaults(this);
  }

  ReservationDecisionResultResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReservationDecisionResultResponse other) {
    _$v = other as _$ReservationDecisionResultResponse;
  }

  @override
  void update(
      void Function(ReservationDecisionResultResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReservationDecisionResultResponse build() => _build();

  _$ReservationDecisionResultResponse _build() {
    _$ReservationDecisionResultResponse _$result;
    try {
      _$result = _$v ??
          _$ReservationDecisionResultResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ReservationDecisionResultResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
