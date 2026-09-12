// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'me_work_requests_get200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MeWorkRequestsGet200Response extends MeWorkRequestsGet200Response {
  @override
  final BuiltList<MeWorkRequestsGet200ResponseRequestsInner> requests;

  factory _$MeWorkRequestsGet200Response(
          [void Function(MeWorkRequestsGet200ResponseBuilder)? updates]) =>
      (MeWorkRequestsGet200ResponseBuilder()..update(updates))._build();

  _$MeWorkRequestsGet200Response._({required this.requests}) : super._();
  @override
  MeWorkRequestsGet200Response rebuild(
          void Function(MeWorkRequestsGet200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MeWorkRequestsGet200ResponseBuilder toBuilder() =>
      MeWorkRequestsGet200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MeWorkRequestsGet200Response && requests == other.requests;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, requests.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MeWorkRequestsGet200Response')
          ..add('requests', requests))
        .toString();
  }
}

class MeWorkRequestsGet200ResponseBuilder
    implements
        Builder<MeWorkRequestsGet200Response,
            MeWorkRequestsGet200ResponseBuilder> {
  _$MeWorkRequestsGet200Response? _$v;

  ListBuilder<MeWorkRequestsGet200ResponseRequestsInner>? _requests;
  ListBuilder<MeWorkRequestsGet200ResponseRequestsInner> get requests =>
      _$this._requests ??=
          ListBuilder<MeWorkRequestsGet200ResponseRequestsInner>();
  set requests(
          ListBuilder<MeWorkRequestsGet200ResponseRequestsInner>? requests) =>
      _$this._requests = requests;

  MeWorkRequestsGet200ResponseBuilder() {
    MeWorkRequestsGet200Response._defaults(this);
  }

  MeWorkRequestsGet200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _requests = $v.requests.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MeWorkRequestsGet200Response other) {
    _$v = other as _$MeWorkRequestsGet200Response;
  }

  @override
  void update(void Function(MeWorkRequestsGet200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MeWorkRequestsGet200Response build() => _build();

  _$MeWorkRequestsGet200Response _build() {
    _$MeWorkRequestsGet200Response _$result;
    try {
      _$result = _$v ??
          _$MeWorkRequestsGet200Response._(
            requests: requests.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'requests';
        requests.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'MeWorkRequestsGet200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
