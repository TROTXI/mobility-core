// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flags_get200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$FlagsGet200Response extends FlagsGet200Response {
  @override
  final BuiltList<FlagsGet200ResponseFlagsInner> flags;
  @override
  final FlagsGet200ResponseMinSupportedVersion minSupportedVersion;

  factory _$FlagsGet200Response(
          [void Function(FlagsGet200ResponseBuilder)? updates]) =>
      (FlagsGet200ResponseBuilder()..update(updates))._build();

  _$FlagsGet200Response._(
      {required this.flags, required this.minSupportedVersion})
      : super._();
  @override
  FlagsGet200Response rebuild(
          void Function(FlagsGet200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FlagsGet200ResponseBuilder toBuilder() =>
      FlagsGet200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FlagsGet200Response &&
        flags == other.flags &&
        minSupportedVersion == other.minSupportedVersion;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, flags.hashCode);
    _$hash = $jc(_$hash, minSupportedVersion.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FlagsGet200Response')
          ..add('flags', flags)
          ..add('minSupportedVersion', minSupportedVersion))
        .toString();
  }
}

class FlagsGet200ResponseBuilder
    implements Builder<FlagsGet200Response, FlagsGet200ResponseBuilder> {
  _$FlagsGet200Response? _$v;

  ListBuilder<FlagsGet200ResponseFlagsInner>? _flags;
  ListBuilder<FlagsGet200ResponseFlagsInner> get flags =>
      _$this._flags ??= ListBuilder<FlagsGet200ResponseFlagsInner>();
  set flags(ListBuilder<FlagsGet200ResponseFlagsInner>? flags) =>
      _$this._flags = flags;

  FlagsGet200ResponseMinSupportedVersionBuilder? _minSupportedVersion;
  FlagsGet200ResponseMinSupportedVersionBuilder get minSupportedVersion =>
      _$this._minSupportedVersion ??=
          FlagsGet200ResponseMinSupportedVersionBuilder();
  set minSupportedVersion(
          FlagsGet200ResponseMinSupportedVersionBuilder? minSupportedVersion) =>
      _$this._minSupportedVersion = minSupportedVersion;

  FlagsGet200ResponseBuilder() {
    FlagsGet200Response._defaults(this);
  }

  FlagsGet200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _flags = $v.flags.toBuilder();
      _minSupportedVersion = $v.minSupportedVersion.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FlagsGet200Response other) {
    _$v = other as _$FlagsGet200Response;
  }

  @override
  void update(void Function(FlagsGet200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FlagsGet200Response build() => _build();

  _$FlagsGet200Response _build() {
    _$FlagsGet200Response _$result;
    try {
      _$result = _$v ??
          _$FlagsGet200Response._(
            flags: flags.build(),
            minSupportedVersion: minSupportedVersion.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'flags';
        flags.build();
        _$failedField = 'minSupportedVersion';
        minSupportedVersion.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'FlagsGet200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
