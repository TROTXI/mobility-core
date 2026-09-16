// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manifest_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ManifestResponse extends ManifestResponse {
  @override
  final Manifest data;

  factory _$ManifestResponse(
          [void Function(ManifestResponseBuilder)? updates]) =>
      (ManifestResponseBuilder()..update(updates))._build();

  _$ManifestResponse._({required this.data}) : super._();
  @override
  ManifestResponse rebuild(void Function(ManifestResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ManifestResponseBuilder toBuilder() =>
      ManifestResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ManifestResponse && data == other.data;
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
    return (newBuiltValueToStringHelper(r'ManifestResponse')..add('data', data))
        .toString();
  }
}

class ManifestResponseBuilder
    implements Builder<ManifestResponse, ManifestResponseBuilder> {
  _$ManifestResponse? _$v;

  ManifestBuilder? _data;
  ManifestBuilder get data => _$this._data ??= ManifestBuilder();
  set data(ManifestBuilder? data) => _$this._data = data;

  ManifestResponseBuilder() {
    ManifestResponse._defaults(this);
  }

  ManifestResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ManifestResponse other) {
    _$v = other as _$ManifestResponse;
  }

  @override
  void update(void Function(ManifestResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ManifestResponse build() => _build();

  _$ManifestResponse _build() {
    _$ManifestResponse _$result;
    try {
      _$result = _$v ??
          _$ManifestResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ManifestResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
