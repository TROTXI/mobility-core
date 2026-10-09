// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'standby_application_page_route_demand_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$StandbyApplicationPageRouteDemandInner
    extends StandbyApplicationPageRouteDemandInner {
  @override
  final String routeId;
  @override
  final String routeName;
  @override
  final int requests;

  factory _$StandbyApplicationPageRouteDemandInner(
          [void Function(StandbyApplicationPageRouteDemandInnerBuilder)?
              updates]) =>
      (StandbyApplicationPageRouteDemandInnerBuilder()..update(updates))
          ._build();

  _$StandbyApplicationPageRouteDemandInner._(
      {required this.routeId, required this.routeName, required this.requests})
      : super._();
  @override
  StandbyApplicationPageRouteDemandInner rebuild(
          void Function(StandbyApplicationPageRouteDemandInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  StandbyApplicationPageRouteDemandInnerBuilder toBuilder() =>
      StandbyApplicationPageRouteDemandInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is StandbyApplicationPageRouteDemandInner &&
        routeId == other.routeId &&
        routeName == other.routeName &&
        requests == other.requests;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, routeId.hashCode);
    _$hash = $jc(_$hash, routeName.hashCode);
    _$hash = $jc(_$hash, requests.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'StandbyApplicationPageRouteDemandInner')
          ..add('routeId', routeId)
          ..add('routeName', routeName)
          ..add('requests', requests))
        .toString();
  }
}

class StandbyApplicationPageRouteDemandInnerBuilder
    implements
        Builder<StandbyApplicationPageRouteDemandInner,
            StandbyApplicationPageRouteDemandInnerBuilder> {
  _$StandbyApplicationPageRouteDemandInner? _$v;

  String? _routeId;
  String? get routeId => _$this._routeId;
  set routeId(String? routeId) => _$this._routeId = routeId;

  String? _routeName;
  String? get routeName => _$this._routeName;
  set routeName(String? routeName) => _$this._routeName = routeName;

  int? _requests;
  int? get requests => _$this._requests;
  set requests(int? requests) => _$this._requests = requests;

  StandbyApplicationPageRouteDemandInnerBuilder() {
    StandbyApplicationPageRouteDemandInner._defaults(this);
  }

  StandbyApplicationPageRouteDemandInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _routeId = $v.routeId;
      _routeName = $v.routeName;
      _requests = $v.requests;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(StandbyApplicationPageRouteDemandInner other) {
    _$v = other as _$StandbyApplicationPageRouteDemandInner;
  }

  @override
  void update(
      void Function(StandbyApplicationPageRouteDemandInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  StandbyApplicationPageRouteDemandInner build() => _build();

  _$StandbyApplicationPageRouteDemandInner _build() {
    final _$result = _$v ??
        _$StandbyApplicationPageRouteDemandInner._(
          routeId: BuiltValueNullFieldError.checkNotNull(
              routeId, r'StandbyApplicationPageRouteDemandInner', 'routeId'),
          routeName: BuiltValueNullFieldError.checkNotNull(routeName,
              r'StandbyApplicationPageRouteDemandInner', 'routeName'),
          requests: BuiltValueNullFieldError.checkNotNull(
              requests, r'StandbyApplicationPageRouteDemandInner', 'requests'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
