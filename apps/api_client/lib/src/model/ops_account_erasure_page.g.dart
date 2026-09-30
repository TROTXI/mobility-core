// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ops_account_erasure_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OpsAccountErasurePage extends OpsAccountErasurePage {
  @override
  final BuiltList<OpsAccountErasure> data;
  @override
  final CommuteRequestPagePage page;

  factory _$OpsAccountErasurePage(
          [void Function(OpsAccountErasurePageBuilder)? updates]) =>
      (OpsAccountErasurePageBuilder()..update(updates))._build();

  _$OpsAccountErasurePage._({required this.data, required this.page})
      : super._();
  @override
  OpsAccountErasurePage rebuild(
          void Function(OpsAccountErasurePageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OpsAccountErasurePageBuilder toBuilder() =>
      OpsAccountErasurePageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OpsAccountErasurePage &&
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
    return (newBuiltValueToStringHelper(r'OpsAccountErasurePage')
          ..add('data', data)
          ..add('page', page))
        .toString();
  }
}

class OpsAccountErasurePageBuilder
    implements Builder<OpsAccountErasurePage, OpsAccountErasurePageBuilder> {
  _$OpsAccountErasurePage? _$v;

  ListBuilder<OpsAccountErasure>? _data;
  ListBuilder<OpsAccountErasure> get data =>
      _$this._data ??= ListBuilder<OpsAccountErasure>();
  set data(ListBuilder<OpsAccountErasure>? data) => _$this._data = data;

  CommuteRequestPagePageBuilder? _page;
  CommuteRequestPagePageBuilder get page =>
      _$this._page ??= CommuteRequestPagePageBuilder();
  set page(CommuteRequestPagePageBuilder? page) => _$this._page = page;

  OpsAccountErasurePageBuilder() {
    OpsAccountErasurePage._defaults(this);
  }

  OpsAccountErasurePageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _page = $v.page.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OpsAccountErasurePage other) {
    _$v = other as _$OpsAccountErasurePage;
  }

  @override
  void update(void Function(OpsAccountErasurePageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OpsAccountErasurePage build() => _build();

  _$OpsAccountErasurePage _build() {
    _$OpsAccountErasurePage _$result;
    try {
      _$result = _$v ??
          _$OpsAccountErasurePage._(
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
            r'OpsAccountErasurePage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
