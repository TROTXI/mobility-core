// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'personal_pause_preview_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PersonalPausePreviewResponse extends PersonalPausePreviewResponse {
  @override
  final PersonalPausePreview data;

  factory _$PersonalPausePreviewResponse(
          [void Function(PersonalPausePreviewResponseBuilder)? updates]) =>
      (PersonalPausePreviewResponseBuilder()..update(updates))._build();

  _$PersonalPausePreviewResponse._({required this.data}) : super._();
  @override
  PersonalPausePreviewResponse rebuild(
          void Function(PersonalPausePreviewResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PersonalPausePreviewResponseBuilder toBuilder() =>
      PersonalPausePreviewResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PersonalPausePreviewResponse && data == other.data;
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
    return (newBuiltValueToStringHelper(r'PersonalPausePreviewResponse')
          ..add('data', data))
        .toString();
  }
}

class PersonalPausePreviewResponseBuilder
    implements
        Builder<PersonalPausePreviewResponse,
            PersonalPausePreviewResponseBuilder> {
  _$PersonalPausePreviewResponse? _$v;

  PersonalPausePreviewBuilder? _data;
  PersonalPausePreviewBuilder get data =>
      _$this._data ??= PersonalPausePreviewBuilder();
  set data(PersonalPausePreviewBuilder? data) => _$this._data = data;

  PersonalPausePreviewResponseBuilder() {
    PersonalPausePreviewResponse._defaults(this);
  }

  PersonalPausePreviewResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PersonalPausePreviewResponse other) {
    _$v = other as _$PersonalPausePreviewResponse;
  }

  @override
  void update(void Function(PersonalPausePreviewResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PersonalPausePreviewResponse build() => _build();

  _$PersonalPausePreviewResponse _build() {
    _$PersonalPausePreviewResponse _$result;
    try {
      _$result = _$v ??
          _$PersonalPausePreviewResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PersonalPausePreviewResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
