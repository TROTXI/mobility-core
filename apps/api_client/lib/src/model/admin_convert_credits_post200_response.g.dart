// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_convert_credits_post200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminConvertCreditsPost200Response
    extends AdminConvertCreditsPost200Response {
  @override
  final int riders;
  @override
  final int ridesConverted;
  @override
  final int creditPesewas;

  factory _$AdminConvertCreditsPost200Response(
          [void Function(AdminConvertCreditsPost200ResponseBuilder)?
              updates]) =>
      (AdminConvertCreditsPost200ResponseBuilder()..update(updates))._build();

  _$AdminConvertCreditsPost200Response._(
      {required this.riders,
      required this.ridesConverted,
      required this.creditPesewas})
      : super._();
  @override
  AdminConvertCreditsPost200Response rebuild(
          void Function(AdminConvertCreditsPost200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminConvertCreditsPost200ResponseBuilder toBuilder() =>
      AdminConvertCreditsPost200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminConvertCreditsPost200Response &&
        riders == other.riders &&
        ridesConverted == other.ridesConverted &&
        creditPesewas == other.creditPesewas;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, riders.hashCode);
    _$hash = $jc(_$hash, ridesConverted.hashCode);
    _$hash = $jc(_$hash, creditPesewas.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminConvertCreditsPost200Response')
          ..add('riders', riders)
          ..add('ridesConverted', ridesConverted)
          ..add('creditPesewas', creditPesewas))
        .toString();
  }
}

class AdminConvertCreditsPost200ResponseBuilder
    implements
        Builder<AdminConvertCreditsPost200Response,
            AdminConvertCreditsPost200ResponseBuilder> {
  _$AdminConvertCreditsPost200Response? _$v;

  int? _riders;
  int? get riders => _$this._riders;
  set riders(int? riders) => _$this._riders = riders;

  int? _ridesConverted;
  int? get ridesConverted => _$this._ridesConverted;
  set ridesConverted(int? ridesConverted) =>
      _$this._ridesConverted = ridesConverted;

  int? _creditPesewas;
  int? get creditPesewas => _$this._creditPesewas;
  set creditPesewas(int? creditPesewas) =>
      _$this._creditPesewas = creditPesewas;

  AdminConvertCreditsPost200ResponseBuilder() {
    AdminConvertCreditsPost200Response._defaults(this);
  }

  AdminConvertCreditsPost200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _riders = $v.riders;
      _ridesConverted = $v.ridesConverted;
      _creditPesewas = $v.creditPesewas;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminConvertCreditsPost200Response other) {
    _$v = other as _$AdminConvertCreditsPost200Response;
  }

  @override
  void update(
      void Function(AdminConvertCreditsPost200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminConvertCreditsPost200Response build() => _build();

  _$AdminConvertCreditsPost200Response _build() {
    final _$result = _$v ??
        _$AdminConvertCreditsPost200Response._(
          riders: BuiltValueNullFieldError.checkNotNull(
              riders, r'AdminConvertCreditsPost200Response', 'riders'),
          ridesConverted: BuiltValueNullFieldError.checkNotNull(ridesConverted,
              r'AdminConvertCreditsPost200Response', 'ridesConverted'),
          creditPesewas: BuiltValueNullFieldError.checkNotNull(creditPesewas,
              r'AdminConvertCreditsPost200Response', 'creditPesewas'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
