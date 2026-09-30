// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_preferences_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$NotificationPreferencesInput extends NotificationPreferencesInput {
  @override
  final String dailyAskTime;
  @override
  final bool optionalUpdatesEnabled;

  factory _$NotificationPreferencesInput(
          [void Function(NotificationPreferencesInputBuilder)? updates]) =>
      (NotificationPreferencesInputBuilder()..update(updates))._build();

  _$NotificationPreferencesInput._(
      {required this.dailyAskTime, required this.optionalUpdatesEnabled})
      : super._();
  @override
  NotificationPreferencesInput rebuild(
          void Function(NotificationPreferencesInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  NotificationPreferencesInputBuilder toBuilder() =>
      NotificationPreferencesInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NotificationPreferencesInput &&
        dailyAskTime == other.dailyAskTime &&
        optionalUpdatesEnabled == other.optionalUpdatesEnabled;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, dailyAskTime.hashCode);
    _$hash = $jc(_$hash, optionalUpdatesEnabled.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'NotificationPreferencesInput')
          ..add('dailyAskTime', dailyAskTime)
          ..add('optionalUpdatesEnabled', optionalUpdatesEnabled))
        .toString();
  }
}

class NotificationPreferencesInputBuilder
    implements
        Builder<NotificationPreferencesInput,
            NotificationPreferencesInputBuilder> {
  _$NotificationPreferencesInput? _$v;

  String? _dailyAskTime;
  String? get dailyAskTime => _$this._dailyAskTime;
  set dailyAskTime(String? dailyAskTime) => _$this._dailyAskTime = dailyAskTime;

  bool? _optionalUpdatesEnabled;
  bool? get optionalUpdatesEnabled => _$this._optionalUpdatesEnabled;
  set optionalUpdatesEnabled(bool? optionalUpdatesEnabled) =>
      _$this._optionalUpdatesEnabled = optionalUpdatesEnabled;

  NotificationPreferencesInputBuilder() {
    NotificationPreferencesInput._defaults(this);
  }

  NotificationPreferencesInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _dailyAskTime = $v.dailyAskTime;
      _optionalUpdatesEnabled = $v.optionalUpdatesEnabled;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(NotificationPreferencesInput other) {
    _$v = other as _$NotificationPreferencesInput;
  }

  @override
  void update(void Function(NotificationPreferencesInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  NotificationPreferencesInput build() => _build();

  _$NotificationPreferencesInput _build() {
    final _$result = _$v ??
        _$NotificationPreferencesInput._(
          dailyAskTime: BuiltValueNullFieldError.checkNotNull(
              dailyAskTime, r'NotificationPreferencesInput', 'dailyAskTime'),
          optionalUpdatesEnabled: BuiltValueNullFieldError.checkNotNull(
              optionalUpdatesEnabled,
              r'NotificationPreferencesInput',
              'optionalUpdatesEnabled'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
