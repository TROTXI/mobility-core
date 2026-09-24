// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_entry_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RideEntryPage extends RideEntryPage {
  @override
  final BuiltList<RideEntry> data;
  @override
  final CommuteRequestPagePage page;

  factory _$RideEntryPage([void Function(RideEntryPageBuilder)? updates]) =>
      (RideEntryPageBuilder()..update(updates))._build();

  _$RideEntryPage._({required this.data, required this.page}) : super._();
  @override
  RideEntryPage rebuild(void Function(RideEntryPageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RideEntryPageBuilder toBuilder() => RideEntryPageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RideEntryPage && data == other.data && page == other.page;
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
    return (newBuiltValueToStringHelper(r'RideEntryPage')
          ..add('data', data)
          ..add('page', page))
        .toString();
  }
}

class RideEntryPageBuilder
    implements Builder<RideEntryPage, RideEntryPageBuilder> {
  _$RideEntryPage? _$v;

  ListBuilder<RideEntry>? _data;
  ListBuilder<RideEntry> get data => _$this._data ??= ListBuilder<RideEntry>();
  set data(ListBuilder<RideEntry>? data) => _$this._data = data;

  CommuteRequestPagePageBuilder? _page;
  CommuteRequestPagePageBuilder get page =>
      _$this._page ??= CommuteRequestPagePageBuilder();
  set page(CommuteRequestPagePageBuilder? page) => _$this._page = page;

  RideEntryPageBuilder() {
    RideEntryPage._defaults(this);
  }

  RideEntryPageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _page = $v.page.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RideEntryPage other) {
    _$v = other as _$RideEntryPage;
  }

  @override
  void update(void Function(RideEntryPageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RideEntryPage build() => _build();

  _$RideEntryPage _build() {
    _$RideEntryPage _$result;
    try {
      _$result = _$v ??
          _$RideEntryPage._(
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
            r'RideEntryPage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
