// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ops_purchase_checkout.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OpsPurchaseCheckout extends OpsPurchaseCheckout {
  @override
  final String url;
  @override
  final DateTime? expiresAt;

  factory _$OpsPurchaseCheckout(
          [void Function(OpsPurchaseCheckoutBuilder)? updates]) =>
      (OpsPurchaseCheckoutBuilder()..update(updates))._build();

  _$OpsPurchaseCheckout._({required this.url, this.expiresAt}) : super._();
  @override
  OpsPurchaseCheckout rebuild(
          void Function(OpsPurchaseCheckoutBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OpsPurchaseCheckoutBuilder toBuilder() =>
      OpsPurchaseCheckoutBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OpsPurchaseCheckout &&
        url == other.url &&
        expiresAt == other.expiresAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, url.hashCode);
    _$hash = $jc(_$hash, expiresAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OpsPurchaseCheckout')
          ..add('url', url)
          ..add('expiresAt', expiresAt))
        .toString();
  }
}

class OpsPurchaseCheckoutBuilder
    implements Builder<OpsPurchaseCheckout, OpsPurchaseCheckoutBuilder> {
  _$OpsPurchaseCheckout? _$v;

  String? _url;
  String? get url => _$this._url;
  set url(String? url) => _$this._url = url;

  DateTime? _expiresAt;
  DateTime? get expiresAt => _$this._expiresAt;
  set expiresAt(DateTime? expiresAt) => _$this._expiresAt = expiresAt;

  OpsPurchaseCheckoutBuilder() {
    OpsPurchaseCheckout._defaults(this);
  }

  OpsPurchaseCheckoutBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _url = $v.url;
      _expiresAt = $v.expiresAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OpsPurchaseCheckout other) {
    _$v = other as _$OpsPurchaseCheckout;
  }

  @override
  void update(void Function(OpsPurchaseCheckoutBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OpsPurchaseCheckout build() => _build();

  _$OpsPurchaseCheckout _build() {
    final _$result = _$v ??
        _$OpsPurchaseCheckout._(
          url: BuiltValueNullFieldError.checkNotNull(
              url, r'OpsPurchaseCheckout', 'url'),
          expiresAt: expiresAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
