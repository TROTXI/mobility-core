// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'me_reservations_get200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MeReservationsGet200Response extends MeReservationsGet200Response {
  @override
  final BuiltList<MeReservationsGet200ResponseReservationsInner> reservations;

  factory _$MeReservationsGet200Response(
          [void Function(MeReservationsGet200ResponseBuilder)? updates]) =>
      (MeReservationsGet200ResponseBuilder()..update(updates))._build();

  _$MeReservationsGet200Response._({required this.reservations}) : super._();
  @override
  MeReservationsGet200Response rebuild(
          void Function(MeReservationsGet200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MeReservationsGet200ResponseBuilder toBuilder() =>
      MeReservationsGet200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MeReservationsGet200Response &&
        reservations == other.reservations;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, reservations.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MeReservationsGet200Response')
          ..add('reservations', reservations))
        .toString();
  }
}

class MeReservationsGet200ResponseBuilder
    implements
        Builder<MeReservationsGet200Response,
            MeReservationsGet200ResponseBuilder> {
  _$MeReservationsGet200Response? _$v;

  ListBuilder<MeReservationsGet200ResponseReservationsInner>? _reservations;
  ListBuilder<MeReservationsGet200ResponseReservationsInner> get reservations =>
      _$this._reservations ??=
          ListBuilder<MeReservationsGet200ResponseReservationsInner>();
  set reservations(
          ListBuilder<MeReservationsGet200ResponseReservationsInner>?
              reservations) =>
      _$this._reservations = reservations;

  MeReservationsGet200ResponseBuilder() {
    MeReservationsGet200Response._defaults(this);
  }

  MeReservationsGet200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _reservations = $v.reservations.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MeReservationsGet200Response other) {
    _$v = other as _$MeReservationsGet200Response;
  }

  @override
  void update(void Function(MeReservationsGet200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MeReservationsGet200Response build() => _build();

  _$MeReservationsGet200Response _build() {
    _$MeReservationsGet200Response _$result;
    try {
      _$result = _$v ??
          _$MeReservationsGet200Response._(
            reservations: reservations.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'reservations';
        reservations.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'MeReservationsGet200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
