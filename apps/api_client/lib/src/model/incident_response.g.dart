// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'incident_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$IncidentResponse extends IncidentResponse {
  @override
  final Incident data;

  factory _$IncidentResponse(
          [void Function(IncidentResponseBuilder)? updates]) =>
      (IncidentResponseBuilder()..update(updates))._build();

  _$IncidentResponse._({required this.data}) : super._();
  @override
  IncidentResponse rebuild(void Function(IncidentResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  IncidentResponseBuilder toBuilder() =>
      IncidentResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is IncidentResponse && data == other.data;
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
    return (newBuiltValueToStringHelper(r'IncidentResponse')..add('data', data))
        .toString();
  }
}

class IncidentResponseBuilder
    implements Builder<IncidentResponse, IncidentResponseBuilder> {
  _$IncidentResponse? _$v;

  IncidentBuilder? _data;
  IncidentBuilder get data => _$this._data ??= IncidentBuilder();
  set data(IncidentBuilder? data) => _$this._data = data;

  IncidentResponseBuilder() {
    IncidentResponse._defaults(this);
  }

  IncidentResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(IncidentResponse other) {
    _$v = other as _$IncidentResponse;
  }

  @override
  void update(void Function(IncidentResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  IncidentResponse build() => _build();

  _$IncidentResponse _build() {
    _$IncidentResponse _$result;
    try {
      _$result = _$v ??
          _$IncidentResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'IncidentResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
