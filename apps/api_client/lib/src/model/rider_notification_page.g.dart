// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rider_notification_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RiderNotificationPage extends RiderNotificationPage {
  @override
  final BuiltList<RiderNotification> data;
  @override
  final CommuteRequestPagePage page;

  factory _$RiderNotificationPage(
          [void Function(RiderNotificationPageBuilder)? updates]) =>
      (RiderNotificationPageBuilder()..update(updates))._build();

  _$RiderNotificationPage._({required this.data, required this.page})
      : super._();
  @override
  RiderNotificationPage rebuild(
          void Function(RiderNotificationPageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RiderNotificationPageBuilder toBuilder() =>
      RiderNotificationPageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RiderNotificationPage &&
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
    return (newBuiltValueToStringHelper(r'RiderNotificationPage')
          ..add('data', data)
          ..add('page', page))
        .toString();
  }
}

class RiderNotificationPageBuilder
    implements Builder<RiderNotificationPage, RiderNotificationPageBuilder> {
  _$RiderNotificationPage? _$v;

  ListBuilder<RiderNotification>? _data;
  ListBuilder<RiderNotification> get data =>
      _$this._data ??= ListBuilder<RiderNotification>();
  set data(ListBuilder<RiderNotification>? data) => _$this._data = data;

  CommuteRequestPagePageBuilder? _page;
  CommuteRequestPagePageBuilder get page =>
      _$this._page ??= CommuteRequestPagePageBuilder();
  set page(CommuteRequestPagePageBuilder? page) => _$this._page = page;

  RiderNotificationPageBuilder() {
    RiderNotificationPage._defaults(this);
  }

  RiderNotificationPageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _page = $v.page.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RiderNotificationPage other) {
    _$v = other as _$RiderNotificationPage;
  }

  @override
  void update(void Function(RiderNotificationPageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RiderNotificationPage build() => _build();

  _$RiderNotificationPage _build() {
    _$RiderNotificationPage _$result;
    try {
      _$result = _$v ??
          _$RiderNotificationPage._(
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
            r'RiderNotificationPage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
