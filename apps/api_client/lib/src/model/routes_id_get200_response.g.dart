// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routes_id_get200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RoutesIdGet200Response extends RoutesIdGet200Response {
  @override
  final String id;
  @override
  final String name;
  @override
  final String? description;
  @override
  final DateTime createdAt;
  @override
  final BuiltList<RoutesIdGet200ResponseStopsInner> stops;

  factory _$RoutesIdGet200Response(
          [void Function(RoutesIdGet200ResponseBuilder)? updates]) =>
      (RoutesIdGet200ResponseBuilder()..update(updates))._build();

  _$RoutesIdGet200Response._(
      {required this.id,
      required this.name,
      this.description,
      required this.createdAt,
      required this.stops})
      : super._();
  @override
  RoutesIdGet200Response rebuild(
          void Function(RoutesIdGet200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RoutesIdGet200ResponseBuilder toBuilder() =>
      RoutesIdGet200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RoutesIdGet200Response &&
        id == other.id &&
        name == other.name &&
        description == other.description &&
        createdAt == other.createdAt &&
        stops == other.stops;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, stops.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RoutesIdGet200Response')
          ..add('id', id)
          ..add('name', name)
          ..add('description', description)
          ..add('createdAt', createdAt)
          ..add('stops', stops))
        .toString();
  }
}

class RoutesIdGet200ResponseBuilder
    implements Builder<RoutesIdGet200Response, RoutesIdGet200ResponseBuilder> {
  _$RoutesIdGet200Response? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  ListBuilder<RoutesIdGet200ResponseStopsInner>? _stops;
  ListBuilder<RoutesIdGet200ResponseStopsInner> get stops =>
      _$this._stops ??= ListBuilder<RoutesIdGet200ResponseStopsInner>();
  set stops(ListBuilder<RoutesIdGet200ResponseStopsInner>? stops) =>
      _$this._stops = stops;

  RoutesIdGet200ResponseBuilder() {
    RoutesIdGet200Response._defaults(this);
  }

  RoutesIdGet200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _description = $v.description;
      _createdAt = $v.createdAt;
      _stops = $v.stops.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RoutesIdGet200Response other) {
    _$v = other as _$RoutesIdGet200Response;
  }

  @override
  void update(void Function(RoutesIdGet200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RoutesIdGet200Response build() => _build();

  _$RoutesIdGet200Response _build() {
    _$RoutesIdGet200Response _$result;
    try {
      _$result = _$v ??
          _$RoutesIdGet200Response._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'RoutesIdGet200Response', 'id'),
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'RoutesIdGet200Response', 'name'),
            description: description,
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'RoutesIdGet200Response', 'createdAt'),
            stops: stops.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'stops';
        stops.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'RoutesIdGet200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
