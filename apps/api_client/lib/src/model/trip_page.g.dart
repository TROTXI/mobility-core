// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TripPage extends TripPage {
  @override
  final BuiltList<Trip> data;
  @override
  final CommuteRequestPagePage page;

  factory _$TripPage([void Function(TripPageBuilder)? updates]) =>
      (TripPageBuilder()..update(updates))._build();

  _$TripPage._({required this.data, required this.page}) : super._();
  @override
  TripPage rebuild(void Function(TripPageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TripPageBuilder toBuilder() => TripPageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TripPage && data == other.data && page == other.page;
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
    return (newBuiltValueToStringHelper(r'TripPage')
          ..add('data', data)
          ..add('page', page))
        .toString();
  }
}

class TripPageBuilder implements Builder<TripPage, TripPageBuilder> {
  _$TripPage? _$v;

  ListBuilder<Trip>? _data;
  ListBuilder<Trip> get data => _$this._data ??= ListBuilder<Trip>();
  set data(ListBuilder<Trip>? data) => _$this._data = data;

  CommuteRequestPagePageBuilder? _page;
  CommuteRequestPagePageBuilder get page =>
      _$this._page ??= CommuteRequestPagePageBuilder();
  set page(CommuteRequestPagePageBuilder? page) => _$this._page = page;

  TripPageBuilder() {
    TripPage._defaults(this);
  }

  TripPageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _page = $v.page.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TripPage other) {
    _$v = other as _$TripPage;
  }

  @override
  void update(void Function(TripPageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TripPage build() => _build();

  _$TripPage _build() {
    _$TripPage _$result;
    try {
      _$result = _$v ??
          _$TripPage._(
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
            r'TripPage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
