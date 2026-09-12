// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trips_id_arrive_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TripsIdArrivePostRequest extends TripsIdArrivePostRequest {
  @override
  final int seq;

  factory _$TripsIdArrivePostRequest(
          [void Function(TripsIdArrivePostRequestBuilder)? updates]) =>
      (TripsIdArrivePostRequestBuilder()..update(updates))._build();

  _$TripsIdArrivePostRequest._({required this.seq}) : super._();
  @override
  TripsIdArrivePostRequest rebuild(
          void Function(TripsIdArrivePostRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TripsIdArrivePostRequestBuilder toBuilder() =>
      TripsIdArrivePostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TripsIdArrivePostRequest && seq == other.seq;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, seq.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TripsIdArrivePostRequest')
          ..add('seq', seq))
        .toString();
  }
}

class TripsIdArrivePostRequestBuilder
    implements
        Builder<TripsIdArrivePostRequest, TripsIdArrivePostRequestBuilder> {
  _$TripsIdArrivePostRequest? _$v;

  int? _seq;
  int? get seq => _$this._seq;
  set seq(int? seq) => _$this._seq = seq;

  TripsIdArrivePostRequestBuilder() {
    TripsIdArrivePostRequest._defaults(this);
  }

  TripsIdArrivePostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _seq = $v.seq;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TripsIdArrivePostRequest other) {
    _$v = other as _$TripsIdArrivePostRequest;
  }

  @override
  void update(void Function(TripsIdArrivePostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TripsIdArrivePostRequest build() => _build();

  _$TripsIdArrivePostRequest _build() {
    final _$result = _$v ??
        _$TripsIdArrivePostRequest._(
          seq: BuiltValueNullFieldError.checkNotNull(
              seq, r'TripsIdArrivePostRequest', 'seq'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
