// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'minimum_version_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MinimumVersionPage extends MinimumVersionPage {
  @override
  final BuiltList<MinimumVersion> data;
  @override
  final CommuteRequestPagePage page;

  factory _$MinimumVersionPage(
          [void Function(MinimumVersionPageBuilder)? updates]) =>
      (MinimumVersionPageBuilder()..update(updates))._build();

  _$MinimumVersionPage._({required this.data, required this.page}) : super._();
  @override
  MinimumVersionPage rebuild(
          void Function(MinimumVersionPageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MinimumVersionPageBuilder toBuilder() =>
      MinimumVersionPageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MinimumVersionPage &&
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
    return (newBuiltValueToStringHelper(r'MinimumVersionPage')
          ..add('data', data)
          ..add('page', page))
        .toString();
  }
}

class MinimumVersionPageBuilder
    implements Builder<MinimumVersionPage, MinimumVersionPageBuilder> {
  _$MinimumVersionPage? _$v;

  ListBuilder<MinimumVersion>? _data;
  ListBuilder<MinimumVersion> get data =>
      _$this._data ??= ListBuilder<MinimumVersion>();
  set data(ListBuilder<MinimumVersion>? data) => _$this._data = data;

  CommuteRequestPagePageBuilder? _page;
  CommuteRequestPagePageBuilder get page =>
      _$this._page ??= CommuteRequestPagePageBuilder();
  set page(CommuteRequestPagePageBuilder? page) => _$this._page = page;

  MinimumVersionPageBuilder() {
    MinimumVersionPage._defaults(this);
  }

  MinimumVersionPageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _page = $v.page.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MinimumVersionPage other) {
    _$v = other as _$MinimumVersionPage;
  }

  @override
  void update(void Function(MinimumVersionPageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MinimumVersionPage build() => _build();

  _$MinimumVersionPage _build() {
    _$MinimumVersionPage _$result;
    try {
      _$result = _$v ??
          _$MinimumVersionPage._(
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
            r'MinimumVersionPage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
