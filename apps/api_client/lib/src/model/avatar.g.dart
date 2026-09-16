// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'avatar.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Avatar extends Avatar {
  @override
  final String url;
  @override
  final DateTime expiresAt;

  factory _$Avatar([void Function(AvatarBuilder)? updates]) =>
      (AvatarBuilder()..update(updates))._build();

  _$Avatar._({required this.url, required this.expiresAt}) : super._();
  @override
  Avatar rebuild(void Function(AvatarBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AvatarBuilder toBuilder() => AvatarBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Avatar && url == other.url && expiresAt == other.expiresAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, url.hashCode);
    _$hash = $jc(_$hash, expiresAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Avatar')
          ..add('url', url)
          ..add('expiresAt', expiresAt))
        .toString();
  }
}

class AvatarBuilder implements Builder<Avatar, AvatarBuilder> {
  _$Avatar? _$v;

  String? _url;
  String? get url => _$this._url;
  set url(String? url) => _$this._url = url;

  DateTime? _expiresAt;
  DateTime? get expiresAt => _$this._expiresAt;
  set expiresAt(DateTime? expiresAt) => _$this._expiresAt = expiresAt;

  AvatarBuilder() {
    Avatar._defaults(this);
  }

  AvatarBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _url = $v.url;
      _expiresAt = $v.expiresAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Avatar other) {
    _$v = other as _$Avatar;
  }

  @override
  void update(void Function(AvatarBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Avatar build() => _build();

  _$Avatar _build() {
    final _$result = _$v ??
        _$Avatar._(
          url: BuiltValueNullFieldError.checkNotNull(url, r'Avatar', 'url'),
          expiresAt: BuiltValueNullFieldError.checkNotNull(
              expiresAt, r'Avatar', 'expiresAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
