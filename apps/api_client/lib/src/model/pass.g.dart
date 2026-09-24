// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pass.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Pass extends Pass {
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

  factory _$Pass([void Function(PassBuilder)? updates]) =>
      (PassBuilder()..update(updates))._build();

  _$Pass._(
      {required this.reservationId,
      required this.tripId,
      required this.qrToken,
      required this.expiresAt,
      required this.boardingCode})
      : super._();
  @override
  Pass rebuild(void Function(PassBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PassBuilder toBuilder() => PassBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Pass &&
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
    return (newBuiltValueToStringHelper(r'Pass')
          ..add('reservationId', reservationId)
          ..add('tripId', tripId)
          ..add('qrToken', qrToken)
          ..add('expiresAt', expiresAt)
          ..add('boardingCode', boardingCode))
        .toString();
  }
}

class PassBuilder implements Builder<Pass, PassBuilder> {
  _$Pass? _$v;

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

  PassBuilder() {
    Pass._defaults(this);
  }

  PassBuilder get _$this {
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
  void replace(Pass other) {
    _$v = other as _$Pass;
  }

  @override
  void update(void Function(PassBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Pass build() => _build();

  _$Pass _build() {
    final _$result = _$v ??
        _$Pass._(
          reservationId: BuiltValueNullFieldError.checkNotNull(
              reservationId, r'Pass', 'reservationId'),
          tripId:
              BuiltValueNullFieldError.checkNotNull(tripId, r'Pass', 'tripId'),
          qrToken: BuiltValueNullFieldError.checkNotNull(
              qrToken, r'Pass', 'qrToken'),
          expiresAt: BuiltValueNullFieldError.checkNotNull(
              expiresAt, r'Pass', 'expiresAt'),
          boardingCode: BuiltValueNullFieldError.checkNotNull(
              boardingCode, r'Pass', 'boardingCode'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
