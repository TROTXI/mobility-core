// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_rating_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RideRatingInput extends RideRatingInput {
  @override
  final int stars;

  factory _$RideRatingInput([void Function(RideRatingInputBuilder)? updates]) =>
      (RideRatingInputBuilder()..update(updates))._build();

  _$RideRatingInput._({required this.stars}) : super._();
  @override
  RideRatingInput rebuild(void Function(RideRatingInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RideRatingInputBuilder toBuilder() => RideRatingInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RideRatingInput && stars == other.stars;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, stars.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RideRatingInput')
          ..add('stars', stars))
        .toString();
  }
}

class RideRatingInputBuilder
    implements Builder<RideRatingInput, RideRatingInputBuilder> {
  _$RideRatingInput? _$v;

  int? _stars;
  int? get stars => _$this._stars;
  set stars(int? stars) => _$this._stars = stars;

  RideRatingInputBuilder() {
    RideRatingInput._defaults(this);
  }

  RideRatingInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _stars = $v.stars;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RideRatingInput other) {
    _$v = other as _$RideRatingInput;
  }

  @override
  void update(void Function(RideRatingInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RideRatingInput build() => _build();

  _$RideRatingInput _build() {
    final _$result = _$v ??
        _$RideRatingInput._(
          stars: BuiltValueNullFieldError.checkNotNull(
              stars, r'RideRatingInput', 'stars'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
