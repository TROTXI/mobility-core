// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$VehiclePage extends VehiclePage {
  @override
  final BuiltList<Vehicle> data;
  @override
  final CommuteRequestPagePage page;

  factory _$VehiclePage([void Function(VehiclePageBuilder)? updates]) =>
      (VehiclePageBuilder()..update(updates))._build();

  _$VehiclePage._({required this.data, required this.page}) : super._();
  @override
  VehiclePage rebuild(void Function(VehiclePageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  VehiclePageBuilder toBuilder() => VehiclePageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is VehiclePage && data == other.data && page == other.page;
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
    return (newBuiltValueToStringHelper(r'VehiclePage')
          ..add('data', data)
          ..add('page', page))
        .toString();
  }
}

class VehiclePageBuilder implements Builder<VehiclePage, VehiclePageBuilder> {
  _$VehiclePage? _$v;

  ListBuilder<Vehicle>? _data;
  ListBuilder<Vehicle> get data => _$this._data ??= ListBuilder<Vehicle>();
  set data(ListBuilder<Vehicle>? data) => _$this._data = data;

  CommuteRequestPagePageBuilder? _page;
  CommuteRequestPagePageBuilder get page =>
      _$this._page ??= CommuteRequestPagePageBuilder();
  set page(CommuteRequestPagePageBuilder? page) => _$this._page = page;

  VehiclePageBuilder() {
    VehiclePage._defaults(this);
  }

  VehiclePageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _page = $v.page.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(VehiclePage other) {
    _$v = other as _$VehiclePage;
  }

  @override
  void update(void Function(VehiclePageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  VehiclePage build() => _build();

  _$VehiclePage _build() {
    _$VehiclePage _$result;
    try {
      _$result = _$v ??
          _$VehiclePage._(
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
            r'VehiclePage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
