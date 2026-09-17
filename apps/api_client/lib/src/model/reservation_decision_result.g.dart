// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation_decision_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ReservationDecisionResult extends ReservationDecisionResult {
  @override
  final Reservation reservation;
  @override
  final ReservationDecisionResultPass? pass;

  factory _$ReservationDecisionResult(
          [void Function(ReservationDecisionResultBuilder)? updates]) =>
      (ReservationDecisionResultBuilder()..update(updates))._build();

  _$ReservationDecisionResult._({required this.reservation, this.pass})
      : super._();
  @override
  ReservationDecisionResult rebuild(
          void Function(ReservationDecisionResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReservationDecisionResultBuilder toBuilder() =>
      ReservationDecisionResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReservationDecisionResult &&
        reservation == other.reservation &&
        pass == other.pass;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, reservation.hashCode);
    _$hash = $jc(_$hash, pass.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ReservationDecisionResult')
          ..add('reservation', reservation)
          ..add('pass', pass))
        .toString();
  }
}

class ReservationDecisionResultBuilder
    implements
        Builder<ReservationDecisionResult, ReservationDecisionResultBuilder> {
  _$ReservationDecisionResult? _$v;

  ReservationBuilder? _reservation;
  ReservationBuilder get reservation =>
      _$this._reservation ??= ReservationBuilder();
  set reservation(ReservationBuilder? reservation) =>
      _$this._reservation = reservation;

  ReservationDecisionResultPassBuilder? _pass;
  ReservationDecisionResultPassBuilder get pass =>
      _$this._pass ??= ReservationDecisionResultPassBuilder();
  set pass(ReservationDecisionResultPassBuilder? pass) => _$this._pass = pass;

  ReservationDecisionResultBuilder() {
    ReservationDecisionResult._defaults(this);
  }

  ReservationDecisionResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _reservation = $v.reservation.toBuilder();
      _pass = $v.pass?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReservationDecisionResult other) {
    _$v = other as _$ReservationDecisionResult;
  }

  @override
  void update(void Function(ReservationDecisionResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReservationDecisionResult build() => _build();

  _$ReservationDecisionResult _build() {
    _$ReservationDecisionResult _$result;
    try {
      _$result = _$v ??
          _$ReservationDecisionResult._(
            reservation: reservation.build(),
            pass: _pass?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'reservation';
        reservation.build();
        _$failedField = 'pass';
        _pass?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ReservationDecisionResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
