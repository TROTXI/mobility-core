// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation_detail_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ReservationDetailResponse extends ReservationDetailResponse {
  @override
  final ReservationDetail data;

  factory _$ReservationDetailResponse(
          [void Function(ReservationDetailResponseBuilder)? updates]) =>
      (ReservationDetailResponseBuilder()..update(updates))._build();

  _$ReservationDetailResponse._({required this.data}) : super._();
  @override
  ReservationDetailResponse rebuild(
          void Function(ReservationDetailResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReservationDetailResponseBuilder toBuilder() =>
      ReservationDetailResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReservationDetailResponse && data == other.data;
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
    return (newBuiltValueToStringHelper(r'ReservationDetailResponse')
          ..add('data', data))
        .toString();
  }
}

class ReservationDetailResponseBuilder
    implements
        Builder<ReservationDetailResponse, ReservationDetailResponseBuilder> {
  _$ReservationDetailResponse? _$v;

  ReservationDetailBuilder? _data;
  ReservationDetailBuilder get data =>
      _$this._data ??= ReservationDetailBuilder();
  set data(ReservationDetailBuilder? data) => _$this._data = data;

  ReservationDetailResponseBuilder() {
    ReservationDetailResponse._defaults(this);
  }

  ReservationDetailResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReservationDetailResponse other) {
    _$v = other as _$ReservationDetailResponse;
  }

  @override
  void update(void Function(ReservationDetailResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReservationDetailResponse build() => _build();

  _$ReservationDetailResponse _build() {
    _$ReservationDetailResponse _$result;
    try {
      _$result = _$v ??
          _$ReservationDetailResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ReservationDetailResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
