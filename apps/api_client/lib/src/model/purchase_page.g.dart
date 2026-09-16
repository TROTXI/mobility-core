// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PurchasePage extends PurchasePage {
  @override
  final BuiltList<Purchase> data;
  @override
  final CommuteRequestPagePage page;

  factory _$PurchasePage([void Function(PurchasePageBuilder)? updates]) =>
      (PurchasePageBuilder()..update(updates))._build();

  _$PurchasePage._({required this.data, required this.page}) : super._();
  @override
  PurchasePage rebuild(void Function(PurchasePageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PurchasePageBuilder toBuilder() => PurchasePageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PurchasePage && data == other.data && page == other.page;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jc(_$hash, page.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PurchasePage')
          ..add('data', data)
          ..add('page', page))
        .toString();
  }
}

class PurchasePageBuilder
    implements Builder<PurchasePage, PurchasePageBuilder> {
  _$PurchasePage? _$v;

  ListBuilder<Purchase>? _data;
  ListBuilder<Purchase> get data => _$this._data ??= ListBuilder<Purchase>();
  set data(ListBuilder<Purchase>? data) => _$this._data = data;

  CommuteRequestPagePageBuilder? _page;
  CommuteRequestPagePageBuilder get page =>
      _$this._page ??= CommuteRequestPagePageBuilder();
  set page(CommuteRequestPagePageBuilder? page) => _$this._page = page;

  PurchasePageBuilder() {
    PurchasePage._defaults(this);
  }

  PurchasePageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _page = $v.page.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PurchasePage other) {
    _$v = other as _$PurchasePage;
  }

  @override
  void update(void Function(PurchasePageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PurchasePage build() => _build();

  _$PurchasePage _build() {
    _$PurchasePage _$result;
    try {
      _$result = _$v ??
          _$PurchasePage._(
            data: data.build(),
            page: page.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
        _$failedField = 'page';
        page.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PurchasePage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
