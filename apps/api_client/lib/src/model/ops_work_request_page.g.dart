// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ops_work_request_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OpsWorkRequestPage extends OpsWorkRequestPage {
  @override
  final BuiltList<OpsWorkRequest> data;
  @override
  final CommuteRequestPagePage page;

  factory _$OpsWorkRequestPage(
          [void Function(OpsWorkRequestPageBuilder)? updates]) =>
      (OpsWorkRequestPageBuilder()..update(updates))._build();

  _$OpsWorkRequestPage._({required this.data, required this.page}) : super._();
  @override
  OpsWorkRequestPage rebuild(
          void Function(OpsWorkRequestPageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OpsWorkRequestPageBuilder toBuilder() =>
      OpsWorkRequestPageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OpsWorkRequestPage &&
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
    return (newBuiltValueToStringHelper(r'OpsWorkRequestPage')
          ..add('data', data)
          ..add('page', page))
        .toString();
  }
}

class OpsWorkRequestPageBuilder
    implements Builder<OpsWorkRequestPage, OpsWorkRequestPageBuilder> {
  _$OpsWorkRequestPage? _$v;

  ListBuilder<OpsWorkRequest>? _data;
  ListBuilder<OpsWorkRequest> get data =>
      _$this._data ??= ListBuilder<OpsWorkRequest>();
  set data(ListBuilder<OpsWorkRequest>? data) => _$this._data = data;

  CommuteRequestPagePageBuilder? _page;
  CommuteRequestPagePageBuilder get page =>
      _$this._page ??= CommuteRequestPagePageBuilder();
  set page(CommuteRequestPagePageBuilder? page) => _$this._page = page;

  OpsWorkRequestPageBuilder() {
    OpsWorkRequestPage._defaults(this);
  }

  OpsWorkRequestPageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _page = $v.page.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OpsWorkRequestPage other) {
    _$v = other as _$OpsWorkRequestPage;
  }

  @override
  void update(void Function(OpsWorkRequestPageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OpsWorkRequestPage build() => _build();

  _$OpsWorkRequestPage _build() {
    _$OpsWorkRequestPage _$result;
    try {
      _$result = _$v ??
          _$OpsWorkRequestPage._(
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
            r'OpsWorkRequestPage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
