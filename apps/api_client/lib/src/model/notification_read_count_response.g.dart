// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_read_count_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$NotificationReadCountResponse extends NotificationReadCountResponse {
  @override
  final NotificationReadCount data;

  factory _$NotificationReadCountResponse(
          [void Function(NotificationReadCountResponseBuilder)? updates]) =>
      (NotificationReadCountResponseBuilder()..update(updates))._build();

  _$NotificationReadCountResponse._({required this.data}) : super._();
  @override
  NotificationReadCountResponse rebuild(
          void Function(NotificationReadCountResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  NotificationReadCountResponseBuilder toBuilder() =>
      NotificationReadCountResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NotificationReadCountResponse && data == other.data;
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
    return (newBuiltValueToStringHelper(r'NotificationReadCountResponse')
          ..add('data', data))
        .toString();
  }
}

class NotificationReadCountResponseBuilder
    implements
        Builder<NotificationReadCountResponse,
            NotificationReadCountResponseBuilder> {
  _$NotificationReadCountResponse? _$v;

  NotificationReadCountBuilder? _data;
  NotificationReadCountBuilder get data =>
      _$this._data ??= NotificationReadCountBuilder();
  set data(NotificationReadCountBuilder? data) => _$this._data = data;

  NotificationReadCountResponseBuilder() {
    NotificationReadCountResponse._defaults(this);
  }

  NotificationReadCountResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(NotificationReadCountResponse other) {
    _$v = other as _$NotificationReadCountResponse;
  }

  @override
  void update(void Function(NotificationReadCountResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  NotificationReadCountResponse build() => _build();

  _$NotificationReadCountResponse _build() {
    _$NotificationReadCountResponse _$result;
    try {
      _$result = _$v ??
          _$NotificationReadCountResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'NotificationReadCountResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
