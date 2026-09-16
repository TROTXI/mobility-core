// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stop_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$StopPage extends StopPage {
  @override
  final BuiltList<Stop> data;
  @override
  final CommuteRequestPagePage page;

  factory _$StopPage([void Function(StopPageBuilder)? updates]) =>
      (StopPageBuilder()..update(updates))._build();

  _$StopPage._({required this.data, required this.page}) : super._();
  @override
  StopPage rebuild(void Function(StopPageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  StopPageBuilder toBuilder() => StopPageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is StopPage && data == other.data && page == other.page;
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
    return (newBuiltValueToStringHelper(r'StopPage')
          ..add('data', data)
          ..add('page', page))
        .toString();
  }
}

class StopPageBuilder implements Builder<StopPage, StopPageBuilder> {
  _$StopPage? _$v;

  ListBuilder<Stop>? _data;
  ListBuilder<Stop> get data => _$this._data ??= ListBuilder<Stop>();
  set data(ListBuilder<Stop>? data) => _$this._data = data;

  CommuteRequestPagePageBuilder? _page;
  CommuteRequestPagePageBuilder get page =>
      _$this._page ??= CommuteRequestPagePageBuilder();
  set page(CommuteRequestPagePageBuilder? page) => _$this._page = page;

  StopPageBuilder() {
    StopPage._defaults(this);
  }

  StopPageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _page = $v.page.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(StopPage other) {
    _$v = other as _$StopPage;
  }

  @override
  void update(void Function(StopPageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  StopPage build() => _build();

  _$StopPage _build() {
    _$StopPage _$result;
    try {
      _$result = _$v ??
          _$StopPage._(
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
            r'StopPage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
