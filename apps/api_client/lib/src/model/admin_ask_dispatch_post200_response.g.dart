// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_ask_dispatch_post200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminAskDispatchPost200Response
    extends AdminAskDispatchPost200Response {
  @override
  final int trips;
  @override
  final int asked;

  factory _$AdminAskDispatchPost200Response(
          [void Function(AdminAskDispatchPost200ResponseBuilder)? updates]) =>
      (AdminAskDispatchPost200ResponseBuilder()..update(updates))._build();

  _$AdminAskDispatchPost200Response._(
      {required this.trips, required this.asked})
      : super._();
  @override
  AdminAskDispatchPost200Response rebuild(
          void Function(AdminAskDispatchPost200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminAskDispatchPost200ResponseBuilder toBuilder() =>
      AdminAskDispatchPost200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminAskDispatchPost200Response &&
        trips == other.trips &&
        asked == other.asked;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, trips.hashCode);
    _$hash = $jc(_$hash, asked.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminAskDispatchPost200Response')
          ..add('trips', trips)
          ..add('asked', asked))
        .toString();
  }
}

class AdminAskDispatchPost200ResponseBuilder
    implements
        Builder<AdminAskDispatchPost200Response,
            AdminAskDispatchPost200ResponseBuilder> {
  _$AdminAskDispatchPost200Response? _$v;

  int? _trips;
  int? get trips => _$this._trips;
  set trips(int? trips) => _$this._trips = trips;

  int? _asked;
  int? get asked => _$this._asked;
  set asked(int? asked) => _$this._asked = asked;

  AdminAskDispatchPost200ResponseBuilder() {
    AdminAskDispatchPost200Response._defaults(this);
  }

  AdminAskDispatchPost200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _trips = $v.trips;
      _asked = $v.asked;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminAskDispatchPost200Response other) {
    _$v = other as _$AdminAskDispatchPost200Response;
  }

  @override
  void update(void Function(AdminAskDispatchPost200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminAskDispatchPost200Response build() => _build();

  _$AdminAskDispatchPost200Response _build() {
    final _$result = _$v ??
        _$AdminAskDispatchPost200Response._(
          trips: BuiltValueNullFieldError.checkNotNull(
              trips, r'AdminAskDispatchPost200Response', 'trips'),
          asked: BuiltValueNullFieldError.checkNotNull(
              asked, r'AdminAskDispatchPost200Response', 'asked'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
