// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DriverPage extends DriverPage {
  @override
  final BuiltList<Driver> data;
  @override
  final CommuteRequestPagePage page;

  factory _$DriverPage([void Function(DriverPageBuilder)? updates]) =>
      (DriverPageBuilder()..update(updates))._build();

  _$DriverPage._({required this.data, required this.page}) : super._();
  @override
  DriverPage rebuild(void Function(DriverPageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DriverPageBuilder toBuilder() => DriverPageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DriverPage && data == other.data && page == other.page;
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
    return (newBuiltValueToStringHelper(r'DriverPage')
          ..add('data', data)
          ..add('page', page))
        .toString();
  }
}

class DriverPageBuilder implements Builder<DriverPage, DriverPageBuilder> {
  _$DriverPage? _$v;

  ListBuilder<Driver>? _data;
  ListBuilder<Driver> get data => _$this._data ??= ListBuilder<Driver>();
  set data(ListBuilder<Driver>? data) => _$this._data = data;

  CommuteRequestPagePageBuilder? _page;
  CommuteRequestPagePageBuilder get page =>
      _$this._page ??= CommuteRequestPagePageBuilder();
  set page(CommuteRequestPagePageBuilder? page) => _$this._page = page;

  DriverPageBuilder() {
    DriverPage._defaults(this);
  }

  DriverPageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _page = $v.page.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DriverPage other) {
    _$v = other as _$DriverPage;
  }

  @override
  void update(void Function(DriverPageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DriverPage build() => _build();

  _$DriverPage _build() {
    _$DriverPage _$result;
    try {
      _$result = _$v ??
          _$DriverPage._(
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
            r'DriverPage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
