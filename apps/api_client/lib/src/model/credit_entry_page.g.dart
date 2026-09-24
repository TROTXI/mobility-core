// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credit_entry_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CreditEntryPage extends CreditEntryPage {
  @override
  final BuiltList<CreditEntry> data;
  @override
  final CommuteRequestPagePage page;

  factory _$CreditEntryPage([void Function(CreditEntryPageBuilder)? updates]) =>
      (CreditEntryPageBuilder()..update(updates))._build();

  _$CreditEntryPage._({required this.data, required this.page}) : super._();
  @override
  CreditEntryPage rebuild(void Function(CreditEntryPageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreditEntryPageBuilder toBuilder() => CreditEntryPageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreditEntryPage && data == other.data && page == other.page;
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
    return (newBuiltValueToStringHelper(r'CreditEntryPage')
          ..add('data', data)
          ..add('page', page))
        .toString();
  }
}

class CreditEntryPageBuilder
    implements Builder<CreditEntryPage, CreditEntryPageBuilder> {
  _$CreditEntryPage? _$v;

  ListBuilder<CreditEntry>? _data;
  ListBuilder<CreditEntry> get data =>
      _$this._data ??= ListBuilder<CreditEntry>();
  set data(ListBuilder<CreditEntry>? data) => _$this._data = data;

  CommuteRequestPagePageBuilder? _page;
  CommuteRequestPagePageBuilder get page =>
      _$this._page ??= CommuteRequestPagePageBuilder();
  set page(CommuteRequestPagePageBuilder? page) => _$this._page = page;

  CreditEntryPageBuilder() {
    CreditEntryPage._defaults(this);
  }

  CreditEntryPageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _page = $v.page.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreditEntryPage other) {
    _$v = other as _$CreditEntryPage;
  }

  @override
  void update(void Function(CreditEntryPageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreditEntryPage build() => _build();

  _$CreditEntryPage _build() {
    _$CreditEntryPage _$result;
    try {
      _$result = _$v ??
          _$CreditEntryPage._(
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
            r'CreditEntryPage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
