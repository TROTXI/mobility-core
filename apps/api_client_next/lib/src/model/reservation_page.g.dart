// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ReservationPage extends ReservationPage {
  @override
  final BuiltList<Reservation> data;
  @override
  final CommuteRequestPagePage page;

  factory _$ReservationPage([void Function(ReservationPageBuilder)? updates]) =>
      (ReservationPageBuilder()..update(updates))._build();

  _$ReservationPage._({required this.data, required this.page}) : super._();
  @override
  ReservationPage rebuild(void Function(ReservationPageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReservationPageBuilder toBuilder() => ReservationPageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReservationPage && data == other.data && page == other.page;
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
    return (newBuiltValueToStringHelper(r'ReservationPage')
          ..add('data', data)
          ..add('page', page))
        .toString();
  }
}

class ReservationPageBuilder
    implements Builder<ReservationPage, ReservationPageBuilder> {
  _$ReservationPage? _$v;

  ListBuilder<Reservation>? _data;
  ListBuilder<Reservation> get data =>
      _$this._data ??= ListBuilder<Reservation>();
  set data(ListBuilder<Reservation>? data) => _$this._data = data;

  CommuteRequestPagePageBuilder? _page;
  CommuteRequestPagePageBuilder get page =>
      _$this._page ??= CommuteRequestPagePageBuilder();
  set page(CommuteRequestPagePageBuilder? page) => _$this._page = page;

  ReservationPageBuilder() {
    ReservationPage._defaults(this);
  }

  ReservationPageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _page = $v.page.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReservationPage other) {
    _$v = other as _$ReservationPage;
  }

  @override
  void update(void Function(ReservationPageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReservationPage build() => _build();

  _$ReservationPage _build() {
    _$ReservationPage _$result;
    try {
      _$result = _$v ??
          _$ReservationPage._(
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
            r'ReservationPage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
