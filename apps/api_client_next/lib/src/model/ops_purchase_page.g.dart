// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ops_purchase_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OpsPurchasePage extends OpsPurchasePage {
  @override
  final BuiltList<OpsPurchase> data;
  @override
  final CommuteRequestPagePage page;

  factory _$OpsPurchasePage([void Function(OpsPurchasePageBuilder)? updates]) =>
      (OpsPurchasePageBuilder()..update(updates))._build();

  _$OpsPurchasePage._({required this.data, required this.page}) : super._();
  @override
  OpsPurchasePage rebuild(void Function(OpsPurchasePageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OpsPurchasePageBuilder toBuilder() => OpsPurchasePageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OpsPurchasePage && data == other.data && page == other.page;
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
    return (newBuiltValueToStringHelper(r'OpsPurchasePage')
          ..add('data', data)
          ..add('page', page))
        .toString();
  }
}

class OpsPurchasePageBuilder
    implements Builder<OpsPurchasePage, OpsPurchasePageBuilder> {
  _$OpsPurchasePage? _$v;

  ListBuilder<OpsPurchase>? _data;
  ListBuilder<OpsPurchase> get data =>
      _$this._data ??= ListBuilder<OpsPurchase>();
  set data(ListBuilder<OpsPurchase>? data) => _$this._data = data;

  CommuteRequestPagePageBuilder? _page;
  CommuteRequestPagePageBuilder get page =>
      _$this._page ??= CommuteRequestPagePageBuilder();
  set page(CommuteRequestPagePageBuilder? page) => _$this._page = page;

  OpsPurchasePageBuilder() {
    OpsPurchasePage._defaults(this);
  }

  OpsPurchasePageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _page = $v.page.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OpsPurchasePage other) {
    _$v = other as _$OpsPurchasePage;
  }

  @override
  void update(void Function(OpsPurchasePageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OpsPurchasePage build() => _build();

  _$OpsPurchasePage _build() {
    _$OpsPurchasePage _$result;
    try {
      _$result = _$v ??
          _$OpsPurchasePage._(
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
            r'OpsPurchasePage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
