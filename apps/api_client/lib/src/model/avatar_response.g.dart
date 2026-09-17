// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'avatar_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AvatarResponse extends AvatarResponse {
  @override
  final Avatar data;

  factory _$AvatarResponse([void Function(AvatarResponseBuilder)? updates]) =>
      (AvatarResponseBuilder()..update(updates))._build();

  _$AvatarResponse._({required this.data}) : super._();
  @override
  AvatarResponse rebuild(void Function(AvatarResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AvatarResponseBuilder toBuilder() => AvatarResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AvatarResponse && data == other.data;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AvatarResponse')..add('data', data))
        .toString();
  }
}

class AvatarResponseBuilder
    implements Builder<AvatarResponse, AvatarResponseBuilder> {
  _$AvatarResponse? _$v;

  AvatarBuilder? _data;
  AvatarBuilder get data => _$this._data ??= AvatarBuilder();
  set data(AvatarBuilder? data) => _$this._data = data;

  AvatarResponseBuilder() {
    AvatarResponse._defaults(this);
  }

  AvatarResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AvatarResponse other) {
    _$v = other as _$AvatarResponse;
  }

  @override
  void update(void Function(AvatarResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AvatarResponse build() => _build();

  _$AvatarResponse _build() {
    _$AvatarResponse _$result;
    try {
      _$result = _$v ??
          _$AvatarResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'AvatarResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
