// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trace_hold_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TraceHoldPage extends TraceHoldPage {
  @override
  final BuiltList<TraceHold> data;
  @override
  final CommuteRequestPagePage page;

  factory _$TraceHoldPage([void Function(TraceHoldPageBuilder)? updates]) =>
      (TraceHoldPageBuilder()..update(updates))._build();

  _$TraceHoldPage._({required this.data, required this.page}) : super._();
  @override
  TraceHoldPage rebuild(void Function(TraceHoldPageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TraceHoldPageBuilder toBuilder() => TraceHoldPageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TraceHoldPage && data == other.data && page == other.page;
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
    return (newBuiltValueToStringHelper(r'TraceHoldPage')
          ..add('data', data)
          ..add('page', page))
        .toString();
  }
}

class TraceHoldPageBuilder
    implements Builder<TraceHoldPage, TraceHoldPageBuilder> {
  _$TraceHoldPage? _$v;

  ListBuilder<TraceHold>? _data;
  ListBuilder<TraceHold> get data => _$this._data ??= ListBuilder<TraceHold>();
  set data(ListBuilder<TraceHold>? data) => _$this._data = data;

  CommuteRequestPagePageBuilder? _page;
  CommuteRequestPagePageBuilder get page =>
      _$this._page ??= CommuteRequestPagePageBuilder();
  set page(CommuteRequestPagePageBuilder? page) => _$this._page = page;

  TraceHoldPageBuilder() {
    TraceHoldPage._defaults(this);
  }

  TraceHoldPageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _page = $v.page.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TraceHoldPage other) {
    _$v = other as _$TraceHoldPage;
  }

  @override
  void update(void Function(TraceHoldPageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TraceHoldPage build() => _build();

  _$TraceHoldPage _build() {
    _$TraceHoldPage _$result;
    try {
      _$result = _$v ??
          _$TraceHoldPage._(
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
            r'TraceHoldPage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
