// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation_detail_rating.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ReservationDetailRating extends ReservationDetailRating {
  @override
  final int stars;
  @override
  final DateTime ratedAt;

  factory _$ReservationDetailRating(
          [void Function(ReservationDetailRatingBuilder)? updates]) =>
      (ReservationDetailRatingBuilder()..update(updates))._build();

  _$ReservationDetailRating._({required this.stars, required this.ratedAt})
      : super._();
  @override
  ReservationDetailRating rebuild(
          void Function(ReservationDetailRatingBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReservationDetailRatingBuilder toBuilder() =>
      ReservationDetailRatingBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReservationDetailRating &&
        stars == other.stars &&
        ratedAt == other.ratedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, stars.hashCode);
    _$hash = $jc(_$hash, ratedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ReservationDetailRating')
          ..add('stars', stars)
          ..add('ratedAt', ratedAt))
        .toString();
  }
}

class ReservationDetailRatingBuilder
    implements
        Builder<ReservationDetailRating, ReservationDetailRatingBuilder> {
  _$ReservationDetailRating? _$v;

  int? _stars;
  int? get stars => _$this._stars;
  set stars(int? stars) => _$this._stars = stars;

  DateTime? _ratedAt;
  DateTime? get ratedAt => _$this._ratedAt;
  set ratedAt(DateTime? ratedAt) => _$this._ratedAt = ratedAt;

  ReservationDetailRatingBuilder() {
    ReservationDetailRating._defaults(this);
  }

  ReservationDetailRatingBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _stars = $v.stars;
      _ratedAt = $v.ratedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReservationDetailRating other) {
    _$v = other as _$ReservationDetailRating;
  }

  @override
  void update(void Function(ReservationDetailRatingBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReservationDetailRating build() => _build();

  _$ReservationDetailRating _build() {
    final _$result = _$v ??
        _$ReservationDetailRating._(
          stars: BuiltValueNullFieldError.checkNotNull(
              stars, r'ReservationDetailRating', 'stars'),
          ratedAt: BuiltValueNullFieldError.checkNotNull(
              ratedAt, r'ReservationDetailRating', 'ratedAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
