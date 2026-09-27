// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ops_delivery_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OpsDeliveryPage extends OpsDeliveryPage {
  @override
  final BuiltList<OpsDelivery> data;
  @override
  final CommuteRequestPagePage page;

  factory _$OpsDeliveryPage([void Function(OpsDeliveryPageBuilder)? updates]) =>
      (OpsDeliveryPageBuilder()..update(updates))._build();

  _$OpsDeliveryPage._({required this.data, required this.page}) : super._();
  @override
  OpsDeliveryPage rebuild(void Function(OpsDeliveryPageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OpsDeliveryPageBuilder toBuilder() => OpsDeliveryPageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OpsDeliveryPage && data == other.data && page == other.page;
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
    return (newBuiltValueToStringHelper(r'OpsDeliveryPage')
          ..add('data', data)
          ..add('page', page))
        .toString();
  }
}

class OpsDeliveryPageBuilder
    implements Builder<OpsDeliveryPage, OpsDeliveryPageBuilder> {
  _$OpsDeliveryPage? _$v;

  ListBuilder<OpsDelivery>? _data;
  ListBuilder<OpsDelivery> get data =>
      _$this._data ??= ListBuilder<OpsDelivery>();
  set data(ListBuilder<OpsDelivery>? data) => _$this._data = data;

  CommuteRequestPagePageBuilder? _page;
  CommuteRequestPagePageBuilder get page =>
      _$this._page ??= CommuteRequestPagePageBuilder();
  set page(CommuteRequestPagePageBuilder? page) => _$this._page = page;

  OpsDeliveryPageBuilder() {
    OpsDeliveryPage._defaults(this);
  }

  OpsDeliveryPageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _page = $v.page.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OpsDeliveryPage other) {
    _$v = other as _$OpsDeliveryPage;
  }

  @override
  void update(void Function(OpsDeliveryPageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OpsDeliveryPage build() => _build();

  _$OpsDeliveryPage _build() {
    _$OpsDeliveryPage _$result;
    try {
      _$result = _$v ??
          _$OpsDeliveryPage._(
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
            r'OpsDeliveryPage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
