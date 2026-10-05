// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ops_auto_renewal_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OpsAutoRenewalPage extends OpsAutoRenewalPage {
  @override
  final BuiltList<OpsAutoRenewal> data;
  @override
  final CommuteRequestPagePage page;

  factory _$OpsAutoRenewalPage(
          [void Function(OpsAutoRenewalPageBuilder)? updates]) =>
      (OpsAutoRenewalPageBuilder()..update(updates))._build();

  _$OpsAutoRenewalPage._({required this.data, required this.page}) : super._();
  @override
  OpsAutoRenewalPage rebuild(
          void Function(OpsAutoRenewalPageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OpsAutoRenewalPageBuilder toBuilder() =>
      OpsAutoRenewalPageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OpsAutoRenewalPage &&
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
    return (newBuiltValueToStringHelper(r'OpsAutoRenewalPage')
          ..add('data', data)
          ..add('page', page))
        .toString();
  }
}

class OpsAutoRenewalPageBuilder
    implements Builder<OpsAutoRenewalPage, OpsAutoRenewalPageBuilder> {
  _$OpsAutoRenewalPage? _$v;

  ListBuilder<OpsAutoRenewal>? _data;
  ListBuilder<OpsAutoRenewal> get data =>
      _$this._data ??= ListBuilder<OpsAutoRenewal>();
  set data(ListBuilder<OpsAutoRenewal>? data) => _$this._data = data;

  CommuteRequestPagePageBuilder? _page;
  CommuteRequestPagePageBuilder get page =>
      _$this._page ??= CommuteRequestPagePageBuilder();
  set page(CommuteRequestPagePageBuilder? page) => _$this._page = page;

  OpsAutoRenewalPageBuilder() {
    OpsAutoRenewalPage._defaults(this);
  }

  OpsAutoRenewalPageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _page = $v.page.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OpsAutoRenewalPage other) {
    _$v = other as _$OpsAutoRenewalPage;
  }

  @override
  void update(void Function(OpsAutoRenewalPageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OpsAutoRenewalPage build() => _build();

  _$OpsAutoRenewalPage _build() {
    _$OpsAutoRenewalPage _$result;
    try {
      _$result = _$v ??
          _$OpsAutoRenewalPage._(
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
            r'OpsAutoRenewalPage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
