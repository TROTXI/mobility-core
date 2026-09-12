// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'boarding_board_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BoardingBoardPostRequest extends BoardingBoardPostRequest {
  @override
  final String reservationId;

  factory _$BoardingBoardPostRequest(
          [void Function(BoardingBoardPostRequestBuilder)? updates]) =>
      (BoardingBoardPostRequestBuilder()..update(updates))._build();

  _$BoardingBoardPostRequest._({required this.reservationId}) : super._();
  @override
  BoardingBoardPostRequest rebuild(
          void Function(BoardingBoardPostRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BoardingBoardPostRequestBuilder toBuilder() =>
      BoardingBoardPostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BoardingBoardPostRequest &&
        reservationId == other.reservationId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, reservationId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BoardingBoardPostRequest')
          ..add('reservationId', reservationId))
        .toString();
  }
}

class BoardingBoardPostRequestBuilder
    implements
        Builder<BoardingBoardPostRequest, BoardingBoardPostRequestBuilder> {
  _$BoardingBoardPostRequest? _$v;

  String? _reservationId;
  String? get reservationId => _$this._reservationId;
  set reservationId(String? reservationId) =>
      _$this._reservationId = reservationId;

  BoardingBoardPostRequestBuilder() {
    BoardingBoardPostRequest._defaults(this);
  }

  BoardingBoardPostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _reservationId = $v.reservationId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BoardingBoardPostRequest other) {
    _$v = other as _$BoardingBoardPostRequest;
  }

  @override
  void update(void Function(BoardingBoardPostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BoardingBoardPostRequest build() => _build();

  _$BoardingBoardPostRequest _build() {
    final _$result = _$v ??
        _$BoardingBoardPostRequest._(
          reservationId: BuiltValueNullFieldError.checkNotNull(
              reservationId, r'BoardingBoardPostRequest', 'reservationId'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
