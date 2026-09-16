// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_trip_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DriverTripPage extends DriverTripPage {
  @override
  final BuiltList<DriverTrip> data;
  @override
  final CommuteRequestPagePage page;

  factory _$DriverTripPage([void Function(DriverTripPageBuilder)? updates]) =>
      (DriverTripPageBuilder()..update(updates))._build();

  _$DriverTripPage._({required this.data, required this.page}) : super._();
  @override
  DriverTripPage rebuild(void Function(DriverTripPageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DriverTripPageBuilder toBuilder() => DriverTripPageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DriverTripPage && data == other.data && page == other.page;
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
    return (newBuiltValueToStringHelper(r'DriverTripPage')
          ..add('data', data)
          ..add('page', page))
        .toString();
  }
}

class DriverTripPageBuilder
    implements Builder<DriverTripPage, DriverTripPageBuilder> {
  _$DriverTripPage? _$v;

  ListBuilder<DriverTrip>? _data;
  ListBuilder<DriverTrip> get data =>
      _$this._data ??= ListBuilder<DriverTrip>();
  set data(ListBuilder<DriverTrip>? data) => _$this._data = data;

  CommuteRequestPagePageBuilder? _page;
  CommuteRequestPagePageBuilder get page =>
      _$this._page ??= CommuteRequestPagePageBuilder();
  set page(CommuteRequestPagePageBuilder? page) => _$this._page = page;

  DriverTripPageBuilder() {
    DriverTripPage._defaults(this);
  }

  DriverTripPageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _page = $v.page.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DriverTripPage other) {
    _$v = other as _$DriverTripPage;
  }

  @override
  void update(void Function(DriverTripPageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DriverTripPage build() => _build();

  _$DriverTripPage _build() {
    _$DriverTripPage _$result;
    try {
      _$result = _$v ??
          _$DriverTripPage._(
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
            r'DriverTripPage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
