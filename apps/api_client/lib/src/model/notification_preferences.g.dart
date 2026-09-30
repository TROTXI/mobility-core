// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_preferences.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$NotificationPreferences extends NotificationPreferences {
  @override
  final String dailyAskTime;
  @override
  final bool optionalUpdatesEnabled;
  @override
  final DateTime updatedAt;
  @override
  final int version;

  factory _$NotificationPreferences(
          [void Function(NotificationPreferencesBuilder)? updates]) =>
      (NotificationPreferencesBuilder()..update(updates))._build();

  _$NotificationPreferences._(
      {required this.dailyAskTime,
      required this.optionalUpdatesEnabled,
      required this.updatedAt,
      required this.version})
      : super._();
  @override
  NotificationPreferences rebuild(
          void Function(NotificationPreferencesBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  NotificationPreferencesBuilder toBuilder() =>
      NotificationPreferencesBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NotificationPreferences &&
        dailyAskTime == other.dailyAskTime &&
        optionalUpdatesEnabled == other.optionalUpdatesEnabled &&
        updatedAt == other.updatedAt &&
        version == other.version;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, dailyAskTime.hashCode);
    _$hash = $jc(_$hash, optionalUpdatesEnabled.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'NotificationPreferences')
          ..add('dailyAskTime', dailyAskTime)
          ..add('optionalUpdatesEnabled', optionalUpdatesEnabled)
          ..add('updatedAt', updatedAt)
          ..add('version', version))
        .toString();
  }
}

class NotificationPreferencesBuilder
    implements
        Builder<NotificationPreferences, NotificationPreferencesBuilder> {
  _$NotificationPreferences? _$v;

  String? _dailyAskTime;
  String? get dailyAskTime => _$this._dailyAskTime;
  set dailyAskTime(String? dailyAskTime) => _$this._dailyAskTime = dailyAskTime;

  bool? _optionalUpdatesEnabled;
  bool? get optionalUpdatesEnabled => _$this._optionalUpdatesEnabled;
  set optionalUpdatesEnabled(bool? optionalUpdatesEnabled) =>
      _$this._optionalUpdatesEnabled = optionalUpdatesEnabled;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  int? _version;
  int? get version => _$this._version;
  set version(int? version) => _$this._version = version;

  NotificationPreferencesBuilder() {
    NotificationPreferences._defaults(this);
  }

  NotificationPreferencesBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _dailyAskTime = $v.dailyAskTime;
      _optionalUpdatesEnabled = $v.optionalUpdatesEnabled;
      _updatedAt = $v.updatedAt;
      _version = $v.version;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(NotificationPreferences other) {
    _$v = other as _$NotificationPreferences;
  }

  @override
  void update(void Function(NotificationPreferencesBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  NotificationPreferences build() => _build();

  _$NotificationPreferences _build() {
    final _$result = _$v ??
        _$NotificationPreferences._(
          dailyAskTime: BuiltValueNullFieldError.checkNotNull(
              dailyAskTime, r'NotificationPreferences', 'dailyAskTime'),
          optionalUpdatesEnabled: BuiltValueNullFieldError.checkNotNull(
              optionalUpdatesEnabled,
              r'NotificationPreferences',
              'optionalUpdatesEnabled'),
          updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt, r'NotificationPreferences', 'updatedAt'),
          version: BuiltValueNullFieldError.checkNotNull(
              version, r'NotificationPreferences', 'version'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
