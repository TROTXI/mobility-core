// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ops_incident_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OpsIncidentPage extends OpsIncidentPage {
  @override
  final BuiltList<OpsIncident> data;
  @override
  final CommuteRequestPagePage page;

  factory _$OpsIncidentPage([void Function(OpsIncidentPageBuilder)? updates]) =>
      (OpsIncidentPageBuilder()..update(updates))._build();

  _$OpsIncidentPage._({required this.data, required this.page}) : super._();
  @override
  OpsIncidentPage rebuild(void Function(OpsIncidentPageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OpsIncidentPageBuilder toBuilder() => OpsIncidentPageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OpsIncidentPage && data == other.data && page == other.page;
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
    return (newBuiltValueToStringHelper(r'OpsIncidentPage')
          ..add('data', data)
          ..add('page', page))
        .toString();
  }
}

class OpsIncidentPageBuilder
    implements Builder<OpsIncidentPage, OpsIncidentPageBuilder> {
  _$OpsIncidentPage? _$v;

  ListBuilder<OpsIncident>? _data;
  ListBuilder<OpsIncident> get data =>
      _$this._data ??= ListBuilder<OpsIncident>();
  set data(ListBuilder<OpsIncident>? data) => _$this._data = data;

  CommuteRequestPagePageBuilder? _page;
  CommuteRequestPagePageBuilder get page =>
      _$this._page ??= CommuteRequestPagePageBuilder();
  set page(CommuteRequestPagePageBuilder? page) => _$this._page = page;

  OpsIncidentPageBuilder() {
    OpsIncidentPage._defaults(this);
  }

  OpsIncidentPageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _page = $v.page.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OpsIncidentPage other) {
    _$v = other as _$OpsIncidentPage;
  }

  @override
  void update(void Function(OpsIncidentPageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OpsIncidentPage build() => _build();

  _$OpsIncidentPage _build() {
    _$OpsIncidentPage _$result;
    try {
      _$result = _$v ??
          _$OpsIncidentPage._(
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
            r'OpsIncidentPage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
