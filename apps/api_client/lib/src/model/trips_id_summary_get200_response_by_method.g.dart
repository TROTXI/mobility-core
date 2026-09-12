// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trips_id_summary_get200_response_by_method.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TripsIdSummaryGet200ResponseByMethod
    extends TripsIdSummaryGet200ResponseByMethod {
  @override
  final int qr;
  @override
  final int pin;
  @override
  final int photo;

  factory _$TripsIdSummaryGet200ResponseByMethod(
          [void Function(TripsIdSummaryGet200ResponseByMethodBuilder)?
              updates]) =>
      (TripsIdSummaryGet200ResponseByMethodBuilder()..update(updates))._build();

  _$TripsIdSummaryGet200ResponseByMethod._(
      {required this.qr, required this.pin, required this.photo})
      : super._();
  @override
  TripsIdSummaryGet200ResponseByMethod rebuild(
          void Function(TripsIdSummaryGet200ResponseByMethodBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TripsIdSummaryGet200ResponseByMethodBuilder toBuilder() =>
      TripsIdSummaryGet200ResponseByMethodBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TripsIdSummaryGet200ResponseByMethod &&
        qr == other.qr &&
        pin == other.pin &&
        photo == other.photo;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, qr.hashCode);
    _$hash = $jc(_$hash, pin.hashCode);
    _$hash = $jc(_$hash, photo.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TripsIdSummaryGet200ResponseByMethod')
          ..add('qr', qr)
          ..add('pin', pin)
          ..add('photo', photo))
        .toString();
  }
}

class TripsIdSummaryGet200ResponseByMethodBuilder
    implements
        Builder<TripsIdSummaryGet200ResponseByMethod,
            TripsIdSummaryGet200ResponseByMethodBuilder> {
  _$TripsIdSummaryGet200ResponseByMethod? _$v;

  int? _qr;
  int? get qr => _$this._qr;
  set qr(int? qr) => _$this._qr = qr;

  int? _pin;
  int? get pin => _$this._pin;
  set pin(int? pin) => _$this._pin = pin;

  int? _photo;
  int? get photo => _$this._photo;
  set photo(int? photo) => _$this._photo = photo;

  TripsIdSummaryGet200ResponseByMethodBuilder() {
    TripsIdSummaryGet200ResponseByMethod._defaults(this);
  }

  TripsIdSummaryGet200ResponseByMethodBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _qr = $v.qr;
      _pin = $v.pin;
      _photo = $v.photo;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TripsIdSummaryGet200ResponseByMethod other) {
    _$v = other as _$TripsIdSummaryGet200ResponseByMethod;
  }

  @override
  void update(
      void Function(TripsIdSummaryGet200ResponseByMethodBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TripsIdSummaryGet200ResponseByMethod build() => _build();

  _$TripsIdSummaryGet200ResponseByMethod _build() {
    final _$result = _$v ??
        _$TripsIdSummaryGet200ResponseByMethod._(
          qr: BuiltValueNullFieldError.checkNotNull(
              qr, r'TripsIdSummaryGet200ResponseByMethod', 'qr'),
          pin: BuiltValueNullFieldError.checkNotNull(
              pin, r'TripsIdSummaryGet200ResponseByMethod', 'pin'),
          photo: BuiltValueNullFieldError.checkNotNull(
              photo, r'TripsIdSummaryGet200ResponseByMethod', 'photo'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
