// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flag_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$FlagPage extends FlagPage {
  @override
  final BuiltList<Flag> data;
  @override
  final CommuteRequestPagePage page;

  factory _$FlagPage([void Function(FlagPageBuilder)? updates]) =>
      (FlagPageBuilder()..update(updates))._build();

  _$FlagPage._({required this.data, required this.page}) : super._();
  @override
  FlagPage rebuild(void Function(FlagPageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FlagPageBuilder toBuilder() => FlagPageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FlagPage && data == other.data && page == other.page;
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
    return (newBuiltValueToStringHelper(r'FlagPage')
          ..add('data', data)
          ..add('page', page))
        .toString();
  }
}

class FlagPageBuilder implements Builder<FlagPage, FlagPageBuilder> {
  _$FlagPage? _$v;

  ListBuilder<Flag>? _data;
  ListBuilder<Flag> get data => _$this._data ??= ListBuilder<Flag>();
  set data(ListBuilder<Flag>? data) => _$this._data = data;

  CommuteRequestPagePageBuilder? _page;
  CommuteRequestPagePageBuilder get page =>
      _$this._page ??= CommuteRequestPagePageBuilder();
  set page(CommuteRequestPagePageBuilder? page) => _$this._page = page;

  FlagPageBuilder() {
    FlagPage._defaults(this);
  }

  FlagPageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _page = $v.page.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FlagPage other) {
    _$v = other as _$FlagPage;
  }

  @override
  void update(void Function(FlagPageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FlagPage build() => _build();

  _$FlagPage _build() {
    _$FlagPage _$result;
    try {
      _$result = _$v ??
          _$FlagPage._(
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
            r'FlagPage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
