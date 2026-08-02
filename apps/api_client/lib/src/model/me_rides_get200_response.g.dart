// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'me_rides_get200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MeRidesGet200Response extends MeRidesGet200Response {
  @override
  final int remainingRides;
  @override
  final int creditPesewas;

  factory _$MeRidesGet200Response(
          [void Function(MeRidesGet200ResponseBuilder)? updates]) =>
      (MeRidesGet200ResponseBuilder()..update(updates))._build();

  _$MeRidesGet200Response._(
      {required this.remainingRides, required this.creditPesewas})
      : super._();
  @override
  MeRidesGet200Response rebuild(
          void Function(MeRidesGet200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MeRidesGet200ResponseBuilder toBuilder() =>
      MeRidesGet200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MeRidesGet200Response &&
        remainingRides == other.remainingRides &&
        creditPesewas == other.creditPesewas;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, remainingRides.hashCode);
    _$hash = $jc(_$hash, creditPesewas.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MeRidesGet200Response')
          ..add('remainingRides', remainingRides)
          ..add('creditPesewas', creditPesewas))
        .toString();
  }
}

class MeRidesGet200ResponseBuilder
    implements Builder<MeRidesGet200Response, MeRidesGet200ResponseBuilder> {
  _$MeRidesGet200Response? _$v;

  int? _remainingRides;
  int? get remainingRides => _$this._remainingRides;
  set remainingRides(int? remainingRides) =>
      _$this._remainingRides = remainingRides;

  int? _creditPesewas;
  int? get creditPesewas => _$this._creditPesewas;
  set creditPesewas(int? creditPesewas) =>
      _$this._creditPesewas = creditPesewas;

  MeRidesGet200ResponseBuilder() {
    MeRidesGet200Response._defaults(this);
  }

  MeRidesGet200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _remainingRides = $v.remainingRides;
      _creditPesewas = $v.creditPesewas;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MeRidesGet200Response other) {
    _$v = other as _$MeRidesGet200Response;
  }

  @override
  void update(void Function(MeRidesGet200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MeRidesGet200Response build() => _build();

  _$MeRidesGet200Response _build() {
    final _$result = _$v ??
        _$MeRidesGet200Response._(
          remainingRides: BuiltValueNullFieldError.checkNotNull(
              remainingRides, r'MeRidesGet200Response', 'remainingRides'),
          creditPesewas: BuiltValueNullFieldError.checkNotNull(
              creditPesewas, r'MeRidesGet200Response', 'creditPesewas'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
