// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ops_purchase_row_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OpsPurchaseRowPage extends OpsPurchaseRowPage {
  @override
  final BuiltList<OpsPurchaseRow> data;
  @override
  final CommuteRequestPagePage page;

  factory _$OpsPurchaseRowPage(
          [void Function(OpsPurchaseRowPageBuilder)? updates]) =>
      (OpsPurchaseRowPageBuilder()..update(updates))._build();

  _$OpsPurchaseRowPage._({required this.data, required this.page}) : super._();
  @override
  OpsPurchaseRowPage rebuild(
          void Function(OpsPurchaseRowPageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OpsPurchaseRowPageBuilder toBuilder() =>
      OpsPurchaseRowPageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OpsPurchaseRowPage &&
        data == other.data &&
        page == other.page;
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
    return (newBuiltValueToStringHelper(r'OpsPurchaseRowPage')
          ..add('data', data)
          ..add('page', page))
        .toString();
  }
}

class OpsPurchaseRowPageBuilder
    implements Builder<OpsPurchaseRowPage, OpsPurchaseRowPageBuilder> {
  _$OpsPurchaseRowPage? _$v;

  ListBuilder<OpsPurchaseRow>? _data;
  ListBuilder<OpsPurchaseRow> get data =>
      _$this._data ??= ListBuilder<OpsPurchaseRow>();
  set data(ListBuilder<OpsPurchaseRow>? data) => _$this._data = data;

  CommuteRequestPagePageBuilder? _page;
  CommuteRequestPagePageBuilder get page =>
      _$this._page ??= CommuteRequestPagePageBuilder();
  set page(CommuteRequestPagePageBuilder? page) => _$this._page = page;

  OpsPurchaseRowPageBuilder() {
    OpsPurchaseRowPage._defaults(this);
  }

  OpsPurchaseRowPageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _page = $v.page.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OpsPurchaseRowPage other) {
    _$v = other as _$OpsPurchaseRowPage;
  }

  @override
  void update(void Function(OpsPurchaseRowPageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OpsPurchaseRowPage build() => _build();

  _$OpsPurchaseRowPage _build() {
    _$OpsPurchaseRowPage _$result;
    try {
      _$result = _$v ??
          _$OpsPurchaseRowPage._(
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
            r'OpsPurchaseRowPage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
