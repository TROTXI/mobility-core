// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'decision_event_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DecisionEventPage extends DecisionEventPage {
  @override
  final BuiltList<DecisionEvent> data;
  @override
  final CommuteRequestPagePage page;

  factory _$DecisionEventPage(
          [void Function(DecisionEventPageBuilder)? updates]) =>
      (DecisionEventPageBuilder()..update(updates))._build();

  _$DecisionEventPage._({required this.data, required this.page}) : super._();
  @override
  DecisionEventPage rebuild(void Function(DecisionEventPageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DecisionEventPageBuilder toBuilder() =>
      DecisionEventPageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DecisionEventPage &&
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
    return (newBuiltValueToStringHelper(r'DecisionEventPage')
          ..add('data', data)
          ..add('page', page))
        .toString();
  }
}

class DecisionEventPageBuilder
    implements Builder<DecisionEventPage, DecisionEventPageBuilder> {
  _$DecisionEventPage? _$v;

  ListBuilder<DecisionEvent>? _data;
  ListBuilder<DecisionEvent> get data =>
      _$this._data ??= ListBuilder<DecisionEvent>();
  set data(ListBuilder<DecisionEvent>? data) => _$this._data = data;

  CommuteRequestPagePageBuilder? _page;
  CommuteRequestPagePageBuilder get page =>
      _$this._page ??= CommuteRequestPagePageBuilder();
  set page(CommuteRequestPagePageBuilder? page) => _$this._page = page;

  DecisionEventPageBuilder() {
    DecisionEventPage._defaults(this);
  }

  DecisionEventPageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _page = $v.page.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DecisionEventPage other) {
    _$v = other as _$DecisionEventPage;
  }

  @override
  void update(void Function(DecisionEventPageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DecisionEventPage build() => _build();

  _$DecisionEventPage _build() {
    _$DecisionEventPage _$result;
    try {
      _$result = _$v ??
          _$DecisionEventPage._(
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
            r'DecisionEventPage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
