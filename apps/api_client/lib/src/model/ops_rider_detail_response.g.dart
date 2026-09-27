// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ops_rider_detail_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OpsRiderDetailResponse extends OpsRiderDetailResponse {
  @override
  final OpsRiderDetail data;

  factory _$OpsRiderDetailResponse(
          [void Function(OpsRiderDetailResponseBuilder)? updates]) =>
      (OpsRiderDetailResponseBuilder()..update(updates))._build();

  _$OpsRiderDetailResponse._({required this.data}) : super._();
  @override
  OpsRiderDetailResponse rebuild(
          void Function(OpsRiderDetailResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OpsRiderDetailResponseBuilder toBuilder() =>
      OpsRiderDetailResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OpsRiderDetailResponse && data == other.data;
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
    return (newBuiltValueToStringHelper(r'OpsRiderDetailResponse')
          ..add('data', data))
        .toString();
  }
}

class OpsRiderDetailResponseBuilder
    implements Builder<OpsRiderDetailResponse, OpsRiderDetailResponseBuilder> {
  _$OpsRiderDetailResponse? _$v;

  OpsRiderDetailBuilder? _data;
  OpsRiderDetailBuilder get data => _$this._data ??= OpsRiderDetailBuilder();
  set data(OpsRiderDetailBuilder? data) => _$this._data = data;

  OpsRiderDetailResponseBuilder() {
    OpsRiderDetailResponse._defaults(this);
  }

  OpsRiderDetailResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OpsRiderDetailResponse other) {
    _$v = other as _$OpsRiderDetailResponse;
  }

  @override
  void update(void Function(OpsRiderDetailResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OpsRiderDetailResponse build() => _build();

  _$OpsRiderDetailResponse _build() {
    _$OpsRiderDetailResponse _$result;
    try {
      _$result = _$v ??
          _$OpsRiderDetailResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'OpsRiderDetailResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
