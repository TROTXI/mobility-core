// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SchedulePage extends SchedulePage {
  @override
  final BuiltList<Schedule> data;
  @override
  final CommuteRequestPagePage page;

  factory _$SchedulePage([void Function(SchedulePageBuilder)? updates]) =>
      (SchedulePageBuilder()..update(updates))._build();

  _$SchedulePage._({required this.data, required this.page}) : super._();
  @override
  SchedulePage rebuild(void Function(SchedulePageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SchedulePageBuilder toBuilder() => SchedulePageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SchedulePage && data == other.data && page == other.page;
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
    return (newBuiltValueToStringHelper(r'SchedulePage')
          ..add('data', data)
          ..add('page', page))
        .toString();
  }
}

class SchedulePageBuilder
    implements Builder<SchedulePage, SchedulePageBuilder> {
  _$SchedulePage? _$v;

  ListBuilder<Schedule>? _data;
  ListBuilder<Schedule> get data => _$this._data ??= ListBuilder<Schedule>();
  set data(ListBuilder<Schedule>? data) => _$this._data = data;

  CommuteRequestPagePageBuilder? _page;
  CommuteRequestPagePageBuilder get page =>
      _$this._page ??= CommuteRequestPagePageBuilder();
  set page(CommuteRequestPagePageBuilder? page) => _$this._page = page;

  SchedulePageBuilder() {
    SchedulePage._defaults(this);
  }

  SchedulePageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _page = $v.page.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SchedulePage other) {
    _$v = other as _$SchedulePage;
  }

  @override
  void update(void Function(SchedulePageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SchedulePage build() => _build();

  _$SchedulePage _build() {
    _$SchedulePage _$result;
    try {
      _$result = _$v ??
          _$SchedulePage._(
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
            r'SchedulePage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
