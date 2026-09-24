// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ops_commute_request_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OpsCommuteRequestPage extends OpsCommuteRequestPage {
  @override
  final BuiltList<OpsCommuteRequest> data;
  @override
  final CommuteRequestPagePage page;

  factory _$OpsCommuteRequestPage(
          [void Function(OpsCommuteRequestPageBuilder)? updates]) =>
      (OpsCommuteRequestPageBuilder()..update(updates))._build();

  _$OpsCommuteRequestPage._({required this.data, required this.page})
      : super._();
  @override
  OpsCommuteRequestPage rebuild(
          void Function(OpsCommuteRequestPageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OpsCommuteRequestPageBuilder toBuilder() =>
      OpsCommuteRequestPageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OpsCommuteRequestPage &&
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
    return (newBuiltValueToStringHelper(r'OpsCommuteRequestPage')
          ..add('data', data)
          ..add('page', page))
        .toString();
  }
}

class OpsCommuteRequestPageBuilder
    implements Builder<OpsCommuteRequestPage, OpsCommuteRequestPageBuilder> {
  _$OpsCommuteRequestPage? _$v;

  ListBuilder<OpsCommuteRequest>? _data;
  ListBuilder<OpsCommuteRequest> get data =>
      _$this._data ??= ListBuilder<OpsCommuteRequest>();
  set data(ListBuilder<OpsCommuteRequest>? data) => _$this._data = data;

  CommuteRequestPagePageBuilder? _page;
  CommuteRequestPagePageBuilder get page =>
      _$this._page ??= CommuteRequestPagePageBuilder();
  set page(CommuteRequestPagePageBuilder? page) => _$this._page = page;

  OpsCommuteRequestPageBuilder() {
    OpsCommuteRequestPage._defaults(this);
  }

  OpsCommuteRequestPageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _page = $v.page.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OpsCommuteRequestPage other) {
    _$v = other as _$OpsCommuteRequestPage;
  }

  @override
  void update(void Function(OpsCommuteRequestPageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OpsCommuteRequestPage build() => _build();

  _$OpsCommuteRequestPage _build() {
    _$OpsCommuteRequestPage _$result;
    try {
      _$result = _$v ??
          _$OpsCommuteRequestPage._(
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
            r'OpsCommuteRequestPage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
