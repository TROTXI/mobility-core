// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membership_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MembershipResponse extends MembershipResponse {
  @override
  final Membership data;

  factory _$MembershipResponse(
          [void Function(MembershipResponseBuilder)? updates]) =>
      (MembershipResponseBuilder()..update(updates))._build();

  _$MembershipResponse._({required this.data}) : super._();
  @override
  MembershipResponse rebuild(
          void Function(MembershipResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MembershipResponseBuilder toBuilder() =>
      MembershipResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MembershipResponse && data == other.data;
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
    return (newBuiltValueToStringHelper(r'MembershipResponse')
          ..add('data', data))
        .toString();
  }
}

class MembershipResponseBuilder
    implements Builder<MembershipResponse, MembershipResponseBuilder> {
  _$MembershipResponse? _$v;

  MembershipBuilder? _data;
  MembershipBuilder get data => _$this._data ??= MembershipBuilder();
  set data(MembershipBuilder? data) => _$this._data = data;

  MembershipResponseBuilder() {
    MembershipResponse._defaults(this);
  }

  MembershipResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MembershipResponse other) {
    _$v = other as _$MembershipResponse;
  }

  @override
  void update(void Function(MembershipResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MembershipResponse build() => _build();

  _$MembershipResponse _build() {
    _$MembershipResponse _$result;
    try {
      _$result = _$v ??
          _$MembershipResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'MembershipResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
