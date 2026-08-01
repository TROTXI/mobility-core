// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'me_avatar_get200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MeAvatarGet200Response extends MeAvatarGet200Response {
  @override
  final String avatarUrl;

  factory _$MeAvatarGet200Response(
          [void Function(MeAvatarGet200ResponseBuilder)? updates]) =>
      (MeAvatarGet200ResponseBuilder()..update(updates))._build();

  _$MeAvatarGet200Response._({required this.avatarUrl}) : super._();
  @override
  MeAvatarGet200Response rebuild(
          void Function(MeAvatarGet200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MeAvatarGet200ResponseBuilder toBuilder() =>
      MeAvatarGet200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MeAvatarGet200Response && avatarUrl == other.avatarUrl;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, avatarUrl.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MeAvatarGet200Response')
          ..add('avatarUrl', avatarUrl))
        .toString();
  }
}

class MeAvatarGet200ResponseBuilder
    implements Builder<MeAvatarGet200Response, MeAvatarGet200ResponseBuilder> {
  _$MeAvatarGet200Response? _$v;

  String? _avatarUrl;
  String? get avatarUrl => _$this._avatarUrl;
  set avatarUrl(String? avatarUrl) => _$this._avatarUrl = avatarUrl;

  MeAvatarGet200ResponseBuilder() {
    MeAvatarGet200Response._defaults(this);
  }

  MeAvatarGet200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _avatarUrl = $v.avatarUrl;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MeAvatarGet200Response other) {
    _$v = other as _$MeAvatarGet200Response;
  }

  @override
  void update(void Function(MeAvatarGet200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MeAvatarGet200Response build() => _build();

  _$MeAvatarGet200Response _build() {
    final _$result = _$v ??
        _$MeAvatarGet200Response._(
          avatarUrl: BuiltValueNullFieldError.checkNotNull(
              avatarUrl, r'MeAvatarGet200Response', 'avatarUrl'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
