// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_routes_id_fare_put_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminRoutesIdFarePutRequest extends AdminRoutesIdFarePutRequest {
  @override
  final int farePesewas;
  @override
  final String? note;

  factory _$AdminRoutesIdFarePutRequest(
          [void Function(AdminRoutesIdFarePutRequestBuilder)? updates]) =>
      (AdminRoutesIdFarePutRequestBuilder()..update(updates))._build();

  _$AdminRoutesIdFarePutRequest._({required this.farePesewas, this.note})
      : super._();
  @override
  AdminRoutesIdFarePutRequest rebuild(
          void Function(AdminRoutesIdFarePutRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminRoutesIdFarePutRequestBuilder toBuilder() =>
      AdminRoutesIdFarePutRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminRoutesIdFarePutRequest &&
        farePesewas == other.farePesewas &&
        note == other.note;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, farePesewas.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminRoutesIdFarePutRequest')
          ..add('farePesewas', farePesewas)
          ..add('note', note))
        .toString();
  }
}

class AdminRoutesIdFarePutRequestBuilder
    implements
        Builder<AdminRoutesIdFarePutRequest,
            AdminRoutesIdFarePutRequestBuilder> {
  _$AdminRoutesIdFarePutRequest? _$v;

  int? _farePesewas;
  int? get farePesewas => _$this._farePesewas;
  set farePesewas(int? farePesewas) => _$this._farePesewas = farePesewas;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  AdminRoutesIdFarePutRequestBuilder() {
    AdminRoutesIdFarePutRequest._defaults(this);
  }

  AdminRoutesIdFarePutRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _farePesewas = $v.farePesewas;
      _note = $v.note;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminRoutesIdFarePutRequest other) {
    _$v = other as _$AdminRoutesIdFarePutRequest;
  }

  @override
  void update(void Function(AdminRoutesIdFarePutRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminRoutesIdFarePutRequest build() => _build();

  _$AdminRoutesIdFarePutRequest _build() {
    final _$result = _$v ??
        _$AdminRoutesIdFarePutRequest._(
          farePesewas: BuiltValueNullFieldError.checkNotNull(
              farePesewas, r'AdminRoutesIdFarePutRequest', 'farePesewas'),
          note: note,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
