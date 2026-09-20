// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'personal_pause_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PersonalPauseResponse extends PersonalPauseResponse {
  @override
  final PersonalPause data;

  factory _$PersonalPauseResponse(
          [void Function(PersonalPauseResponseBuilder)? updates]) =>
      (PersonalPauseResponseBuilder()..update(updates))._build();

  _$PersonalPauseResponse._({required this.data}) : super._();
  @override
  PersonalPauseResponse rebuild(
          void Function(PersonalPauseResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PersonalPauseResponseBuilder toBuilder() =>
      PersonalPauseResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PersonalPauseResponse && data == other.data;
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
    return (newBuiltValueToStringHelper(r'PersonalPauseResponse')
          ..add('data', data))
        .toString();
  }
}

class PersonalPauseResponseBuilder
    implements Builder<PersonalPauseResponse, PersonalPauseResponseBuilder> {
  _$PersonalPauseResponse? _$v;

  PersonalPauseBuilder? _data;
  PersonalPauseBuilder get data => _$this._data ??= PersonalPauseBuilder();
  set data(PersonalPauseBuilder? data) => _$this._data = data;

  PersonalPauseResponseBuilder() {
    PersonalPauseResponse._defaults(this);
  }

  PersonalPauseResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PersonalPauseResponse other) {
    _$v = other as _$PersonalPauseResponse;
  }

  @override
  void update(void Function(PersonalPauseResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PersonalPauseResponse build() => _build();

  _$PersonalPauseResponse _build() {
    _$PersonalPauseResponse _$result;
    try {
      _$result = _$v ??
          _$PersonalPauseResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PersonalPauseResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
