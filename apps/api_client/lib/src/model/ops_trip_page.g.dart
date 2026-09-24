// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ops_trip_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OpsTripPage extends OpsTripPage {
  @override
  final BuiltList<OpsTrip> data;
  @override
  final CommuteRequestPagePage page;

  factory _$OpsTripPage([void Function(OpsTripPageBuilder)? updates]) =>
      (OpsTripPageBuilder()..update(updates))._build();

  _$OpsTripPage._({required this.data, required this.page}) : super._();
  @override
  OpsTripPage rebuild(void Function(OpsTripPageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OpsTripPageBuilder toBuilder() => OpsTripPageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OpsTripPage && data == other.data && page == other.page;
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
    return (newBuiltValueToStringHelper(r'OpsTripPage')
          ..add('data', data)
          ..add('page', page))
        .toString();
  }
}

class OpsTripPageBuilder implements Builder<OpsTripPage, OpsTripPageBuilder> {
  _$OpsTripPage? _$v;

  ListBuilder<OpsTrip>? _data;
  ListBuilder<OpsTrip> get data => _$this._data ??= ListBuilder<OpsTrip>();
  set data(ListBuilder<OpsTrip>? data) => _$this._data = data;

  CommuteRequestPagePageBuilder? _page;
  CommuteRequestPagePageBuilder get page =>
      _$this._page ??= CommuteRequestPagePageBuilder();
  set page(CommuteRequestPagePageBuilder? page) => _$this._page = page;

  OpsTripPageBuilder() {
    OpsTripPage._defaults(this);
  }

  OpsTripPageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _page = $v.page.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OpsTripPage other) {
    _$v = other as _$OpsTripPage;
  }

  @override
  void update(void Function(OpsTripPageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OpsTripPage build() => _build();

  _$OpsTripPage _build() {
    _$OpsTripPage _$result;
    try {
      _$result = _$v ??
          _$OpsTripPage._(
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
            r'OpsTripPage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
