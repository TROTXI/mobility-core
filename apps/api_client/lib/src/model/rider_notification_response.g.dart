// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rider_notification_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RiderNotificationResponse extends RiderNotificationResponse {
  @override
  final RiderNotification data;

  factory _$RiderNotificationResponse(
          [void Function(RiderNotificationResponseBuilder)? updates]) =>
      (RiderNotificationResponseBuilder()..update(updates))._build();

  _$RiderNotificationResponse._({required this.data}) : super._();
  @override
  RiderNotificationResponse rebuild(
          void Function(RiderNotificationResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RiderNotificationResponseBuilder toBuilder() =>
      RiderNotificationResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RiderNotificationResponse && data == other.data;
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
    return (newBuiltValueToStringHelper(r'RiderNotificationResponse')
          ..add('data', data))
        .toString();
  }
}

class RiderNotificationResponseBuilder
    implements
        Builder<RiderNotificationResponse, RiderNotificationResponseBuilder> {
  _$RiderNotificationResponse? _$v;

  RiderNotificationBuilder? _data;
  RiderNotificationBuilder get data =>
      _$this._data ??= RiderNotificationBuilder();
  set data(RiderNotificationBuilder? data) => _$this._data = data;

  RiderNotificationResponseBuilder() {
    RiderNotificationResponse._defaults(this);
  }

  RiderNotificationResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RiderNotificationResponse other) {
    _$v = other as _$RiderNotificationResponse;
  }

  @override
  void update(void Function(RiderNotificationResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RiderNotificationResponse build() => _build();

  _$RiderNotificationResponse _build() {
    _$RiderNotificationResponse _$result;
    try {
      _$result = _$v ??
          _$RiderNotificationResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'RiderNotificationResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
