// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'boarding_verify_code_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BoardingVerifyCodePostRequest extends BoardingVerifyCodePostRequest {
  @override
  final String tripId;
  @override
  final String code;

  factory _$BoardingVerifyCodePostRequest(
          [void Function(BoardingVerifyCodePostRequestBuilder)? updates]) =>
      (BoardingVerifyCodePostRequestBuilder()..update(updates))._build();

  _$BoardingVerifyCodePostRequest._({required this.tripId, required this.code})
      : super._();
  @override
  BoardingVerifyCodePostRequest rebuild(
          void Function(BoardingVerifyCodePostRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BoardingVerifyCodePostRequestBuilder toBuilder() =>
      BoardingVerifyCodePostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BoardingVerifyCodePostRequest &&
        tripId == other.tripId &&
        code == other.code;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, tripId.hashCode);
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BoardingVerifyCodePostRequest')
          ..add('tripId', tripId)
          ..add('code', code))
        .toString();
  }
}

class BoardingVerifyCodePostRequestBuilder
    implements
        Builder<BoardingVerifyCodePostRequest,
            BoardingVerifyCodePostRequestBuilder> {
  _$BoardingVerifyCodePostRequest? _$v;

  String? _tripId;
  String? get tripId => _$this._tripId;
  set tripId(String? tripId) => _$this._tripId = tripId;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  BoardingVerifyCodePostRequestBuilder() {
    BoardingVerifyCodePostRequest._defaults(this);
  }

  BoardingVerifyCodePostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _tripId = $v.tripId;
      _code = $v.code;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BoardingVerifyCodePostRequest other) {
    _$v = other as _$BoardingVerifyCodePostRequest;
  }

  @override
  void update(void Function(BoardingVerifyCodePostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BoardingVerifyCodePostRequest build() => _build();

  _$BoardingVerifyCodePostRequest _build() {
    final _$result = _$v ??
        _$BoardingVerifyCodePostRequest._(
          tripId: BuiltValueNullFieldError.checkNotNull(
              tripId, r'BoardingVerifyCodePostRequest', 'tripId'),
          code: BuiltValueNullFieldError.checkNotNull(
              code, r'BoardingVerifyCodePostRequest', 'code'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
