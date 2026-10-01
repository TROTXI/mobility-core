// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verification_status_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$VerificationStatusResponse extends VerificationStatusResponse {
  @override
  final VerificationStatus data;

  factory _$VerificationStatusResponse(
          [void Function(VerificationStatusResponseBuilder)? updates]) =>
      (VerificationStatusResponseBuilder()..update(updates))._build();

  _$VerificationStatusResponse._({required this.data}) : super._();
  @override
  VerificationStatusResponse rebuild(
          void Function(VerificationStatusResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  VerificationStatusResponseBuilder toBuilder() =>
      VerificationStatusResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is VerificationStatusResponse && data == other.data;
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
    return (newBuiltValueToStringHelper(r'VerificationStatusResponse')
          ..add('data', data))
        .toString();
  }
}

class VerificationStatusResponseBuilder
    implements
        Builder<VerificationStatusResponse, VerificationStatusResponseBuilder> {
  _$VerificationStatusResponse? _$v;

  VerificationStatusBuilder? _data;
  VerificationStatusBuilder get data =>
      _$this._data ??= VerificationStatusBuilder();
  set data(VerificationStatusBuilder? data) => _$this._data = data;

  VerificationStatusResponseBuilder() {
    VerificationStatusResponse._defaults(this);
  }

  VerificationStatusResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(VerificationStatusResponse other) {
    _$v = other as _$VerificationStatusResponse;
  }

  @override
  void update(void Function(VerificationStatusResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  VerificationStatusResponse build() => _build();

  _$VerificationStatusResponse _build() {
    _$VerificationStatusResponse _$result;
    try {
      _$result = _$v ??
          _$VerificationStatusResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'VerificationStatusResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
