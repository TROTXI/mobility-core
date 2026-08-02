// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_routes_id_stops_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminRoutesIdStopsPostRequest extends AdminRoutesIdStopsPostRequest {
  @override
  final String stopId;
  @override
  final int seq;

  factory _$AdminRoutesIdStopsPostRequest(
          [void Function(AdminRoutesIdStopsPostRequestBuilder)? updates]) =>
      (AdminRoutesIdStopsPostRequestBuilder()..update(updates))._build();

  _$AdminRoutesIdStopsPostRequest._({required this.stopId, required this.seq})
      : super._();
  @override
  AdminRoutesIdStopsPostRequest rebuild(
          void Function(AdminRoutesIdStopsPostRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminRoutesIdStopsPostRequestBuilder toBuilder() =>
      AdminRoutesIdStopsPostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminRoutesIdStopsPostRequest &&
        stopId == other.stopId &&
        seq == other.seq;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, stopId.hashCode);
    _$hash = $jc(_$hash, seq.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminRoutesIdStopsPostRequest')
          ..add('stopId', stopId)
          ..add('seq', seq))
        .toString();
  }
}

class AdminRoutesIdStopsPostRequestBuilder
    implements
        Builder<AdminRoutesIdStopsPostRequest,
            AdminRoutesIdStopsPostRequestBuilder> {
  _$AdminRoutesIdStopsPostRequest? _$v;

  String? _stopId;
  String? get stopId => _$this._stopId;
  set stopId(String? stopId) => _$this._stopId = stopId;

  int? _seq;
  int? get seq => _$this._seq;
  set seq(int? seq) => _$this._seq = seq;

  AdminRoutesIdStopsPostRequestBuilder() {
    AdminRoutesIdStopsPostRequest._defaults(this);
  }

  AdminRoutesIdStopsPostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _stopId = $v.stopId;
      _seq = $v.seq;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminRoutesIdStopsPostRequest other) {
    _$v = other as _$AdminRoutesIdStopsPostRequest;
  }

  @override
  void update(void Function(AdminRoutesIdStopsPostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminRoutesIdStopsPostRequest build() => _build();

  _$AdminRoutesIdStopsPostRequest _build() {
    final _$result = _$v ??
        _$AdminRoutesIdStopsPostRequest._(
          stopId: BuiltValueNullFieldError.checkNotNull(
              stopId, r'AdminRoutesIdStopsPostRequest', 'stopId'),
          seq: BuiltValueNullFieldError.checkNotNull(
              seq, r'AdminRoutesIdStopsPostRequest', 'seq'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
