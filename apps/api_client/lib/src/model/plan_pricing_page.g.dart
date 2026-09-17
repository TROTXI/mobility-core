// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_pricing_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PlanPricingPage extends PlanPricingPage {
  @override
  final BuiltList<PlanPricing> data;
  @override
  final CommuteRequestPagePage page;

  factory _$PlanPricingPage([void Function(PlanPricingPageBuilder)? updates]) =>
      (PlanPricingPageBuilder()..update(updates))._build();

  _$PlanPricingPage._({required this.data, required this.page}) : super._();
  @override
  PlanPricingPage rebuild(void Function(PlanPricingPageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PlanPricingPageBuilder toBuilder() => PlanPricingPageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PlanPricingPage && data == other.data && page == other.page;
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
    return (newBuiltValueToStringHelper(r'PlanPricingPage')
          ..add('data', data)
          ..add('page', page))
        .toString();
  }
}

class PlanPricingPageBuilder
    implements Builder<PlanPricingPage, PlanPricingPageBuilder> {
  _$PlanPricingPage? _$v;

  ListBuilder<PlanPricing>? _data;
  ListBuilder<PlanPricing> get data =>
      _$this._data ??= ListBuilder<PlanPricing>();
  set data(ListBuilder<PlanPricing>? data) => _$this._data = data;

  CommuteRequestPagePageBuilder? _page;
  CommuteRequestPagePageBuilder get page =>
      _$this._page ??= CommuteRequestPagePageBuilder();
  set page(CommuteRequestPagePageBuilder? page) => _$this._page = page;

  PlanPricingPageBuilder() {
    PlanPricingPage._defaults(this);
  }

  PlanPricingPageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _page = $v.page.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PlanPricingPage other) {
    _$v = other as _$PlanPricingPage;
  }

  @override
  void update(void Function(PlanPricingPageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PlanPricingPage build() => _build();

  _$PlanPricingPage _build() {
    _$PlanPricingPage _$result;
    try {
      _$result = _$v ??
          _$PlanPricingPage._(
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
            r'PlanPricingPage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
