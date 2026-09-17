// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_update.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ProfileUpdate extends ProfileUpdate {
  @override
  final String displayName;

  factory _$ProfileUpdate([void Function(ProfileUpdateBuilder)? updates]) =>
      (ProfileUpdateBuilder()..update(updates))._build();

  _$ProfileUpdate._({required this.displayName}) : super._();
  @override
  ProfileUpdate rebuild(void Function(ProfileUpdateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ProfileUpdateBuilder toBuilder() => ProfileUpdateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ProfileUpdate && displayName == other.displayName;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ProfileUpdate')
          ..add('displayName', displayName))
        .toString();
  }
}

class ProfileUpdateBuilder
    implements Builder<ProfileUpdate, ProfileUpdateBuilder> {
  _$ProfileUpdate? _$v;

  String? _displayName;
  String? get displayName => _$this._displayName;
  set displayName(String? displayName) => _$this._displayName = displayName;

  ProfileUpdateBuilder() {
    ProfileUpdate._defaults(this);
  }

  ProfileUpdateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _displayName = $v.displayName;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ProfileUpdate other) {
    _$v = other as _$ProfileUpdate;
  }

  @override
  void update(void Function(ProfileUpdateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ProfileUpdate build() => _build();

  _$ProfileUpdate _build() {
    final _$result = _$v ??
        _$ProfileUpdate._(
          displayName: BuiltValueNullFieldError.checkNotNull(
              displayName, r'ProfileUpdate', 'displayName'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
