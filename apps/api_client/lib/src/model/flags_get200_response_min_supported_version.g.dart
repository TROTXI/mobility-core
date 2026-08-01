// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flags_get200_response_min_supported_version.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$FlagsGet200ResponseMinSupportedVersion
    extends FlagsGet200ResponseMinSupportedVersion {
  @override
  final String? ios;
  @override
  final String? android;

  factory _$FlagsGet200ResponseMinSupportedVersion(
          [void Function(FlagsGet200ResponseMinSupportedVersionBuilder)?
              updates]) =>
      (FlagsGet200ResponseMinSupportedVersionBuilder()..update(updates))
          ._build();

  _$FlagsGet200ResponseMinSupportedVersion._({this.ios, this.android})
      : super._();
  @override
  FlagsGet200ResponseMinSupportedVersion rebuild(
          void Function(FlagsGet200ResponseMinSupportedVersionBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FlagsGet200ResponseMinSupportedVersionBuilder toBuilder() =>
      FlagsGet200ResponseMinSupportedVersionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FlagsGet200ResponseMinSupportedVersion &&
        ios == other.ios &&
        android == other.android;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, ios.hashCode);
    _$hash = $jc(_$hash, android.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'FlagsGet200ResponseMinSupportedVersion')
          ..add('ios', ios)
          ..add('android', android))
        .toString();
  }
}

class FlagsGet200ResponseMinSupportedVersionBuilder
    implements
        Builder<FlagsGet200ResponseMinSupportedVersion,
            FlagsGet200ResponseMinSupportedVersionBuilder> {
  _$FlagsGet200ResponseMinSupportedVersion? _$v;

  String? _ios;
  String? get ios => _$this._ios;
  set ios(String? ios) => _$this._ios = ios;

  String? _android;
  String? get android => _$this._android;
  set android(String? android) => _$this._android = android;

  FlagsGet200ResponseMinSupportedVersionBuilder() {
    FlagsGet200ResponseMinSupportedVersion._defaults(this);
  }

  FlagsGet200ResponseMinSupportedVersionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _ios = $v.ios;
      _android = $v.android;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FlagsGet200ResponseMinSupportedVersion other) {
    _$v = other as _$FlagsGet200ResponseMinSupportedVersion;
  }

  @override
  void update(
      void Function(FlagsGet200ResponseMinSupportedVersionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FlagsGet200ResponseMinSupportedVersion build() => _build();

  _$FlagsGet200ResponseMinSupportedVersion _build() {
    final _$result = _$v ??
        _$FlagsGet200ResponseMinSupportedVersion._(
          ios: ios,
          android: android,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
