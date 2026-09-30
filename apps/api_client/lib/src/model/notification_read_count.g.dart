// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_read_count.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$NotificationReadCount extends NotificationReadCount {
  @override
  final int readCount;

  factory _$NotificationReadCount(
          [void Function(NotificationReadCountBuilder)? updates]) =>
      (NotificationReadCountBuilder()..update(updates))._build();

  _$NotificationReadCount._({required this.readCount}) : super._();
  @override
  NotificationReadCount rebuild(
          void Function(NotificationReadCountBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  NotificationReadCountBuilder toBuilder() =>
      NotificationReadCountBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NotificationReadCount && readCount == other.readCount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, readCount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'NotificationReadCount')
          ..add('readCount', readCount))
        .toString();
  }
}

class NotificationReadCountBuilder
    implements Builder<NotificationReadCount, NotificationReadCountBuilder> {
  _$NotificationReadCount? _$v;

  int? _readCount;
  int? get readCount => _$this._readCount;
  set readCount(int? readCount) => _$this._readCount = readCount;

  NotificationReadCountBuilder() {
    NotificationReadCount._defaults(this);
  }

  NotificationReadCountBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _readCount = $v.readCount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(NotificationReadCount other) {
    _$v = other as _$NotificationReadCount;
  }

  @override
  void update(void Function(NotificationReadCountBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  NotificationReadCount build() => _build();

  _$NotificationReadCount _build() {
    final _$result = _$v ??
        _$NotificationReadCount._(
          readCount: BuiltValueNullFieldError.checkNotNull(
              readCount, r'NotificationReadCount', 'readCount'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
