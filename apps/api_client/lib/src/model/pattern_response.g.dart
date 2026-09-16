// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pattern_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PatternResponse extends PatternResponse {
  @override
  final Pattern data;

  factory _$PatternResponse([void Function(PatternResponseBuilder)? updates]) =>
      (PatternResponseBuilder()..update(updates))._build();

  _$PatternResponse._({required this.data}) : super._();
  @override
  PatternResponse rebuild(void Function(PatternResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PatternResponseBuilder toBuilder() => PatternResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PatternResponse && data == other.data;
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
    return (newBuiltValueToStringHelper(r'PatternResponse')..add('data', data))
        .toString();
  }
}

class PatternResponseBuilder
    implements Builder<PatternResponse, PatternResponseBuilder> {
  _$PatternResponse? _$v;

  PatternBuilder? _data;
  PatternBuilder get data => _$this._data ??= PatternBuilder();
  set data(PatternBuilder? data) => _$this._data = data;

  PatternResponseBuilder() {
    PatternResponse._defaults(this);
  }

  PatternResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PatternResponse other) {
    _$v = other as _$PatternResponse;
  }

  @override
  void update(void Function(PatternResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PatternResponse build() => _build();

  _$PatternResponse _build() {
    _$PatternResponse _$result;
    try {
      _$result = _$v ??
          _$PatternResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PatternResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
