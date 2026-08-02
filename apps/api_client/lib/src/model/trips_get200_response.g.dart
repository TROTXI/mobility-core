// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trips_get200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TripsGet200Response extends TripsGet200Response {
  @override
  final BuiltList<TripsGet200ResponseTripsInner> trips;

  factory _$TripsGet200Response(
          [void Function(TripsGet200ResponseBuilder)? updates]) =>
      (TripsGet200ResponseBuilder()..update(updates))._build();

  _$TripsGet200Response._({required this.trips}) : super._();
  @override
  TripsGet200Response rebuild(
          void Function(TripsGet200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TripsGet200ResponseBuilder toBuilder() =>
      TripsGet200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TripsGet200Response && trips == other.trips;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, trips.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TripsGet200Response')
          ..add('trips', trips))
        .toString();
  }
}

class TripsGet200ResponseBuilder
    implements Builder<TripsGet200Response, TripsGet200ResponseBuilder> {
  _$TripsGet200Response? _$v;

  ListBuilder<TripsGet200ResponseTripsInner>? _trips;
  ListBuilder<TripsGet200ResponseTripsInner> get trips =>
      _$this._trips ??= ListBuilder<TripsGet200ResponseTripsInner>();
  set trips(ListBuilder<TripsGet200ResponseTripsInner>? trips) =>
      _$this._trips = trips;

  TripsGet200ResponseBuilder() {
    TripsGet200Response._defaults(this);
  }

  TripsGet200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _trips = $v.trips.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TripsGet200Response other) {
    _$v = other as _$TripsGet200Response;
  }

  @override
  void update(void Function(TripsGet200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TripsGet200Response build() => _build();

  _$TripsGet200Response _build() {
    _$TripsGet200Response _$result;
    try {
      _$result = _$v ??
          _$TripsGet200Response._(
            trips: trips.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'trips';
        trips.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TripsGet200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
