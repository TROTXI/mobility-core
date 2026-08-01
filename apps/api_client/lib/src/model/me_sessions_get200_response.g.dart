// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'me_sessions_get200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MeSessionsGet200Response extends MeSessionsGet200Response {
  @override
  final BuiltList<MeSessionsGet200ResponseSessionsInner> sessions;

  factory _$MeSessionsGet200Response(
          [void Function(MeSessionsGet200ResponseBuilder)? updates]) =>
      (MeSessionsGet200ResponseBuilder()..update(updates))._build();

  _$MeSessionsGet200Response._({required this.sessions}) : super._();
  @override
  MeSessionsGet200Response rebuild(
          void Function(MeSessionsGet200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MeSessionsGet200ResponseBuilder toBuilder() =>
      MeSessionsGet200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MeSessionsGet200Response && sessions == other.sessions;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, sessions.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MeSessionsGet200Response')
          ..add('sessions', sessions))
        .toString();
  }
}

class MeSessionsGet200ResponseBuilder
    implements
        Builder<MeSessionsGet200Response, MeSessionsGet200ResponseBuilder> {
  _$MeSessionsGet200Response? _$v;

  ListBuilder<MeSessionsGet200ResponseSessionsInner>? _sessions;
  ListBuilder<MeSessionsGet200ResponseSessionsInner> get sessions =>
      _$this._sessions ??= ListBuilder<MeSessionsGet200ResponseSessionsInner>();
  set sessions(ListBuilder<MeSessionsGet200ResponseSessionsInner>? sessions) =>
      _$this._sessions = sessions;

  MeSessionsGet200ResponseBuilder() {
    MeSessionsGet200Response._defaults(this);
  }

  MeSessionsGet200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _sessions = $v.sessions.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MeSessionsGet200Response other) {
    _$v = other as _$MeSessionsGet200Response;
  }

  @override
  void update(void Function(MeSessionsGet200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MeSessionsGet200Response build() => _build();

  _$MeSessionsGet200Response _build() {
    _$MeSessionsGet200Response _$result;
    try {
      _$result = _$v ??
          _$MeSessionsGet200Response._(
            sessions: sessions.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'sessions';
        sessions.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'MeSessionsGet200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
