// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_expire_subscriptions_post200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminExpireSubscriptionsPost200Response
    extends AdminExpireSubscriptionsPost200Response {
  @override
  final int expired;
  @override
  final int considered;

  factory _$AdminExpireSubscriptionsPost200Response(
          [void Function(AdminExpireSubscriptionsPost200ResponseBuilder)?
              updates]) =>
      (AdminExpireSubscriptionsPost200ResponseBuilder()..update(updates))
          ._build();

  _$AdminExpireSubscriptionsPost200Response._(
      {required this.expired, required this.considered})
      : super._();
  @override
  AdminExpireSubscriptionsPost200Response rebuild(
          void Function(AdminExpireSubscriptionsPost200ResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminExpireSubscriptionsPost200ResponseBuilder toBuilder() =>
      AdminExpireSubscriptionsPost200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminExpireSubscriptionsPost200Response &&
        expired == other.expired &&
        considered == other.considered;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, expired.hashCode);
    _$hash = $jc(_$hash, considered.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'AdminExpireSubscriptionsPost200Response')
          ..add('expired', expired)
          ..add('considered', considered))
        .toString();
  }
}

class AdminExpireSubscriptionsPost200ResponseBuilder
    implements
        Builder<AdminExpireSubscriptionsPost200Response,
            AdminExpireSubscriptionsPost200ResponseBuilder> {
  _$AdminExpireSubscriptionsPost200Response? _$v;

  int? _expired;
  int? get expired => _$this._expired;
  set expired(int? expired) => _$this._expired = expired;

  int? _considered;
  int? get considered => _$this._considered;
  set considered(int? considered) => _$this._considered = considered;

  AdminExpireSubscriptionsPost200ResponseBuilder() {
    AdminExpireSubscriptionsPost200Response._defaults(this);
  }

  AdminExpireSubscriptionsPost200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _expired = $v.expired;
      _considered = $v.considered;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminExpireSubscriptionsPost200Response other) {
    _$v = other as _$AdminExpireSubscriptionsPost200Response;
  }

  @override
  void update(
      void Function(AdminExpireSubscriptionsPost200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminExpireSubscriptionsPost200Response build() => _build();

  _$AdminExpireSubscriptionsPost200Response _build() {
    final _$result = _$v ??
        _$AdminExpireSubscriptionsPost200Response._(
          expired: BuiltValueNullFieldError.checkNotNull(
              expired, r'AdminExpireSubscriptionsPost200Response', 'expired'),
          considered: BuiltValueNullFieldError.checkNotNull(considered,
              r'AdminExpireSubscriptionsPost200Response', 'considered'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
