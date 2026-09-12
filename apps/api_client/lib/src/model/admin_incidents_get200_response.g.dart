// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_incidents_get200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminIncidentsGet200Response extends AdminIncidentsGet200Response {
  @override
  final BuiltList<AdminIncidentsGet200ResponseIncidentsInner> incidents;

  factory _$AdminIncidentsGet200Response(
          [void Function(AdminIncidentsGet200ResponseBuilder)? updates]) =>
      (AdminIncidentsGet200ResponseBuilder()..update(updates))._build();

  _$AdminIncidentsGet200Response._({required this.incidents}) : super._();
  @override
  AdminIncidentsGet200Response rebuild(
          void Function(AdminIncidentsGet200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminIncidentsGet200ResponseBuilder toBuilder() =>
      AdminIncidentsGet200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminIncidentsGet200Response &&
        incidents == other.incidents;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, incidents.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminIncidentsGet200Response')
          ..add('incidents', incidents))
        .toString();
  }
}

class AdminIncidentsGet200ResponseBuilder
    implements
        Builder<AdminIncidentsGet200Response,
            AdminIncidentsGet200ResponseBuilder> {
  _$AdminIncidentsGet200Response? _$v;

  ListBuilder<AdminIncidentsGet200ResponseIncidentsInner>? _incidents;
  ListBuilder<AdminIncidentsGet200ResponseIncidentsInner> get incidents =>
      _$this._incidents ??=
          ListBuilder<AdminIncidentsGet200ResponseIncidentsInner>();
  set incidents(
          ListBuilder<AdminIncidentsGet200ResponseIncidentsInner>? incidents) =>
      _$this._incidents = incidents;

  AdminIncidentsGet200ResponseBuilder() {
    AdminIncidentsGet200Response._defaults(this);
  }

  AdminIncidentsGet200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _incidents = $v.incidents.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminIncidentsGet200Response other) {
    _$v = other as _$AdminIncidentsGet200Response;
  }

  @override
  void update(void Function(AdminIncidentsGet200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminIncidentsGet200Response build() => _build();

  _$AdminIncidentsGet200Response _build() {
    _$AdminIncidentsGet200Response _$result;
    try {
      _$result = _$v ??
          _$AdminIncidentsGet200Response._(
            incidents: incidents.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'incidents';
        incidents.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'AdminIncidentsGet200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
