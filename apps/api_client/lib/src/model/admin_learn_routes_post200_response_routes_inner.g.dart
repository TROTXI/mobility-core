// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_learn_routes_post200_response_routes_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminLearnRoutesPost200ResponseRoutesInner
    extends AdminLearnRoutesPost200ResponseRoutesInner {
  @override
  final String routeId;
  @override
  final int runsUsed;
  @override
  final bool geometryUpdated;
  @override
  final AdminLearnRoutesPost200ResponseRoutesInnerSegmentsLearned
      segmentsLearned;

  factory _$AdminLearnRoutesPost200ResponseRoutesInner(
          [void Function(AdminLearnRoutesPost200ResponseRoutesInnerBuilder)?
              updates]) =>
      (AdminLearnRoutesPost200ResponseRoutesInnerBuilder()..update(updates))
          ._build();

  _$AdminLearnRoutesPost200ResponseRoutesInner._(
      {required this.routeId,
      required this.runsUsed,
      required this.geometryUpdated,
      required this.segmentsLearned})
      : super._();
  @override
  AdminLearnRoutesPost200ResponseRoutesInner rebuild(
          void Function(AdminLearnRoutesPost200ResponseRoutesInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminLearnRoutesPost200ResponseRoutesInnerBuilder toBuilder() =>
      AdminLearnRoutesPost200ResponseRoutesInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminLearnRoutesPost200ResponseRoutesInner &&
        routeId == other.routeId &&
        runsUsed == other.runsUsed &&
        geometryUpdated == other.geometryUpdated &&
        segmentsLearned == other.segmentsLearned;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, routeId.hashCode);
    _$hash = $jc(_$hash, runsUsed.hashCode);
    _$hash = $jc(_$hash, geometryUpdated.hashCode);
    _$hash = $jc(_$hash, segmentsLearned.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'AdminLearnRoutesPost200ResponseRoutesInner')
          ..add('routeId', routeId)
          ..add('runsUsed', runsUsed)
          ..add('geometryUpdated', geometryUpdated)
          ..add('segmentsLearned', segmentsLearned))
        .toString();
  }
}

class AdminLearnRoutesPost200ResponseRoutesInnerBuilder
    implements
        Builder<AdminLearnRoutesPost200ResponseRoutesInner,
            AdminLearnRoutesPost200ResponseRoutesInnerBuilder> {
  _$AdminLearnRoutesPost200ResponseRoutesInner? _$v;

  String? _routeId;
  String? get routeId => _$this._routeId;
  set routeId(String? routeId) => _$this._routeId = routeId;

  int? _runsUsed;
  int? get runsUsed => _$this._runsUsed;
  set runsUsed(int? runsUsed) => _$this._runsUsed = runsUsed;

  bool? _geometryUpdated;
  bool? get geometryUpdated => _$this._geometryUpdated;
  set geometryUpdated(bool? geometryUpdated) =>
      _$this._geometryUpdated = geometryUpdated;

  AdminLearnRoutesPost200ResponseRoutesInnerSegmentsLearnedBuilder?
      _segmentsLearned;
  AdminLearnRoutesPost200ResponseRoutesInnerSegmentsLearnedBuilder
      get segmentsLearned => _$this._segmentsLearned ??=
          AdminLearnRoutesPost200ResponseRoutesInnerSegmentsLearnedBuilder();
  set segmentsLearned(
          AdminLearnRoutesPost200ResponseRoutesInnerSegmentsLearnedBuilder?
              segmentsLearned) =>
      _$this._segmentsLearned = segmentsLearned;

  AdminLearnRoutesPost200ResponseRoutesInnerBuilder() {
    AdminLearnRoutesPost200ResponseRoutesInner._defaults(this);
  }

  AdminLearnRoutesPost200ResponseRoutesInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _routeId = $v.routeId;
      _runsUsed = $v.runsUsed;
      _geometryUpdated = $v.geometryUpdated;
      _segmentsLearned = $v.segmentsLearned.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminLearnRoutesPost200ResponseRoutesInner other) {
    _$v = other as _$AdminLearnRoutesPost200ResponseRoutesInner;
  }

  @override
  void update(
      void Function(AdminLearnRoutesPost200ResponseRoutesInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminLearnRoutesPost200ResponseRoutesInner build() => _build();

  _$AdminLearnRoutesPost200ResponseRoutesInner _build() {
    _$AdminLearnRoutesPost200ResponseRoutesInner _$result;
    try {
      _$result = _$v ??
          _$AdminLearnRoutesPost200ResponseRoutesInner._(
            routeId: BuiltValueNullFieldError.checkNotNull(routeId,
                r'AdminLearnRoutesPost200ResponseRoutesInner', 'routeId'),
            runsUsed: BuiltValueNullFieldError.checkNotNull(runsUsed,
                r'AdminLearnRoutesPost200ResponseRoutesInner', 'runsUsed'),
            geometryUpdated: BuiltValueNullFieldError.checkNotNull(
                geometryUpdated,
                r'AdminLearnRoutesPost200ResponseRoutesInner',
                'geometryUpdated'),
            segmentsLearned: segmentsLearned.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'segmentsLearned';
        segmentsLearned.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'AdminLearnRoutesPost200ResponseRoutesInner',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
