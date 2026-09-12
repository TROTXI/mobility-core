// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_routes_id_fares_get200_response_fares_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminRoutesIdFaresGet200ResponseFaresInner
    extends AdminRoutesIdFaresGet200ResponseFaresInner {
  @override
  final String id;
  @override
  final String routeId;
  @override
  final int farePesewas;
  @override
  final DateTime effectiveFrom;
  @override
  final DateTime? effectiveTo;
  @override
  final String? note;

  factory _$AdminRoutesIdFaresGet200ResponseFaresInner(
          [void Function(AdminRoutesIdFaresGet200ResponseFaresInnerBuilder)?
              updates]) =>
      (AdminRoutesIdFaresGet200ResponseFaresInnerBuilder()..update(updates))
          ._build();

  _$AdminRoutesIdFaresGet200ResponseFaresInner._(
      {required this.id,
      required this.routeId,
      required this.farePesewas,
      required this.effectiveFrom,
      this.effectiveTo,
      this.note})
      : super._();
  @override
  AdminRoutesIdFaresGet200ResponseFaresInner rebuild(
          void Function(AdminRoutesIdFaresGet200ResponseFaresInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminRoutesIdFaresGet200ResponseFaresInnerBuilder toBuilder() =>
      AdminRoutesIdFaresGet200ResponseFaresInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminRoutesIdFaresGet200ResponseFaresInner &&
        id == other.id &&
        routeId == other.routeId &&
        farePesewas == other.farePesewas &&
        effectiveFrom == other.effectiveFrom &&
        effectiveTo == other.effectiveTo &&
        note == other.note;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, routeId.hashCode);
    _$hash = $jc(_$hash, farePesewas.hashCode);
    _$hash = $jc(_$hash, effectiveFrom.hashCode);
    _$hash = $jc(_$hash, effectiveTo.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'AdminRoutesIdFaresGet200ResponseFaresInner')
          ..add('id', id)
          ..add('routeId', routeId)
          ..add('farePesewas', farePesewas)
          ..add('effectiveFrom', effectiveFrom)
          ..add('effectiveTo', effectiveTo)
          ..add('note', note))
        .toString();
  }
}

class AdminRoutesIdFaresGet200ResponseFaresInnerBuilder
    implements
        Builder<AdminRoutesIdFaresGet200ResponseFaresInner,
            AdminRoutesIdFaresGet200ResponseFaresInnerBuilder> {
  _$AdminRoutesIdFaresGet200ResponseFaresInner? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _routeId;
  String? get routeId => _$this._routeId;
  set routeId(String? routeId) => _$this._routeId = routeId;

  int? _farePesewas;
  int? get farePesewas => _$this._farePesewas;
  set farePesewas(int? farePesewas) => _$this._farePesewas = farePesewas;

  DateTime? _effectiveFrom;
  DateTime? get effectiveFrom => _$this._effectiveFrom;
  set effectiveFrom(DateTime? effectiveFrom) =>
      _$this._effectiveFrom = effectiveFrom;

  DateTime? _effectiveTo;
  DateTime? get effectiveTo => _$this._effectiveTo;
  set effectiveTo(DateTime? effectiveTo) => _$this._effectiveTo = effectiveTo;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  AdminRoutesIdFaresGet200ResponseFaresInnerBuilder() {
    AdminRoutesIdFaresGet200ResponseFaresInner._defaults(this);
  }

  AdminRoutesIdFaresGet200ResponseFaresInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _routeId = $v.routeId;
      _farePesewas = $v.farePesewas;
      _effectiveFrom = $v.effectiveFrom;
      _effectiveTo = $v.effectiveTo;
      _note = $v.note;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminRoutesIdFaresGet200ResponseFaresInner other) {
    _$v = other as _$AdminRoutesIdFaresGet200ResponseFaresInner;
  }

  @override
  void update(
      void Function(AdminRoutesIdFaresGet200ResponseFaresInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminRoutesIdFaresGet200ResponseFaresInner build() => _build();

  _$AdminRoutesIdFaresGet200ResponseFaresInner _build() {
    final _$result = _$v ??
        _$AdminRoutesIdFaresGet200ResponseFaresInner._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'AdminRoutesIdFaresGet200ResponseFaresInner', 'id'),
          routeId: BuiltValueNullFieldError.checkNotNull(routeId,
              r'AdminRoutesIdFaresGet200ResponseFaresInner', 'routeId'),
          farePesewas: BuiltValueNullFieldError.checkNotNull(farePesewas,
              r'AdminRoutesIdFaresGet200ResponseFaresInner', 'farePesewas'),
          effectiveFrom: BuiltValueNullFieldError.checkNotNull(effectiveFrom,
              r'AdminRoutesIdFaresGet200ResponseFaresInner', 'effectiveFrom'),
          effectiveTo: effectiveTo,
          note: note,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
