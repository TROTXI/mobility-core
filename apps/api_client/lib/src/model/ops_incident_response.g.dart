// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ops_incident_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OpsIncidentResponse extends OpsIncidentResponse {
  @override
  final OpsIncident data;

  factory _$OpsIncidentResponse(
          [void Function(OpsIncidentResponseBuilder)? updates]) =>
      (OpsIncidentResponseBuilder()..update(updates))._build();

  _$OpsIncidentResponse._({required this.data}) : super._();
  @override
  OpsIncidentResponse rebuild(
          void Function(OpsIncidentResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OpsIncidentResponseBuilder toBuilder() =>
      OpsIncidentResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OpsIncidentResponse && data == other.data;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OpsIncidentResponse')
          ..add('data', data))
        .toString();
  }
}

class OpsIncidentResponseBuilder
    implements Builder<OpsIncidentResponse, OpsIncidentResponseBuilder> {
  _$OpsIncidentResponse? _$v;

  OpsIncidentBuilder? _data;
  OpsIncidentBuilder get data => _$this._data ??= OpsIncidentBuilder();
  set data(OpsIncidentBuilder? data) => _$this._data = data;

  OpsIncidentResponseBuilder() {
    OpsIncidentResponse._defaults(this);
  }

  OpsIncidentResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OpsIncidentResponse other) {
    _$v = other as _$OpsIncidentResponse;
  }

  @override
  void update(void Function(OpsIncidentResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OpsIncidentResponse build() => _build();

  _$OpsIncidentResponse _build() {
    _$OpsIncidentResponse _$result;
    try {
      _$result = _$v ??
          _$OpsIncidentResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'OpsIncidentResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
