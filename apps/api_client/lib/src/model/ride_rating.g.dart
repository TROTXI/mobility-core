// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_rating.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RideRating extends RideRating {
  @override
  final int stars;
  @override
  final DateTime ratedAt;

  factory _$RideRating([void Function(RideRatingBuilder)? updates]) =>
      (RideRatingBuilder()..update(updates))._build();

  _$RideRating._({required this.stars, required this.ratedAt}) : super._();
  @override
  RideRating rebuild(void Function(RideRatingBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RideRatingBuilder toBuilder() => RideRatingBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RideRating &&
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
    return (newBuiltValueToStringHelper(r'RideRating')
          ..add('stars', stars)
          ..add('ratedAt', ratedAt))
        .toString();
  }
}

class RideRatingBuilder implements Builder<RideRating, RideRatingBuilder> {
  _$RideRating? _$v;

  int? _stars;
  int? get stars => _$this._stars;
  set stars(int? stars) => _$this._stars = stars;

  DateTime? _ratedAt;
  DateTime? get ratedAt => _$this._ratedAt;
  set ratedAt(DateTime? ratedAt) => _$this._ratedAt = ratedAt;

  RideRatingBuilder() {
    RideRating._defaults(this);
  }

  RideRatingBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _stars = $v.stars;
      _ratedAt = $v.ratedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RideRating other) {
    _$v = other as _$RideRating;
  }

  @override
  void update(void Function(RideRatingBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RideRating build() => _build();

  _$RideRating _build() {
    final _$result = _$v ??
        _$RideRating._(
          stars: BuiltValueNullFieldError.checkNotNull(
              stars, r'RideRating', 'stars'),
          ratedAt: BuiltValueNullFieldError.checkNotNull(
              ratedAt, r'RideRating', 'ratedAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
