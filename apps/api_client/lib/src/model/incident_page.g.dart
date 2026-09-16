// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'incident_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$IncidentPage extends IncidentPage {
  @override
  final BuiltList<Incident> data;
  @override
  final CommuteRequestPagePage page;

  factory _$IncidentPage([void Function(IncidentPageBuilder)? updates]) =>
      (IncidentPageBuilder()..update(updates))._build();

  _$IncidentPage._({required this.data, required this.page}) : super._();
  @override
  IncidentPage rebuild(void Function(IncidentPageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  IncidentPageBuilder toBuilder() => IncidentPageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is IncidentPage && data == other.data && page == other.page;
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
    return (newBuiltValueToStringHelper(r'IncidentPage')
          ..add('data', data)
          ..add('page', page))
        .toString();
  }
}

class IncidentPageBuilder
    implements Builder<IncidentPage, IncidentPageBuilder> {
  _$IncidentPage? _$v;

  ListBuilder<Incident>? _data;
  ListBuilder<Incident> get data => _$this._data ??= ListBuilder<Incident>();
  set data(ListBuilder<Incident>? data) => _$this._data = data;

  CommuteRequestPagePageBuilder? _page;
  CommuteRequestPagePageBuilder get page =>
      _$this._page ??= CommuteRequestPagePageBuilder();
  set page(CommuteRequestPagePageBuilder? page) => _$this._page = page;

  IncidentPageBuilder() {
    IncidentPage._defaults(this);
  }

  IncidentPageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _page = $v.page.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(IncidentPage other) {
    _$v = other as _$IncidentPage;
  }

  @override
  void update(void Function(IncidentPageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  IncidentPage build() => _build();

  _$IncidentPage _build() {
    _$IncidentPage _$result;
    try {
      _$result = _$v ??
          _$IncidentPage._(
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
            r'IncidentPage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
