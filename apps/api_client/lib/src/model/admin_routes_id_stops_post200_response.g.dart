// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_routes_id_stops_post200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminRoutesIdStopsPost200Response
    extends AdminRoutesIdStopsPost200Response {
  @override
  final String id;
  @override
  final String routeId;
  @override
  final String stopId;
  @override
  final int seq;
  @override
  final DateTime createdAt;

  factory _$AdminRoutesIdStopsPost200Response(
          [void Function(AdminRoutesIdStopsPost200ResponseBuilder)? updates]) =>
      (AdminRoutesIdStopsPost200ResponseBuilder()..update(updates))._build();

  _$AdminRoutesIdStopsPost200Response._(
      {required this.id,
      required this.routeId,
      required this.stopId,
      required this.seq,
      required this.createdAt})
      : super._();
  @override
  AdminRoutesIdStopsPost200Response rebuild(
          void Function(AdminRoutesIdStopsPost200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminRoutesIdStopsPost200ResponseBuilder toBuilder() =>
      AdminRoutesIdStopsPost200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminRoutesIdStopsPost200Response &&
        id == other.id &&
        routeId == other.routeId &&
        stopId == other.stopId &&
        seq == other.seq &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, routeId.hashCode);
    _$hash = $jc(_$hash, stopId.hashCode);
    _$hash = $jc(_$hash, seq.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminRoutesIdStopsPost200Response')
          ..add('id', id)
          ..add('routeId', routeId)
          ..add('stopId', stopId)
          ..add('seq', seq)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class AdminRoutesIdStopsPost200ResponseBuilder
    implements
        Builder<AdminRoutesIdStopsPost200Response,
            AdminRoutesIdStopsPost200ResponseBuilder> {
  _$AdminRoutesIdStopsPost200Response? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _routeId;
  String? get routeId => _$this._routeId;
  set routeId(String? routeId) => _$this._routeId = routeId;

  String? _stopId;
  String? get stopId => _$this._stopId;
  set stopId(String? stopId) => _$this._stopId = stopId;

  int? _seq;
  int? get seq => _$this._seq;
  set seq(int? seq) => _$this._seq = seq;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  AdminRoutesIdStopsPost200ResponseBuilder() {
    AdminRoutesIdStopsPost200Response._defaults(this);
  }

  AdminRoutesIdStopsPost200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _routeId = $v.routeId;
      _stopId = $v.stopId;
      _seq = $v.seq;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminRoutesIdStopsPost200Response other) {
    _$v = other as _$AdminRoutesIdStopsPost200Response;
  }

  @override
  void update(
      void Function(AdminRoutesIdStopsPost200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminRoutesIdStopsPost200Response build() => _build();

  _$AdminRoutesIdStopsPost200Response _build() {
    final _$result = _$v ??
        _$AdminRoutesIdStopsPost200Response._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'AdminRoutesIdStopsPost200Response', 'id'),
          routeId: BuiltValueNullFieldError.checkNotNull(
              routeId, r'AdminRoutesIdStopsPost200Response', 'routeId'),
          stopId: BuiltValueNullFieldError.checkNotNull(
              stopId, r'AdminRoutesIdStopsPost200Response', 'stopId'),
          seq: BuiltValueNullFieldError.checkNotNull(
              seq, r'AdminRoutesIdStopsPost200Response', 'seq'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'AdminRoutesIdStopsPost200Response', 'createdAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
