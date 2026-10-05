// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auto_renewal.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AutoRenewal extends AutoRenewal {
  @override
  final bool enabled;
  @override
  final AutoRenewalCard? card;
  @override
  final AutoRenewalUpcoming? upcoming;

  factory _$AutoRenewal([void Function(AutoRenewalBuilder)? updates]) =>
      (AutoRenewalBuilder()..update(updates))._build();

  _$AutoRenewal._({required this.enabled, this.card, this.upcoming})
      : super._();
  @override
  AutoRenewal rebuild(void Function(AutoRenewalBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AutoRenewalBuilder toBuilder() => AutoRenewalBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AutoRenewal &&
        enabled == other.enabled &&
        card == other.card &&
        upcoming == other.upcoming;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, enabled.hashCode);
    _$hash = $jc(_$hash, card.hashCode);
    _$hash = $jc(_$hash, upcoming.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AutoRenewal')
          ..add('enabled', enabled)
          ..add('card', card)
          ..add('upcoming', upcoming))
        .toString();
  }
}

class AutoRenewalBuilder implements Builder<AutoRenewal, AutoRenewalBuilder> {
  _$AutoRenewal? _$v;

  bool? _enabled;
  bool? get enabled => _$this._enabled;
  set enabled(bool? enabled) => _$this._enabled = enabled;

  AutoRenewalCardBuilder? _card;
  AutoRenewalCardBuilder get card => _$this._card ??= AutoRenewalCardBuilder();
  set card(AutoRenewalCardBuilder? card) => _$this._card = card;

  AutoRenewalUpcomingBuilder? _upcoming;
  AutoRenewalUpcomingBuilder get upcoming =>
      _$this._upcoming ??= AutoRenewalUpcomingBuilder();
  set upcoming(AutoRenewalUpcomingBuilder? upcoming) =>
      _$this._upcoming = upcoming;

  AutoRenewalBuilder() {
    AutoRenewal._defaults(this);
  }

  AutoRenewalBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _enabled = $v.enabled;
      _card = $v.card?.toBuilder();
      _upcoming = $v.upcoming?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AutoRenewal other) {
    _$v = other as _$AutoRenewal;
  }

  @override
  void update(void Function(AutoRenewalBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AutoRenewal build() => _build();

  _$AutoRenewal _build() {
    _$AutoRenewal _$result;
    try {
      _$result = _$v ??
          _$AutoRenewal._(
            enabled: BuiltValueNullFieldError.checkNotNull(
                enabled, r'AutoRenewal', 'enabled'),
            card: _card?.build(),
            upcoming: _upcoming?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'card';
        _card?.build();
        _$failedField = 'upcoming';
        _upcoming?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'AutoRenewal', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
