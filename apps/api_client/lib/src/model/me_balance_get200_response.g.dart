// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'me_balance_get200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MeBalanceGet200Response extends MeBalanceGet200Response {
  @override
  final int balancePesewas;

  factory _$MeBalanceGet200Response(
          [void Function(MeBalanceGet200ResponseBuilder)? updates]) =>
      (MeBalanceGet200ResponseBuilder()..update(updates))._build();

  _$MeBalanceGet200Response._({required this.balancePesewas}) : super._();
  @override
  MeBalanceGet200Response rebuild(
          void Function(MeBalanceGet200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MeBalanceGet200ResponseBuilder toBuilder() =>
      MeBalanceGet200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MeBalanceGet200Response &&
        balancePesewas == other.balancePesewas;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, balancePesewas.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MeBalanceGet200Response')
          ..add('balancePesewas', balancePesewas))
        .toString();
  }
}

class MeBalanceGet200ResponseBuilder
    implements
        Builder<MeBalanceGet200Response, MeBalanceGet200ResponseBuilder> {
  _$MeBalanceGet200Response? _$v;

  int? _balancePesewas;
  int? get balancePesewas => _$this._balancePesewas;
  set balancePesewas(int? balancePesewas) =>
      _$this._balancePesewas = balancePesewas;

  MeBalanceGet200ResponseBuilder() {
    MeBalanceGet200Response._defaults(this);
  }

  MeBalanceGet200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _balancePesewas = $v.balancePesewas;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MeBalanceGet200Response other) {
    _$v = other as _$MeBalanceGet200Response;
  }

  @override
  void update(void Function(MeBalanceGet200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MeBalanceGet200Response build() => _build();

  _$MeBalanceGet200Response _build() {
    final _$result = _$v ??
        _$MeBalanceGet200Response._(
          balancePesewas: BuiltValueNullFieldError.checkNotNull(
              balancePesewas, r'MeBalanceGet200Response', 'balancePesewas'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
