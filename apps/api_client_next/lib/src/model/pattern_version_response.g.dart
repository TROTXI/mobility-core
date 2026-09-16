// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pattern_version_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PatternVersionResponse extends PatternVersionResponse {
  @override
  final PatternVersion data;

  factory _$PatternVersionResponse(
          [void Function(PatternVersionResponseBuilder)? updates]) =>
      (PatternVersionResponseBuilder()..update(updates))._build();

  _$PatternVersionResponse._({required this.data}) : super._();
  @override
  PatternVersionResponse rebuild(
          void Function(PatternVersionResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PatternVersionResponseBuilder toBuilder() =>
      PatternVersionResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PatternVersionResponse && data == other.data;
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
    return (newBuiltValueToStringHelper(r'PatternVersionResponse')
          ..add('data', data))
        .toString();
  }
}

class PatternVersionResponseBuilder
    implements Builder<PatternVersionResponse, PatternVersionResponseBuilder> {
  _$PatternVersionResponse? _$v;

  PatternVersionBuilder? _data;
  PatternVersionBuilder get data => _$this._data ??= PatternVersionBuilder();
  set data(PatternVersionBuilder? data) => _$this._data = data;

  PatternVersionResponseBuilder() {
    PatternVersionResponse._defaults(this);
  }

  PatternVersionResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PatternVersionResponse other) {
    _$v = other as _$PatternVersionResponse;
  }

  @override
  void update(void Function(PatternVersionResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PatternVersionResponse build() => _build();

  _$PatternVersionResponse _build() {
    _$PatternVersionResponse _$result;
    try {
      _$result = _$v ??
          _$PatternVersionResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PatternVersionResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
