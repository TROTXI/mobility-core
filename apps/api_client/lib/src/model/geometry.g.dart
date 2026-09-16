// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geometry.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GeometrySource_Enum _$geometrySourceEnum_observed =
    const GeometrySource_Enum._('observed');
const GeometrySource_Enum _$geometrySourceEnum_configured =
    const GeometrySource_Enum._('configured');

GeometrySource_Enum _$geometrySourceEnumValueOf(String name) {
  switch (name) {
    case 'observed':
      return _$geometrySourceEnum_observed;
    case 'configured':
      return _$geometrySourceEnum_configured;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GeometrySource_Enum> _$geometrySourceEnumValues =
    BuiltSet<GeometrySource_Enum>(const <GeometrySource_Enum>[
  _$geometrySourceEnum_observed,
  _$geometrySourceEnum_configured,
]);

Serializer<GeometrySource_Enum> _$geometrySourceEnumSerializer =
    _$GeometrySource_EnumSerializer();

class _$GeometrySource_EnumSerializer
    implements PrimitiveSerializer<GeometrySource_Enum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'observed': 'observed',
    'configured': 'configured',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'observed': 'observed',
    'configured': 'configured',
  };

  @override
  final Iterable<Type> types = const <Type>[GeometrySource_Enum];
  @override
  final String wireName = 'GeometrySource_Enum';

  @override
  Object serialize(Serializers serializers, GeometrySource_Enum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GeometrySource_Enum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GeometrySource_Enum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$Geometry extends Geometry {
  @override
  final String id;
  @override
  final String patternVersionId;
  @override
  final BuiltList<Point> points;
  @override
  final BuiltList<GeometryStopDistancesInner> stopDistances;
  @override
  final GeometrySource_Enum source_;
  @override
  final DateTime createdAt;

  factory _$Geometry([void Function(GeometryBuilder)? updates]) =>
      (GeometryBuilder()..update(updates))._build();

  _$Geometry._(
      {required this.id,
      required this.patternVersionId,
      required this.points,
      required this.stopDistances,
      required this.source_,
      required this.createdAt})
      : super._();
  @override
  Geometry rebuild(void Function(GeometryBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GeometryBuilder toBuilder() => GeometryBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Geometry &&
        id == other.id &&
        patternVersionId == other.patternVersionId &&
        points == other.points &&
        stopDistances == other.stopDistances &&
        source_ == other.source_ &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, patternVersionId.hashCode);
    _$hash = $jc(_$hash, points.hashCode);
    _$hash = $jc(_$hash, stopDistances.hashCode);
    _$hash = $jc(_$hash, source_.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Geometry')
          ..add('id', id)
          ..add('patternVersionId', patternVersionId)
          ..add('points', points)
          ..add('stopDistances', stopDistances)
          ..add('source_', source_)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class GeometryBuilder implements Builder<Geometry, GeometryBuilder> {
  _$Geometry? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _patternVersionId;
  String? get patternVersionId => _$this._patternVersionId;
  set patternVersionId(String? patternVersionId) =>
      _$this._patternVersionId = patternVersionId;

  ListBuilder<Point>? _points;
  ListBuilder<Point> get points => _$this._points ??= ListBuilder<Point>();
  set points(ListBuilder<Point>? points) => _$this._points = points;

  ListBuilder<GeometryStopDistancesInner>? _stopDistances;
  ListBuilder<GeometryStopDistancesInner> get stopDistances =>
      _$this._stopDistances ??= ListBuilder<GeometryStopDistancesInner>();
  set stopDistances(ListBuilder<GeometryStopDistancesInner>? stopDistances) =>
      _$this._stopDistances = stopDistances;

  GeometrySource_Enum? _source_;
  GeometrySource_Enum? get source_ => _$this._source_;
  set source_(GeometrySource_Enum? source_) => _$this._source_ = source_;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  GeometryBuilder() {
    Geometry._defaults(this);
  }

  GeometryBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _patternVersionId = $v.patternVersionId;
      _points = $v.points.toBuilder();
      _stopDistances = $v.stopDistances.toBuilder();
      _source_ = $v.source_;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Geometry other) {
    _$v = other as _$Geometry;
  }

  @override
  void update(void Function(GeometryBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Geometry build() => _build();

  _$Geometry _build() {
    _$Geometry _$result;
    try {
      _$result = _$v ??
          _$Geometry._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'Geometry', 'id'),
            patternVersionId: BuiltValueNullFieldError.checkNotNull(
                patternVersionId, r'Geometry', 'patternVersionId'),
            points: points.build(),
            stopDistances: stopDistances.build(),
            source_: BuiltValueNullFieldError.checkNotNull(
                source_, r'Geometry', 'source_'),
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'Geometry', 'createdAt'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'points';
        points.build();
        _$failedField = 'stopDistances';
        stopDistances.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'Geometry', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
