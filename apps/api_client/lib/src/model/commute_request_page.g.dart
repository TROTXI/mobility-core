// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commute_request_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CommuteRequestPage extends CommuteRequestPage {
  @override
  final BuiltList<CommuteRequest> data;
  @override
  final CommuteRequestPagePage page;

  factory _$CommuteRequestPage(
          [void Function(CommuteRequestPageBuilder)? updates]) =>
      (CommuteRequestPageBuilder()..update(updates))._build();

  _$CommuteRequestPage._({required this.data, required this.page}) : super._();
  @override
  CommuteRequestPage rebuild(
          void Function(CommuteRequestPageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CommuteRequestPageBuilder toBuilder() =>
      CommuteRequestPageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CommuteRequestPage &&
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
    return (newBuiltValueToStringHelper(r'CommuteRequestPage')
          ..add('data', data)
          ..add('page', page))
        .toString();
  }
}

class CommuteRequestPageBuilder
    implements Builder<CommuteRequestPage, CommuteRequestPageBuilder> {
  _$CommuteRequestPage? _$v;

  ListBuilder<CommuteRequest>? _data;
  ListBuilder<CommuteRequest> get data =>
      _$this._data ??= ListBuilder<CommuteRequest>();
  set data(ListBuilder<CommuteRequest>? data) => _$this._data = data;

  CommuteRequestPagePageBuilder? _page;
  CommuteRequestPagePageBuilder get page =>
      _$this._page ??= CommuteRequestPagePageBuilder();
  set page(CommuteRequestPagePageBuilder? page) => _$this._page = page;

  CommuteRequestPageBuilder() {
    CommuteRequestPage._defaults(this);
  }

  CommuteRequestPageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _page = $v.page.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CommuteRequestPage other) {
    _$v = other as _$CommuteRequestPage;
  }

  @override
  void update(void Function(CommuteRequestPageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CommuteRequestPage build() => _build();

  _$CommuteRequestPage _build() {
    _$CommuteRequestPage _$result;
    try {
      _$result = _$v ??
          _$CommuteRequestPage._(
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
            r'CommuteRequestPage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
