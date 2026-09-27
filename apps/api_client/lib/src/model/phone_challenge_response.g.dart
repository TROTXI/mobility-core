// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phone_challenge_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PhoneChallengeResponse extends PhoneChallengeResponse {
  @override
  final PhoneChallenge data;

  factory _$PhoneChallengeResponse(
          [void Function(PhoneChallengeResponseBuilder)? updates]) =>
      (PhoneChallengeResponseBuilder()..update(updates))._build();

  _$PhoneChallengeResponse._({required this.data}) : super._();
  @override
  PhoneChallengeResponse rebuild(
          void Function(PhoneChallengeResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PhoneChallengeResponseBuilder toBuilder() =>
      PhoneChallengeResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PhoneChallengeResponse && data == other.data;
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
    return (newBuiltValueToStringHelper(r'PhoneChallengeResponse')
          ..add('data', data))
        .toString();
  }
}

class PhoneChallengeResponseBuilder
    implements Builder<PhoneChallengeResponse, PhoneChallengeResponseBuilder> {
  _$PhoneChallengeResponse? _$v;

  PhoneChallengeBuilder? _data;
  PhoneChallengeBuilder get data => _$this._data ??= PhoneChallengeBuilder();
  set data(PhoneChallengeBuilder? data) => _$this._data = data;

  PhoneChallengeResponseBuilder() {
    PhoneChallengeResponse._defaults(this);
  }

  PhoneChallengeResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PhoneChallengeResponse other) {
    _$v = other as _$PhoneChallengeResponse;
  }

  @override
  void update(void Function(PhoneChallengeResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PhoneChallengeResponse build() => _build();

  _$PhoneChallengeResponse _build() {
    _$PhoneChallengeResponse _$result;
    try {
      _$result = _$v ??
          _$PhoneChallengeResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PhoneChallengeResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
