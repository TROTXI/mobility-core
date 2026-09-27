// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ops_audit_event_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OpsAuditEventPage extends OpsAuditEventPage {
  @override
  final BuiltList<OpsAuditEvent> data;
  @override
  final CommuteRequestPagePage page;

  factory _$OpsAuditEventPage(
          [void Function(OpsAuditEventPageBuilder)? updates]) =>
      (OpsAuditEventPageBuilder()..update(updates))._build();

  _$OpsAuditEventPage._({required this.data, required this.page}) : super._();
  @override
  OpsAuditEventPage rebuild(void Function(OpsAuditEventPageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OpsAuditEventPageBuilder toBuilder() =>
      OpsAuditEventPageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OpsAuditEventPage &&
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
    return (newBuiltValueToStringHelper(r'OpsAuditEventPage')
          ..add('data', data)
          ..add('page', page))
        .toString();
  }
}

class OpsAuditEventPageBuilder
    implements Builder<OpsAuditEventPage, OpsAuditEventPageBuilder> {
  _$OpsAuditEventPage? _$v;

  ListBuilder<OpsAuditEvent>? _data;
  ListBuilder<OpsAuditEvent> get data =>
      _$this._data ??= ListBuilder<OpsAuditEvent>();
  set data(ListBuilder<OpsAuditEvent>? data) => _$this._data = data;

  CommuteRequestPagePageBuilder? _page;
  CommuteRequestPagePageBuilder get page =>
      _$this._page ??= CommuteRequestPagePageBuilder();
  set page(CommuteRequestPagePageBuilder? page) => _$this._page = page;

  OpsAuditEventPageBuilder() {
    OpsAuditEventPage._defaults(this);
  }

  OpsAuditEventPageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _page = $v.page.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OpsAuditEventPage other) {
    _$v = other as _$OpsAuditEventPage;
  }

  @override
  void update(void Function(OpsAuditEventPageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OpsAuditEventPage build() => _build();

  _$OpsAuditEventPage _build() {
    _$OpsAuditEventPage _$result;
    try {
      _$result = _$v ??
          _$OpsAuditEventPage._(
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
            r'OpsAuditEventPage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
