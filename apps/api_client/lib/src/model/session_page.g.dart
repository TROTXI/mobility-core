// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SessionPage extends SessionPage {
  @override
  final BuiltList<Session> data;
  @override
  final CommuteRequestPagePage page;

  factory _$SessionPage([void Function(SessionPageBuilder)? updates]) =>
      (SessionPageBuilder()..update(updates))._build();

  _$SessionPage._({required this.data, required this.page}) : super._();
  @override
  SessionPage rebuild(void Function(SessionPageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SessionPageBuilder toBuilder() => SessionPageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SessionPage && data == other.data && page == other.page;
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
    return (newBuiltValueToStringHelper(r'SessionPage')
          ..add('data', data)
          ..add('page', page))
        .toString();
  }
}

class SessionPageBuilder implements Builder<SessionPage, SessionPageBuilder> {
  _$SessionPage? _$v;

  ListBuilder<Session>? _data;
  ListBuilder<Session> get data => _$this._data ??= ListBuilder<Session>();
  set data(ListBuilder<Session>? data) => _$this._data = data;

  CommuteRequestPagePageBuilder? _page;
  CommuteRequestPagePageBuilder get page =>
      _$this._page ??= CommuteRequestPagePageBuilder();
  set page(CommuteRequestPagePageBuilder? page) => _$this._page = page;

  SessionPageBuilder() {
    SessionPage._defaults(this);
  }

  SessionPageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _page = $v.page.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SessionPage other) {
    _$v = other as _$SessionPage;
  }

  @override
  void update(void Function(SessionPageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SessionPage build() => _build();

  _$SessionPage _build() {
    _$SessionPage _$result;
    try {
      _$result = _$v ??
          _$SessionPage._(
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
            r'SessionPage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
