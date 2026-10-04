// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ops_team_entry_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OpsTeamEntryPage extends OpsTeamEntryPage {
  @override
  final BuiltList<OpsTeamEntry> data;
  @override
  final CommuteRequestPagePage page;

  factory _$OpsTeamEntryPage(
          [void Function(OpsTeamEntryPageBuilder)? updates]) =>
      (OpsTeamEntryPageBuilder()..update(updates))._build();

  _$OpsTeamEntryPage._({required this.data, required this.page}) : super._();
  @override
  OpsTeamEntryPage rebuild(void Function(OpsTeamEntryPageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OpsTeamEntryPageBuilder toBuilder() =>
      OpsTeamEntryPageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OpsTeamEntryPage &&
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
    return (newBuiltValueToStringHelper(r'OpsTeamEntryPage')
          ..add('data', data)
          ..add('page', page))
        .toString();
  }
}

class OpsTeamEntryPageBuilder
    implements Builder<OpsTeamEntryPage, OpsTeamEntryPageBuilder> {
  _$OpsTeamEntryPage? _$v;

  ListBuilder<OpsTeamEntry>? _data;
  ListBuilder<OpsTeamEntry> get data =>
      _$this._data ??= ListBuilder<OpsTeamEntry>();
  set data(ListBuilder<OpsTeamEntry>? data) => _$this._data = data;

  CommuteRequestPagePageBuilder? _page;
  CommuteRequestPagePageBuilder get page =>
      _$this._page ??= CommuteRequestPagePageBuilder();
  set page(CommuteRequestPagePageBuilder? page) => _$this._page = page;

  OpsTeamEntryPageBuilder() {
    OpsTeamEntryPage._defaults(this);
  }

  OpsTeamEntryPageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _page = $v.page.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OpsTeamEntryPage other) {
    _$v = other as _$OpsTeamEntryPage;
  }

  @override
  void update(void Function(OpsTeamEntryPageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OpsTeamEntryPage build() => _build();

  _$OpsTeamEntryPage _build() {
    _$OpsTeamEntryPage _$result;
    try {
      _$result = _$v ??
          _$OpsTeamEntryPage._(
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
            r'OpsTeamEntryPage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
