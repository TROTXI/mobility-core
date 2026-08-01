// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'me_pass_get200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MePassGet200Response extends MePassGet200Response {
  @override
  final String pass;
  @override
  final int expiresInSeconds;

  factory _$MePassGet200Response(
          [void Function(MePassGet200ResponseBuilder)? updates]) =>
      (MePassGet200ResponseBuilder()..update(updates))._build();

  _$MePassGet200Response._({required this.pass, required this.expiresInSeconds})
      : super._();
  @override
  MePassGet200Response rebuild(
          void Function(MePassGet200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MePassGet200ResponseBuilder toBuilder() =>
      MePassGet200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MePassGet200Response &&
        pass == other.pass &&
        expiresInSeconds == other.expiresInSeconds;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, pass.hashCode);
    _$hash = $jc(_$hash, expiresInSeconds.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MePassGet200Response')
          ..add('pass', pass)
          ..add('expiresInSeconds', expiresInSeconds))
        .toString();
  }
}

class MePassGet200ResponseBuilder
    implements Builder<MePassGet200Response, MePassGet200ResponseBuilder> {
  _$MePassGet200Response? _$v;

  String? _pass;
  String? get pass => _$this._pass;
  set pass(String? pass) => _$this._pass = pass;

  int? _expiresInSeconds;
  int? get expiresInSeconds => _$this._expiresInSeconds;
  set expiresInSeconds(int? expiresInSeconds) =>
      _$this._expiresInSeconds = expiresInSeconds;

  MePassGet200ResponseBuilder() {
    MePassGet200Response._defaults(this);
  }

  MePassGet200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _pass = $v.pass;
      _expiresInSeconds = $v.expiresInSeconds;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MePassGet200Response other) {
    _$v = other as _$MePassGet200Response;
  }

  @override
  void update(void Function(MePassGet200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MePassGet200Response build() => _build();

  _$MePassGet200Response _build() {
    final _$result = _$v ??
        _$MePassGet200Response._(
          pass: BuiltValueNullFieldError.checkNotNull(
              pass, r'MePassGet200Response', 'pass'),
          expiresInSeconds: BuiltValueNullFieldError.checkNotNull(
              expiresInSeconds, r'MePassGet200Response', 'expiresInSeconds'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
