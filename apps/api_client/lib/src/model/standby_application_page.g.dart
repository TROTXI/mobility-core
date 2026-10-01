// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'standby_application_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$StandbyApplicationPage extends StandbyApplicationPage {
  @override
  final BuiltList<StandbyApplication> data;
  @override
  final CommuteRequestPagePage page;

  factory _$StandbyApplicationPage(
          [void Function(StandbyApplicationPageBuilder)? updates]) =>
      (StandbyApplicationPageBuilder()..update(updates))._build();

  _$StandbyApplicationPage._({required this.data, required this.page})
      : super._();
  @override
  StandbyApplicationPage rebuild(
          void Function(StandbyApplicationPageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  StandbyApplicationPageBuilder toBuilder() =>
      StandbyApplicationPageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is StandbyApplicationPage &&
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
    return (newBuiltValueToStringHelper(r'StandbyApplicationPage')
          ..add('data', data)
          ..add('page', page))
        .toString();
  }
}

class StandbyApplicationPageBuilder
    implements Builder<StandbyApplicationPage, StandbyApplicationPageBuilder> {
  _$StandbyApplicationPage? _$v;

  ListBuilder<StandbyApplication>? _data;
  ListBuilder<StandbyApplication> get data =>
      _$this._data ??= ListBuilder<StandbyApplication>();
  set data(ListBuilder<StandbyApplication>? data) => _$this._data = data;

  CommuteRequestPagePageBuilder? _page;
  CommuteRequestPagePageBuilder get page =>
      _$this._page ??= CommuteRequestPagePageBuilder();
  set page(CommuteRequestPagePageBuilder? page) => _$this._page = page;

  StandbyApplicationPageBuilder() {
    StandbyApplicationPage._defaults(this);
  }

  StandbyApplicationPageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _page = $v.page.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(StandbyApplicationPage other) {
    _$v = other as _$StandbyApplicationPage;
  }

  @override
  void update(void Function(StandbyApplicationPageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  StandbyApplicationPage build() => _build();

  _$StandbyApplicationPage _build() {
    _$StandbyApplicationPage _$result;
    try {
      _$result = _$v ??
          _$StandbyApplicationPage._(
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
            r'StandbyApplicationPage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
