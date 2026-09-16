// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_edit.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TripEdit extends TripEdit {
  @override
  final DateTime scheduledAt;

  factory _$TripEdit([void Function(TripEditBuilder)? updates]) =>
      (TripEditBuilder()..update(updates))._build();

  _$TripEdit._({required this.scheduledAt}) : super._();
  @override
  TripEdit rebuild(void Function(TripEditBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TripEditBuilder toBuilder() => TripEditBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TripEdit && scheduledAt == other.scheduledAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, scheduledAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TripEdit')
          ..add('scheduledAt', scheduledAt))
        .toString();
  }
}

class TripEditBuilder implements Builder<TripEdit, TripEditBuilder> {
  _$TripEdit? _$v;

  DateTime? _scheduledAt;
  DateTime? get scheduledAt => _$this._scheduledAt;
  set scheduledAt(DateTime? scheduledAt) => _$this._scheduledAt = scheduledAt;

  TripEditBuilder() {
    TripEdit._defaults(this);
  }

  TripEditBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _scheduledAt = $v.scheduledAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TripEdit other) {
    _$v = other as _$TripEdit;
  }

  @override
  void update(void Function(TripEditBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TripEdit build() => _build();

  _$TripEdit _build() {
    final _$result = _$v ??
        _$TripEdit._(
          scheduledAt: BuiltValueNullFieldError.checkNotNull(
              scheduledAt, r'TripEdit', 'scheduledAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
