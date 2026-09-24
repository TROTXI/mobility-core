// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation_decision_result_pass.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ReservationDecisionResultPass extends ReservationDecisionResultPass {
  @override
  final String reservationId;
  @override
  final String tripId;
  @override
  final String qrToken;
  @override
  final DateTime expiresAt;
  @override
  final String boardingCode;

  factory _$ReservationDecisionResultPass(
          [void Function(ReservationDecisionResultPassBuilder)? updates]) =>
      (ReservationDecisionResultPassBuilder()..update(updates))._build();

  _$ReservationDecisionResultPass._(
      {required this.reservationId,
      required this.tripId,
      required this.qrToken,
      required this.expiresAt,
      required this.boardingCode})
      : super._();
  @override
  ReservationDecisionResultPass rebuild(
          void Function(ReservationDecisionResultPassBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReservationDecisionResultPassBuilder toBuilder() =>
      ReservationDecisionResultPassBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReservationDecisionResultPass &&
        reservationId == other.reservationId &&
        tripId == other.tripId &&
        qrToken == other.qrToken &&
        expiresAt == other.expiresAt &&
        boardingCode == other.boardingCode;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, reservationId.hashCode);
    _$hash = $jc(_$hash, tripId.hashCode);
    _$hash = $jc(_$hash, qrToken.hashCode);
    _$hash = $jc(_$hash, expiresAt.hashCode);
    _$hash = $jc(_$hash, boardingCode.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ReservationDecisionResultPass')
          ..add('reservationId', reservationId)
          ..add('tripId', tripId)
          ..add('qrToken', qrToken)
          ..add('expiresAt', expiresAt)
          ..add('boardingCode', boardingCode))
        .toString();
  }
}

class ReservationDecisionResultPassBuilder
    implements
        Builder<ReservationDecisionResultPass,
            ReservationDecisionResultPassBuilder> {
  _$ReservationDecisionResultPass? _$v;

  String? _reservationId;
  String? get reservationId => _$this._reservationId;
  set reservationId(String? reservationId) =>
      _$this._reservationId = reservationId;

  String? _tripId;
  String? get tripId => _$this._tripId;
  set tripId(String? tripId) => _$this._tripId = tripId;

  String? _qrToken;
  String? get qrToken => _$this._qrToken;
  set qrToken(String? qrToken) => _$this._qrToken = qrToken;

  DateTime? _expiresAt;
  DateTime? get expiresAt => _$this._expiresAt;
  set expiresAt(DateTime? expiresAt) => _$this._expiresAt = expiresAt;

  String? _boardingCode;
  String? get boardingCode => _$this._boardingCode;
  set boardingCode(String? boardingCode) => _$this._boardingCode = boardingCode;

  ReservationDecisionResultPassBuilder() {
    ReservationDecisionResultPass._defaults(this);
  }

  ReservationDecisionResultPassBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _reservationId = $v.reservationId;
      _tripId = $v.tripId;
      _qrToken = $v.qrToken;
      _expiresAt = $v.expiresAt;
      _boardingCode = $v.boardingCode;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReservationDecisionResultPass other) {
    _$v = other as _$ReservationDecisionResultPass;
  }

  @override
  void update(void Function(ReservationDecisionResultPassBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReservationDecisionResultPass build() => _build();

  _$ReservationDecisionResultPass _build() {
    final _$result = _$v ??
        _$ReservationDecisionResultPass._(
          reservationId: BuiltValueNullFieldError.checkNotNull(
              reservationId, r'ReservationDecisionResultPass', 'reservationId'),
          tripId: BuiltValueNullFieldError.checkNotNull(
              tripId, r'ReservationDecisionResultPass', 'tripId'),
          qrToken: BuiltValueNullFieldError.checkNotNull(
              qrToken, r'ReservationDecisionResultPass', 'qrToken'),
          expiresAt: BuiltValueNullFieldError.checkNotNull(
              expiresAt, r'ReservationDecisionResultPass', 'expiresAt'),
          boardingCode: BuiltValueNullFieldError.checkNotNull(
              boardingCode, r'ReservationDecisionResultPass', 'boardingCode'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
