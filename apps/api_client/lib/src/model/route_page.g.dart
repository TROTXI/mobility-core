// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RoutePage extends RoutePage {
  @override
  final BuiltList<Route> data;
  @override
  final CommuteRequestPagePage page;

  factory _$RoutePage([void Function(RoutePageBuilder)? updates]) =>
      (RoutePageBuilder()..update(updates))._build();

  _$RoutePage._({required this.data, required this.page}) : super._();
  @override
  RoutePage rebuild(void Function(RoutePageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RoutePageBuilder toBuilder() => RoutePageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RoutePage && data == other.data && page == other.page;
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
    return (newBuiltValueToStringHelper(r'RoutePage')
          ..add('data', data)
          ..add('page', page))
        .toString();
  }
}

class RoutePageBuilder implements Builder<RoutePage, RoutePageBuilder> {
  _$RoutePage? _$v;

  ListBuilder<Route>? _data;
  ListBuilder<Route> get data => _$this._data ??= ListBuilder<Route>();
  set data(ListBuilder<Route>? data) => _$this._data = data;

  CommuteRequestPagePageBuilder? _page;
  CommuteRequestPagePageBuilder get page =>
      _$this._page ??= CommuteRequestPagePageBuilder();
  set page(CommuteRequestPagePageBuilder? page) => _$this._page = page;

  RoutePageBuilder() {
    RoutePage._defaults(this);
  }

  RoutePageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _page = $v.page.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RoutePage other) {
    _$v = other as _$RoutePage;
  }

  @override
  void update(void Function(RoutePageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RoutePage build() => _build();

  _$RoutePage _build() {
    _$RoutePage _$result;
    try {
      _$result = _$v ??
          _$RoutePage._(
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
            r'RoutePage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
