// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pattern_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PatternPage extends PatternPage {
  @override
  final BuiltList<Pattern> data;
  @override
  final CommuteRequestPagePage page;

  factory _$PatternPage([void Function(PatternPageBuilder)? updates]) =>
      (PatternPageBuilder()..update(updates))._build();

  _$PatternPage._({required this.data, required this.page}) : super._();
  @override
  PatternPage rebuild(void Function(PatternPageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PatternPageBuilder toBuilder() => PatternPageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PatternPage && data == other.data && page == other.page;
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
    return (newBuiltValueToStringHelper(r'PatternPage')
          ..add('data', data)
          ..add('page', page))
        .toString();
  }
}

class PatternPageBuilder implements Builder<PatternPage, PatternPageBuilder> {
  _$PatternPage? _$v;

  ListBuilder<Pattern>? _data;
  ListBuilder<Pattern> get data => _$this._data ??= ListBuilder<Pattern>();
  set data(ListBuilder<Pattern>? data) => _$this._data = data;

  CommuteRequestPagePageBuilder? _page;
  CommuteRequestPagePageBuilder get page =>
      _$this._page ??= CommuteRequestPagePageBuilder();
  set page(CommuteRequestPagePageBuilder? page) => _$this._page = page;

  PatternPageBuilder() {
    PatternPage._defaults(this);
  }

  PatternPageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _page = $v.page.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PatternPage other) {
    _$v = other as _$PatternPage;
  }

  @override
  void update(void Function(PatternPageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PatternPage build() => _build();

  _$PatternPage _build() {
    _$PatternPage _$result;
    try {
      _$result = _$v ??
          _$PatternPage._(
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
            r'PatternPage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
