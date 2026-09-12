// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routes_id_geometry_get200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const RoutesIdGeometryGet200ResponseSource_Enum
    _$routesIdGeometryGet200ResponseSourceEnum_traces =
    const RoutesIdGeometryGet200ResponseSource_Enum._('traces');
const RoutesIdGeometryGet200ResponseSource_Enum
    _$routesIdGeometryGet200ResponseSourceEnum_matched =
    const RoutesIdGeometryGet200ResponseSource_Enum._('matched');
const RoutesIdGeometryGet200ResponseSource_Enum
    _$routesIdGeometryGet200ResponseSourceEnum_manual =
    const RoutesIdGeometryGet200ResponseSource_Enum._('manual');
const RoutesIdGeometryGet200ResponseSource_Enum
    _$routesIdGeometryGet200ResponseSourceEnum_stops =
    const RoutesIdGeometryGet200ResponseSource_Enum._('stops');

RoutesIdGeometryGet200ResponseSource_Enum
    _$routesIdGeometryGet200ResponseSourceEnumValueOf(String name) {
  switch (name) {
    case 'traces':
      return _$routesIdGeometryGet200ResponseSourceEnum_traces;
    case 'matched':
      return _$routesIdGeometryGet200ResponseSourceEnum_matched;
    case 'manual':
      return _$routesIdGeometryGet200ResponseSourceEnum_manual;
    case 'stops':
      return _$routesIdGeometryGet200ResponseSourceEnum_stops;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<RoutesIdGeometryGet200ResponseSource_Enum>
    _$routesIdGeometryGet200ResponseSourceEnumValues = BuiltSet<
        RoutesIdGeometryGet200ResponseSource_Enum>(const <RoutesIdGeometryGet200ResponseSource_Enum>[
  _$routesIdGeometryGet200ResponseSourceEnum_traces,
  _$routesIdGeometryGet200ResponseSourceEnum_matched,
  _$routesIdGeometryGet200ResponseSourceEnum_manual,
  _$routesIdGeometryGet200ResponseSourceEnum_stops,
]);

Serializer<RoutesIdGeometryGet200ResponseSource_Enum>
    _$routesIdGeometryGet200ResponseSourceEnumSerializer =
    _$RoutesIdGeometryGet200ResponseSource_EnumSerializer();

class _$RoutesIdGeometryGet200ResponseSource_EnumSerializer
    implements PrimitiveSerializer<RoutesIdGeometryGet200ResponseSource_Enum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'traces': 'traces',
    'matched': 'matched',
    'manual': 'manual',
    'stops': 'stops',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'traces': 'traces',
    'matched': 'matched',
    'manual': 'manual',
    'stops': 'stops',
  };

  @override
  final Iterable<Type> types = const <Type>[
    RoutesIdGeometryGet200ResponseSource_Enum
  ];
  @override
  final String wireName = 'RoutesIdGeometryGet200ResponseSource_Enum';

  @override
  Object serialize(Serializers serializers,
          RoutesIdGeometryGet200ResponseSource_Enum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  RoutesIdGeometryGet200ResponseSource_Enum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      RoutesIdGeometryGet200ResponseSource_Enum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$RoutesIdGeometryGet200Response extends RoutesIdGeometryGet200Response {
  @override
  final String routeId;
  @override
  final BuiltList<RoutesIdGeometryGet200ResponsePointsInner> points;
  @override
  final RoutesIdGeometryGet200ResponseSource_Enum source_;
  @override
  final int runCount;

  factory _$RoutesIdGeometryGet200Response(
          [void Function(RoutesIdGeometryGet200ResponseBuilder)? updates]) =>
      (RoutesIdGeometryGet200ResponseBuilder()..update(updates))._build();

  _$RoutesIdGeometryGet200Response._(
      {required this.routeId,
      required this.points,
      required this.source_,
      required this.runCount})
      : super._();
  @override
  RoutesIdGeometryGet200Response rebuild(
          void Function(RoutesIdGeometryGet200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RoutesIdGeometryGet200ResponseBuilder toBuilder() =>
      RoutesIdGeometryGet200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RoutesIdGeometryGet200Response &&
        routeId == other.routeId &&
        points == other.points &&
        source_ == other.source_ &&
        runCount == other.runCount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, routeId.hashCode);
    _$hash = $jc(_$hash, points.hashCode);
    _$hash = $jc(_$hash, source_.hashCode);
    _$hash = $jc(_$hash, runCount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RoutesIdGeometryGet200Response')
          ..add('routeId', routeId)
          ..add('points', points)
          ..add('source_', source_)
          ..add('runCount', runCount))
        .toString();
  }
}

class RoutesIdGeometryGet200ResponseBuilder
    implements
        Builder<RoutesIdGeometryGet200Response,
            RoutesIdGeometryGet200ResponseBuilder> {
  _$RoutesIdGeometryGet200Response? _$v;

  String? _routeId;
  String? get routeId => _$this._routeId;
  set routeId(String? routeId) => _$this._routeId = routeId;

  ListBuilder<RoutesIdGeometryGet200ResponsePointsInner>? _points;
  ListBuilder<RoutesIdGeometryGet200ResponsePointsInner> get points =>
      _$this._points ??=
          ListBuilder<RoutesIdGeometryGet200ResponsePointsInner>();
  set points(ListBuilder<RoutesIdGeometryGet200ResponsePointsInner>? points) =>
      _$this._points = points;

  RoutesIdGeometryGet200ResponseSource_Enum? _source_;
  RoutesIdGeometryGet200ResponseSource_Enum? get source_ => _$this._source_;
  set source_(RoutesIdGeometryGet200ResponseSource_Enum? source_) =>
      _$this._source_ = source_;

  int? _runCount;
  int? get runCount => _$this._runCount;
  set runCount(int? runCount) => _$this._runCount = runCount;

  RoutesIdGeometryGet200ResponseBuilder() {
    RoutesIdGeometryGet200Response._defaults(this);
  }

  RoutesIdGeometryGet200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _routeId = $v.routeId;
      _points = $v.points.toBuilder();
      _source_ = $v.source_;
      _runCount = $v.runCount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RoutesIdGeometryGet200Response other) {
    _$v = other as _$RoutesIdGeometryGet200Response;
  }

  @override
  void update(void Function(RoutesIdGeometryGet200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RoutesIdGeometryGet200Response build() => _build();

  _$RoutesIdGeometryGet200Response _build() {
    _$RoutesIdGeometryGet200Response _$result;
    try {
      _$result = _$v ??
          _$RoutesIdGeometryGet200Response._(
            routeId: BuiltValueNullFieldError.checkNotNull(
                routeId, r'RoutesIdGeometryGet200Response', 'routeId'),
            points: points.build(),
            source_: BuiltValueNullFieldError.checkNotNull(
                source_, r'RoutesIdGeometryGet200Response', 'source_'),
            runCount: BuiltValueNullFieldError.checkNotNull(
                runCount, r'RoutesIdGeometryGet200Response', 'runCount'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'points';
        points.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'RoutesIdGeometryGet200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
