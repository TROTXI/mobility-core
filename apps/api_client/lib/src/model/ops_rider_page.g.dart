// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ops_rider_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OpsRiderPage extends OpsRiderPage {
  @override
  final BuiltList<OpsRider> data;
  @override
  final CommuteRequestPagePage page;

  factory _$OpsRiderPage([void Function(OpsRiderPageBuilder)? updates]) =>
      (OpsRiderPageBuilder()..update(updates))._build();

  _$OpsRiderPage._({required this.data, required this.page}) : super._();
  @override
  OpsRiderPage rebuild(void Function(OpsRiderPageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OpsRiderPageBuilder toBuilder() => OpsRiderPageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OpsRiderPage && data == other.data && page == other.page;
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
    return (newBuiltValueToStringHelper(r'OpsRiderPage')
          ..add('data', data)
          ..add('page', page))
        .toString();
  }
}

class OpsRiderPageBuilder
    implements Builder<OpsRiderPage, OpsRiderPageBuilder> {
  _$OpsRiderPage? _$v;

  ListBuilder<OpsRider>? _data;
  ListBuilder<OpsRider> get data => _$this._data ??= ListBuilder<OpsRider>();
  set data(ListBuilder<OpsRider>? data) => _$this._data = data;

  CommuteRequestPagePageBuilder? _page;
  CommuteRequestPagePageBuilder get page =>
      _$this._page ??= CommuteRequestPagePageBuilder();
  set page(CommuteRequestPagePageBuilder? page) => _$this._page = page;

  OpsRiderPageBuilder() {
    OpsRiderPage._defaults(this);
  }

  OpsRiderPageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _page = $v.page.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OpsRiderPage other) {
    _$v = other as _$OpsRiderPage;
  }

  @override
  void update(void Function(OpsRiderPageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OpsRiderPage build() => _build();

  _$OpsRiderPage _build() {
    _$OpsRiderPage _$result;
    try {
      _$result = _$v ??
          _$OpsRiderPage._(
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
            r'OpsRiderPage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
