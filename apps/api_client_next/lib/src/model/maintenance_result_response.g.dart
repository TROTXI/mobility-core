// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'maintenance_result_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MaintenanceResultResponse extends MaintenanceResultResponse {
  @override
  final MaintenanceResult data;

  factory _$MaintenanceResultResponse(
          [void Function(MaintenanceResultResponseBuilder)? updates]) =>
      (MaintenanceResultResponseBuilder()..update(updates))._build();

  _$MaintenanceResultResponse._({required this.data}) : super._();
  @override
  MaintenanceResultResponse rebuild(
          void Function(MaintenanceResultResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MaintenanceResultResponseBuilder toBuilder() =>
      MaintenanceResultResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MaintenanceResultResponse && data == other.data;
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
    return (newBuiltValueToStringHelper(r'MaintenanceResultResponse')
          ..add('data', data))
        .toString();
  }
}

class MaintenanceResultResponseBuilder
    implements
        Builder<MaintenanceResultResponse, MaintenanceResultResponseBuilder> {
  _$MaintenanceResultResponse? _$v;

  MaintenanceResultBuilder? _data;
  MaintenanceResultBuilder get data =>
      _$this._data ??= MaintenanceResultBuilder();
  set data(MaintenanceResultBuilder? data) => _$this._data = data;

  MaintenanceResultResponseBuilder() {
    MaintenanceResultResponse._defaults(this);
  }

  MaintenanceResultResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MaintenanceResultResponse other) {
    _$v = other as _$MaintenanceResultResponse;
  }

  @override
  void update(void Function(MaintenanceResultResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MaintenanceResultResponse build() => _build();

  _$MaintenanceResultResponse _build() {
    _$MaintenanceResultResponse _$result;
    try {
      _$result = _$v ??
          _$MaintenanceResultResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'MaintenanceResultResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
