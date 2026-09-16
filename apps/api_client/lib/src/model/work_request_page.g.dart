// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_request_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$WorkRequestPage extends WorkRequestPage {
  @override
  final BuiltList<WorkRequest> data;
  @override
  final CommuteRequestPagePage page;

  factory _$WorkRequestPage([void Function(WorkRequestPageBuilder)? updates]) =>
      (WorkRequestPageBuilder()..update(updates))._build();

  _$WorkRequestPage._({required this.data, required this.page}) : super._();
  @override
  WorkRequestPage rebuild(void Function(WorkRequestPageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  WorkRequestPageBuilder toBuilder() => WorkRequestPageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WorkRequestPage && data == other.data && page == other.page;
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
    return (newBuiltValueToStringHelper(r'WorkRequestPage')
          ..add('data', data)
          ..add('page', page))
        .toString();
  }
}

class WorkRequestPageBuilder
    implements Builder<WorkRequestPage, WorkRequestPageBuilder> {
  _$WorkRequestPage? _$v;

  ListBuilder<WorkRequest>? _data;
  ListBuilder<WorkRequest> get data =>
      _$this._data ??= ListBuilder<WorkRequest>();
  set data(ListBuilder<WorkRequest>? data) => _$this._data = data;

  CommuteRequestPagePageBuilder? _page;
  CommuteRequestPagePageBuilder get page =>
      _$this._page ??= CommuteRequestPagePageBuilder();
  set page(CommuteRequestPagePageBuilder? page) => _$this._page = page;

  WorkRequestPageBuilder() {
    WorkRequestPage._defaults(this);
  }

  WorkRequestPageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _page = $v.page.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WorkRequestPage other) {
    _$v = other as _$WorkRequestPage;
  }

  @override
  void update(void Function(WorkRequestPageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WorkRequestPage build() => _build();

  _$WorkRequestPage _build() {
    _$WorkRequestPage _$result;
    try {
      _$result = _$v ??
          _$WorkRequestPage._(
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
            r'WorkRequestPage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
