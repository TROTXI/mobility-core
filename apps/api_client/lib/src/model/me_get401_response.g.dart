// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'me_get401_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MeGet401Response extends MeGet401Response {
  @override
  final String error;
  @override
  final String message;

  factory _$MeGet401Response(
          [void Function(MeGet401ResponseBuilder)? updates]) =>
      (MeGet401ResponseBuilder()..update(updates))._build();

  _$MeGet401Response._({required this.error, required this.message})
      : super._();
  @override
  MeGet401Response rebuild(void Function(MeGet401ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MeGet401ResponseBuilder toBuilder() =>
      MeGet401ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MeGet401Response &&
        error == other.error &&
        message == other.message;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, error.hashCode);
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MeGet401Response')
          ..add('error', error)
          ..add('message', message))
        .toString();
  }
}

class MeGet401ResponseBuilder
    implements Builder<MeGet401Response, MeGet401ResponseBuilder> {
  _$MeGet401Response? _$v;

  String? _error;
  String? get error => _$this._error;
  set error(String? error) => _$this._error = error;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  MeGet401ResponseBuilder() {
    MeGet401Response._defaults(this);
  }

  MeGet401ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _error = $v.error;
      _message = $v.message;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MeGet401Response other) {
    _$v = other as _$MeGet401Response;
  }

  @override
  void update(void Function(MeGet401ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MeGet401Response build() => _build();

  _$MeGet401Response _build() {
    final _$result = _$v ??
        _$MeGet401Response._(
          error: BuiltValueNullFieldError.checkNotNull(
              error, r'MeGet401Response', 'error'),
          message: BuiltValueNullFieldError.checkNotNull(
              message, r'MeGet401Response', 'message'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
