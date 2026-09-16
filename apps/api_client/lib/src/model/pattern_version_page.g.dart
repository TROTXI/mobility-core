// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pattern_version_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PatternVersionPage extends PatternVersionPage {
  @override
  final BuiltList<PatternVersion> data;
  @override
  final CommuteRequestPagePage page;

  factory _$PatternVersionPage(
          [void Function(PatternVersionPageBuilder)? updates]) =>
      (PatternVersionPageBuilder()..update(updates))._build();

  _$PatternVersionPage._({required this.data, required this.page}) : super._();
  @override
  PatternVersionPage rebuild(
          void Function(PatternVersionPageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PatternVersionPageBuilder toBuilder() =>
      PatternVersionPageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PatternVersionPage &&
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
    return (newBuiltValueToStringHelper(r'PatternVersionPage')
          ..add('data', data)
          ..add('page', page))
        .toString();
  }
}

class PatternVersionPageBuilder
    implements Builder<PatternVersionPage, PatternVersionPageBuilder> {
  _$PatternVersionPage? _$v;

  ListBuilder<PatternVersion>? _data;
  ListBuilder<PatternVersion> get data =>
      _$this._data ??= ListBuilder<PatternVersion>();
  set data(ListBuilder<PatternVersion>? data) => _$this._data = data;

  CommuteRequestPagePageBuilder? _page;
  CommuteRequestPagePageBuilder get page =>
      _$this._page ??= CommuteRequestPagePageBuilder();
  set page(CommuteRequestPagePageBuilder? page) => _$this._page = page;

  PatternVersionPageBuilder() {
    PatternVersionPage._defaults(this);
  }

  PatternVersionPageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _page = $v.page.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PatternVersionPage other) {
    _$v = other as _$PatternVersionPage;
  }

  @override
  void update(void Function(PatternVersionPageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PatternVersionPage build() => _build();

  _$PatternVersionPage _build() {
    _$PatternVersionPage _$result;
    try {
      _$result = _$v ??
          _$PatternVersionPage._(
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
            r'PatternVersionPage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
