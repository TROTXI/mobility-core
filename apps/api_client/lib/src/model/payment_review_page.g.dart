// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_review_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PaymentReviewPage extends PaymentReviewPage {
  @override
  final BuiltList<PaymentReview> data;
  @override
  final CommuteRequestPagePage page;

  factory _$PaymentReviewPage(
          [void Function(PaymentReviewPageBuilder)? updates]) =>
      (PaymentReviewPageBuilder()..update(updates))._build();

  _$PaymentReviewPage._({required this.data, required this.page}) : super._();
  @override
  PaymentReviewPage rebuild(void Function(PaymentReviewPageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PaymentReviewPageBuilder toBuilder() =>
      PaymentReviewPageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PaymentReviewPage &&
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
    return (newBuiltValueToStringHelper(r'PaymentReviewPage')
          ..add('data', data)
          ..add('page', page))
        .toString();
  }
}

class PaymentReviewPageBuilder
    implements Builder<PaymentReviewPage, PaymentReviewPageBuilder> {
  _$PaymentReviewPage? _$v;

  ListBuilder<PaymentReview>? _data;
  ListBuilder<PaymentReview> get data =>
      _$this._data ??= ListBuilder<PaymentReview>();
  set data(ListBuilder<PaymentReview>? data) => _$this._data = data;

  CommuteRequestPagePageBuilder? _page;
  CommuteRequestPagePageBuilder get page =>
      _$this._page ??= CommuteRequestPagePageBuilder();
  set page(CommuteRequestPagePageBuilder? page) => _$this._page = page;

  PaymentReviewPageBuilder() {
    PaymentReviewPage._defaults(this);
  }

  PaymentReviewPageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _page = $v.page.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PaymentReviewPage other) {
    _$v = other as _$PaymentReviewPage;
  }

  @override
  void update(void Function(PaymentReviewPageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PaymentReviewPage build() => _build();

  _$PaymentReviewPage _build() {
    _$PaymentReviewPage _$result;
    try {
      _$result = _$v ??
          _$PaymentReviewPage._(
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
            r'PaymentReviewPage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
