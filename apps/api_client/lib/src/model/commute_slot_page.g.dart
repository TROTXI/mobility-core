// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commute_slot_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CommuteSlotPage extends CommuteSlotPage {
  @override
  final BuiltList<CommuteSlot> data;
  @override
  final CommuteRequestPagePage page;

  factory _$CommuteSlotPage([void Function(CommuteSlotPageBuilder)? updates]) =>
      (CommuteSlotPageBuilder()..update(updates))._build();

  _$CommuteSlotPage._({required this.data, required this.page}) : super._();
  @override
  CommuteSlotPage rebuild(void Function(CommuteSlotPageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CommuteSlotPageBuilder toBuilder() => CommuteSlotPageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CommuteSlotPage && data == other.data && page == other.page;
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
    return (newBuiltValueToStringHelper(r'CommuteSlotPage')
          ..add('data', data)
          ..add('page', page))
        .toString();
  }
}

class CommuteSlotPageBuilder
    implements Builder<CommuteSlotPage, CommuteSlotPageBuilder> {
  _$CommuteSlotPage? _$v;

  ListBuilder<CommuteSlot>? _data;
  ListBuilder<CommuteSlot> get data =>
      _$this._data ??= ListBuilder<CommuteSlot>();
  set data(ListBuilder<CommuteSlot>? data) => _$this._data = data;

  CommuteRequestPagePageBuilder? _page;
  CommuteRequestPagePageBuilder get page =>
      _$this._page ??= CommuteRequestPagePageBuilder();
  set page(CommuteRequestPagePageBuilder? page) => _$this._page = page;

  CommuteSlotPageBuilder() {
    CommuteSlotPage._defaults(this);
  }

  CommuteSlotPageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _page = $v.page.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CommuteSlotPage other) {
    _$v = other as _$CommuteSlotPage;
  }

  @override
  void update(void Function(CommuteSlotPageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CommuteSlotPage build() => _build();

  _$CommuteSlotPage _build() {
    _$CommuteSlotPage _$result;
    try {
      _$result = _$v ??
          _$CommuteSlotPage._(
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
            r'CommuteSlotPage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
