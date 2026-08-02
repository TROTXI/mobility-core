// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'boarding_verify_pin_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BoardingVerifyPinPostRequest extends BoardingVerifyPinPostRequest {
  @override
  final String reservationId;
  @override
  final String pin;

  factory _$BoardingVerifyPinPostRequest(
          [void Function(BoardingVerifyPinPostRequestBuilder)? updates]) =>
      (BoardingVerifyPinPostRequestBuilder()..update(updates))._build();

  _$BoardingVerifyPinPostRequest._(
      {required this.reservationId, required this.pin})
      : super._();
  @override
  BoardingVerifyPinPostRequest rebuild(
          void Function(BoardingVerifyPinPostRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BoardingVerifyPinPostRequestBuilder toBuilder() =>
      BoardingVerifyPinPostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BoardingVerifyPinPostRequest &&
        reservationId == other.reservationId &&
        pin == other.pin;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, reservationId.hashCode);
    _$hash = $jc(_$hash, pin.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BoardingVerifyPinPostRequest')
          ..add('reservationId', reservationId)
          ..add('pin', pin))
        .toString();
  }
}

class BoardingVerifyPinPostRequestBuilder
    implements
        Builder<BoardingVerifyPinPostRequest,
            BoardingVerifyPinPostRequestBuilder> {
  _$BoardingVerifyPinPostRequest? _$v;

  String? _reservationId;
  String? get reservationId => _$this._reservationId;
  set reservationId(String? reservationId) =>
      _$this._reservationId = reservationId;

  String? _pin;
  String? get pin => _$this._pin;
  set pin(String? pin) => _$this._pin = pin;

  BoardingVerifyPinPostRequestBuilder() {
    BoardingVerifyPinPostRequest._defaults(this);
  }

  BoardingVerifyPinPostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _reservationId = $v.reservationId;
      _pin = $v.pin;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BoardingVerifyPinPostRequest other) {
    _$v = other as _$BoardingVerifyPinPostRequest;
  }

  @override
  void update(void Function(BoardingVerifyPinPostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BoardingVerifyPinPostRequest build() => _build();

  _$BoardingVerifyPinPostRequest _build() {
    final _$result = _$v ??
        _$BoardingVerifyPinPostRequest._(
          reservationId: BuiltValueNullFieldError.checkNotNull(
              reservationId, r'BoardingVerifyPinPostRequest', 'reservationId'),
          pin: BuiltValueNullFieldError.checkNotNull(
              pin, r'BoardingVerifyPinPostRequest', 'pin'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
