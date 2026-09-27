// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ops_operator_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OpsOperatorPage extends OpsOperatorPage {
  @override
  final BuiltList<OpsOperator> data;
  @override
  final CommuteRequestPagePage page;

  factory _$OpsOperatorPage([void Function(OpsOperatorPageBuilder)? updates]) =>
      (OpsOperatorPageBuilder()..update(updates))._build();

  _$OpsOperatorPage._({required this.data, required this.page}) : super._();
  @override
  OpsOperatorPage rebuild(void Function(OpsOperatorPageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OpsOperatorPageBuilder toBuilder() => OpsOperatorPageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OpsOperatorPage && data == other.data && page == other.page;
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
    return (newBuiltValueToStringHelper(r'OpsOperatorPage')
          ..add('data', data)
          ..add('page', page))
        .toString();
  }
}

class OpsOperatorPageBuilder
    implements Builder<OpsOperatorPage, OpsOperatorPageBuilder> {
  _$OpsOperatorPage? _$v;

  ListBuilder<OpsOperator>? _data;
  ListBuilder<OpsOperator> get data =>
      _$this._data ??= ListBuilder<OpsOperator>();
  set data(ListBuilder<OpsOperator>? data) => _$this._data = data;

  CommuteRequestPagePageBuilder? _page;
  CommuteRequestPagePageBuilder get page =>
      _$this._page ??= CommuteRequestPagePageBuilder();
  set page(CommuteRequestPagePageBuilder? page) => _$this._page = page;

  OpsOperatorPageBuilder() {
    OpsOperatorPage._defaults(this);
  }

  OpsOperatorPageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _page = $v.page.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OpsOperatorPage other) {
    _$v = other as _$OpsOperatorPage;
  }

  @override
  void update(void Function(OpsOperatorPageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OpsOperatorPage build() => _build();

  _$OpsOperatorPage _build() {
    _$OpsOperatorPage _$result;
    try {
      _$result = _$v ??
          _$OpsOperatorPage._(
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
            r'OpsOperatorPage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
