// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_generation_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TripGenerationInput extends TripGenerationInput {
  @override
  final Date serviceDate;
  @override
  final String? routeId;
  @override
  final int limit;

  factory _$TripGenerationInput(
          [void Function(TripGenerationInputBuilder)? updates]) =>
      (TripGenerationInputBuilder()..update(updates))._build();

  _$TripGenerationInput._(
      {required this.serviceDate, this.routeId, required this.limit})
      : super._();
  @override
  TripGenerationInput rebuild(
          void Function(TripGenerationInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TripGenerationInputBuilder toBuilder() =>
      TripGenerationInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TripGenerationInput &&
        serviceDate == other.serviceDate &&
        routeId == other.routeId &&
        limit == other.limit;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, serviceDate.hashCode);
    _$hash = $jc(_$hash, routeId.hashCode);
    _$hash = $jc(_$hash, limit.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TripGenerationInput')
          ..add('serviceDate', serviceDate)
          ..add('routeId', routeId)
          ..add('limit', limit))
        .toString();
  }
}

class TripGenerationInputBuilder
    implements Builder<TripGenerationInput, TripGenerationInputBuilder> {
  _$TripGenerationInput? _$v;

  Date? _serviceDate;
  Date? get serviceDate => _$this._serviceDate;
  set serviceDate(Date? serviceDate) => _$this._serviceDate = serviceDate;

  String? _routeId;
  String? get routeId => _$this._routeId;
  set routeId(String? routeId) => _$this._routeId = routeId;

  int? _limit;
  int? get limit => _$this._limit;
  set limit(int? limit) => _$this._limit = limit;

  TripGenerationInputBuilder() {
    TripGenerationInput._defaults(this);
  }

  TripGenerationInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _serviceDate = $v.serviceDate;
      _routeId = $v.routeId;
      _limit = $v.limit;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TripGenerationInput other) {
    _$v = other as _$TripGenerationInput;
  }

  @override
  void update(void Function(TripGenerationInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TripGenerationInput build() => _build();

  _$TripGenerationInput _build() {
    final _$result = _$v ??
        _$TripGenerationInput._(
          serviceDate: BuiltValueNullFieldError.checkNotNull(
              serviceDate, r'TripGenerationInput', 'serviceDate'),
          routeId: routeId,
          limit: BuiltValueNullFieldError.checkNotNull(
              limit, r'TripGenerationInput', 'limit'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
