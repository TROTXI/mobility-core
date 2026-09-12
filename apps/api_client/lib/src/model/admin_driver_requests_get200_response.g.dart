// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_driver_requests_get200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminDriverRequestsGet200Response
    extends AdminDriverRequestsGet200Response {
  @override
  final BuiltList<AdminDriverRequestsGet200ResponseRequestsInner> requests;

  factory _$AdminDriverRequestsGet200Response(
          [void Function(AdminDriverRequestsGet200ResponseBuilder)? updates]) =>
      (AdminDriverRequestsGet200ResponseBuilder()..update(updates))._build();

  _$AdminDriverRequestsGet200Response._({required this.requests}) : super._();
  @override
  AdminDriverRequestsGet200Response rebuild(
          void Function(AdminDriverRequestsGet200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminDriverRequestsGet200ResponseBuilder toBuilder() =>
      AdminDriverRequestsGet200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminDriverRequestsGet200Response &&
        requests == other.requests;
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
    return (newBuiltValueToStringHelper(r'AdminDriverRequestsGet200Response')
          ..add('requests', requests))
        .toString();
  }
}

class AdminDriverRequestsGet200ResponseBuilder
    implements
        Builder<AdminDriverRequestsGet200Response,
            AdminDriverRequestsGet200ResponseBuilder> {
  _$AdminDriverRequestsGet200Response? _$v;

  ListBuilder<AdminDriverRequestsGet200ResponseRequestsInner>? _requests;
  ListBuilder<AdminDriverRequestsGet200ResponseRequestsInner> get requests =>
      _$this._requests ??=
          ListBuilder<AdminDriverRequestsGet200ResponseRequestsInner>();
  set requests(
          ListBuilder<AdminDriverRequestsGet200ResponseRequestsInner>?
              requests) =>
      _$this._requests = requests;

  AdminDriverRequestsGet200ResponseBuilder() {
    AdminDriverRequestsGet200Response._defaults(this);
  }

  AdminDriverRequestsGet200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _requests = $v.requests.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminDriverRequestsGet200Response other) {
    _$v = other as _$AdminDriverRequestsGet200Response;
  }

  @override
  void update(
      void Function(AdminDriverRequestsGet200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminDriverRequestsGet200Response build() => _build();

  _$AdminDriverRequestsGet200Response _build() {
    _$AdminDriverRequestsGet200Response _$result;
    try {
      _$result = _$v ??
          _$AdminDriverRequestsGet200Response._(
            requests: requests.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'requests';
        requests.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'AdminDriverRequestsGet200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
