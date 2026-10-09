// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_update.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ProfileUpdate extends ProfileUpdate {
  @override
  final String? displayName;
  @override
  final String? firstName;
  @override
  final String? lastName;
  @override
  final String? otherNames;

  factory _$ProfileUpdate([void Function(ProfileUpdateBuilder)? updates]) =>
      (ProfileUpdateBuilder()..update(updates))._build();

  _$ProfileUpdate._(
      {this.displayName, this.firstName, this.lastName, this.otherNames})
      : super._();
  @override
  ProfileUpdate rebuild(void Function(ProfileUpdateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ProfileUpdateBuilder toBuilder() => ProfileUpdateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ProfileUpdate &&
        displayName == other.displayName &&
        firstName == other.firstName &&
        lastName == other.lastName &&
        otherNames == other.otherNames;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jc(_$hash, firstName.hashCode);
    _$hash = $jc(_$hash, lastName.hashCode);
    _$hash = $jc(_$hash, otherNames.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ProfileUpdate')
          ..add('displayName', displayName)
          ..add('firstName', firstName)
          ..add('lastName', lastName)
          ..add('otherNames', otherNames))
        .toString();
  }
}

class ProfileUpdateBuilder
    implements Builder<ProfileUpdate, ProfileUpdateBuilder> {
  _$ProfileUpdate? _$v;

  String? _displayName;
  String? get displayName => _$this._displayName;
  set displayName(String? displayName) => _$this._displayName = displayName;

  String? _firstName;
  String? get firstName => _$this._firstName;
  set firstName(String? firstName) => _$this._firstName = firstName;

  String? _lastName;
  String? get lastName => _$this._lastName;
  set lastName(String? lastName) => _$this._lastName = lastName;

  String? _otherNames;
  String? get otherNames => _$this._otherNames;
  set otherNames(String? otherNames) => _$this._otherNames = otherNames;

  ProfileUpdateBuilder() {
    ProfileUpdate._defaults(this);
  }

  ProfileUpdateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _displayName = $v.displayName;
      _firstName = $v.firstName;
      _lastName = $v.lastName;
      _otherNames = $v.otherNames;
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
          displayName: displayName,
          firstName: firstName,
          lastName: lastName,
          otherNames: otherNames,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
