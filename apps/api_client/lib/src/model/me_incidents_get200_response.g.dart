// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'me_incidents_get200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MeIncidentsGet200Response extends MeIncidentsGet200Response {
  @override
  final BuiltList<MeIncidentsGet200ResponseIncidentsInner> incidents;

  factory _$MeIncidentsGet200Response(
          [void Function(MeIncidentsGet200ResponseBuilder)? updates]) =>
      (MeIncidentsGet200ResponseBuilder()..update(updates))._build();

  _$MeIncidentsGet200Response._({required this.incidents}) : super._();
  @override
  MeIncidentsGet200Response rebuild(
          void Function(MeIncidentsGet200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MeIncidentsGet200ResponseBuilder toBuilder() =>
      MeIncidentsGet200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MeIncidentsGet200Response && incidents == other.incidents;
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
    return (newBuiltValueToStringHelper(r'MeIncidentsGet200Response')
          ..add('incidents', incidents))
        .toString();
  }
}

class MeIncidentsGet200ResponseBuilder
    implements
        Builder<MeIncidentsGet200Response, MeIncidentsGet200ResponseBuilder> {
  _$MeIncidentsGet200Response? _$v;

  ListBuilder<MeIncidentsGet200ResponseIncidentsInner>? _incidents;
  ListBuilder<MeIncidentsGet200ResponseIncidentsInner> get incidents =>
      _$this._incidents ??=
          ListBuilder<MeIncidentsGet200ResponseIncidentsInner>();
  set incidents(
          ListBuilder<MeIncidentsGet200ResponseIncidentsInner>? incidents) =>
      _$this._incidents = incidents;

  MeIncidentsGet200ResponseBuilder() {
    MeIncidentsGet200Response._defaults(this);
  }

  MeIncidentsGet200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _incidents = $v.incidents.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MeIncidentsGet200Response other) {
    _$v = other as _$MeIncidentsGet200Response;
  }

  @override
  void update(void Function(MeIncidentsGet200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MeIncidentsGet200Response build() => _build();

  _$MeIncidentsGet200Response _build() {
    _$MeIncidentsGet200Response _$result;
    try {
      _$result = _$v ??
          _$MeIncidentsGet200Response._(
            incidents: incidents.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'incidents';
        incidents.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'MeIncidentsGet200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
