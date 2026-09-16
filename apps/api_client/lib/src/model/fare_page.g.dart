// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fare_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$FarePage extends FarePage {
  @override
  final BuiltList<Fare> data;
  @override
  final CommuteRequestPagePage page;

  factory _$FarePage([void Function(FarePageBuilder)? updates]) =>
      (FarePageBuilder()..update(updates))._build();

  _$FarePage._({required this.data, required this.page}) : super._();
  @override
  FarePage rebuild(void Function(FarePageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FarePageBuilder toBuilder() => FarePageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FarePage && data == other.data && page == other.page;
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
    return (newBuiltValueToStringHelper(r'FarePage')
          ..add('data', data)
          ..add('page', page))
        .toString();
  }
}

class FarePageBuilder implements Builder<FarePage, FarePageBuilder> {
  _$FarePage? _$v;

  ListBuilder<Fare>? _data;
  ListBuilder<Fare> get data => _$this._data ??= ListBuilder<Fare>();
  set data(ListBuilder<Fare>? data) => _$this._data = data;

  CommuteRequestPagePageBuilder? _page;
  CommuteRequestPagePageBuilder get page =>
      _$this._page ??= CommuteRequestPagePageBuilder();
  set page(CommuteRequestPagePageBuilder? page) => _$this._page = page;

  FarePageBuilder() {
    FarePage._defaults(this);
  }

  FarePageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _page = $v.page.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FarePage other) {
    _$v = other as _$FarePage;
  }

  @override
  void update(void Function(FarePageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FarePage build() => _build();

  _$FarePage _build() {
    _$FarePage _$result;
    try {
      _$result = _$v ??
          _$FarePage._(
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
            r'FarePage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
