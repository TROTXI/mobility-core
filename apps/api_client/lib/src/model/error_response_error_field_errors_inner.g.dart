// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'error_response_error_field_errors_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ErrorResponseErrorFieldErrorsInner
    extends ErrorResponseErrorFieldErrorsInner {
  @override
  final String field;
  @override
  final String code;

  factory _$ErrorResponseErrorFieldErrorsInner(
          [void Function(ErrorResponseErrorFieldErrorsInnerBuilder)?
              updates]) =>
      (ErrorResponseErrorFieldErrorsInnerBuilder()..update(updates))._build();

  _$ErrorResponseErrorFieldErrorsInner._(
      {required this.field, required this.code})
      : super._();
  @override
  ErrorResponseErrorFieldErrorsInner rebuild(
          void Function(ErrorResponseErrorFieldErrorsInnerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ErrorResponseErrorFieldErrorsInnerBuilder toBuilder() =>
      ErrorResponseErrorFieldErrorsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ErrorResponseErrorFieldErrorsInner &&
        field == other.field &&
        code == other.code;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, field.hashCode);
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ErrorResponseErrorFieldErrorsInner')
          ..add('field', field)
          ..add('code', code))
        .toString();
  }
}

class ErrorResponseErrorFieldErrorsInnerBuilder
    implements
        Builder<ErrorResponseErrorFieldErrorsInner,
            ErrorResponseErrorFieldErrorsInnerBuilder> {
  _$ErrorResponseErrorFieldErrorsInner? _$v;

  String? _field;
  String? get field => _$this._field;
  set field(String? field) => _$this._field = field;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  ErrorResponseErrorFieldErrorsInnerBuilder() {
    ErrorResponseErrorFieldErrorsInner._defaults(this);
  }

  ErrorResponseErrorFieldErrorsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _field = $v.field;
      _code = $v.code;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ErrorResponseErrorFieldErrorsInner other) {
    _$v = other as _$ErrorResponseErrorFieldErrorsInner;
  }

  @override
  void update(
      void Function(ErrorResponseErrorFieldErrorsInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ErrorResponseErrorFieldErrorsInner build() => _build();

  _$ErrorResponseErrorFieldErrorsInner _build() {
    final _$result = _$v ??
        _$ErrorResponseErrorFieldErrorsInner._(
          field: BuiltValueNullFieldError.checkNotNull(
              field, r'ErrorResponseErrorFieldErrorsInner', 'field'),
          code: BuiltValueNullFieldError.checkNotNull(
              code, r'ErrorResponseErrorFieldErrorsInner', 'code'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
