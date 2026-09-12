// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_learn_routes_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminLearnRoutesPostRequest extends AdminLearnRoutesPostRequest {
  @override
  final String? routeId;

  factory _$AdminLearnRoutesPostRequest(
          [void Function(AdminLearnRoutesPostRequestBuilder)? updates]) =>
      (AdminLearnRoutesPostRequestBuilder()..update(updates))._build();

  _$AdminLearnRoutesPostRequest._({this.routeId}) : super._();
  @override
  AdminLearnRoutesPostRequest rebuild(
          void Function(AdminLearnRoutesPostRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminLearnRoutesPostRequestBuilder toBuilder() =>
      AdminLearnRoutesPostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminLearnRoutesPostRequest && routeId == other.routeId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, routeId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminLearnRoutesPostRequest')
          ..add('routeId', routeId))
        .toString();
  }
}

class AdminLearnRoutesPostRequestBuilder
    implements
        Builder<AdminLearnRoutesPostRequest,
            AdminLearnRoutesPostRequestBuilder> {
  _$AdminLearnRoutesPostRequest? _$v;

  String? _routeId;
  String? get routeId => _$this._routeId;
  set routeId(String? routeId) => _$this._routeId = routeId;

  AdminLearnRoutesPostRequestBuilder() {
    AdminLearnRoutesPostRequest._defaults(this);
  }

  AdminLearnRoutesPostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _routeId = $v.routeId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminLearnRoutesPostRequest other) {
    _$v = other as _$AdminLearnRoutesPostRequest;
  }

  @override
  void update(void Function(AdminLearnRoutesPostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminLearnRoutesPostRequest build() => _build();

  _$AdminLearnRoutesPostRequest _build() {
    final _$result = _$v ??
        _$AdminLearnRoutesPostRequest._(
          routeId: routeId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
