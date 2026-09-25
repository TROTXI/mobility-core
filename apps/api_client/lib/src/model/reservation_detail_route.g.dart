// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation_detail_route.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ReservationDetailRoute extends ReservationDetailRoute {
  @override
  final String id;
  @override
  final String name;

  factory _$ReservationDetailRoute(
          [void Function(ReservationDetailRouteBuilder)? updates]) =>
      (ReservationDetailRouteBuilder()..update(updates))._build();

  _$ReservationDetailRoute._({required this.id, required this.name})
      : super._();
  @override
  ReservationDetailRoute rebuild(
          void Function(ReservationDetailRouteBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReservationDetailRouteBuilder toBuilder() =>
      ReservationDetailRouteBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReservationDetailRoute &&
        id == other.id &&
        name == other.name;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ReservationDetailRoute')
          ..add('id', id)
          ..add('name', name))
        .toString();
  }
}

class ReservationDetailRouteBuilder
    implements Builder<ReservationDetailRoute, ReservationDetailRouteBuilder> {
  _$ReservationDetailRoute? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  ReservationDetailRouteBuilder() {
    ReservationDetailRoute._defaults(this);
  }

  ReservationDetailRouteBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReservationDetailRoute other) {
    _$v = other as _$ReservationDetailRoute;
  }

  @override
  void update(void Function(ReservationDetailRouteBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReservationDetailRoute build() => _build();

  _$ReservationDetailRoute _build() {
    final _$result = _$v ??
        _$ReservationDetailRoute._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'ReservationDetailRoute', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'ReservationDetailRoute', 'name'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
