// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ops_overview.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const OpsOverviewWindowEnum _$opsOverviewWindowEnum_morning =
    const OpsOverviewWindowEnum._('morning');
const OpsOverviewWindowEnum _$opsOverviewWindowEnum_evening =
    const OpsOverviewWindowEnum._('evening');

OpsOverviewWindowEnum _$opsOverviewWindowEnumValueOf(String name) {
  switch (name) {
    case 'morning':
      return _$opsOverviewWindowEnum_morning;
    case 'evening':
      return _$opsOverviewWindowEnum_evening;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<OpsOverviewWindowEnum> _$opsOverviewWindowEnumValues =
    BuiltSet<OpsOverviewWindowEnum>(const <OpsOverviewWindowEnum>[
  _$opsOverviewWindowEnum_morning,
  _$opsOverviewWindowEnum_evening,
]);

Serializer<OpsOverviewWindowEnum> _$opsOverviewWindowEnumSerializer =
    _$OpsOverviewWindowEnumSerializer();

class _$OpsOverviewWindowEnumSerializer
    implements PrimitiveSerializer<OpsOverviewWindowEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'morning': 'morning',
    'evening': 'evening',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'morning': 'morning',
    'evening': 'evening',
  };

  @override
  final Iterable<Type> types = const <Type>[OpsOverviewWindowEnum];
  @override
  final String wireName = 'OpsOverviewWindowEnum';

  @override
  Object serialize(Serializers serializers, OpsOverviewWindowEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  OpsOverviewWindowEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      OpsOverviewWindowEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$OpsOverview extends OpsOverview {
  @override
  final DateTime generatedAt;
  @override
  final OpsOverviewWindowEnum window;
  @override
  final int staleFixAfterSeconds;
  @override
  final BuiltList<OpsOverviewTripsInner> trips;

  factory _$OpsOverview([void Function(OpsOverviewBuilder)? updates]) =>
      (OpsOverviewBuilder()..update(updates))._build();

  _$OpsOverview._(
      {required this.generatedAt,
      required this.window,
      required this.staleFixAfterSeconds,
      required this.trips})
      : super._();
  @override
  OpsOverview rebuild(void Function(OpsOverviewBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OpsOverviewBuilder toBuilder() => OpsOverviewBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OpsOverview &&
        generatedAt == other.generatedAt &&
        window == other.window &&
        staleFixAfterSeconds == other.staleFixAfterSeconds &&
        trips == other.trips;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, generatedAt.hashCode);
    _$hash = $jc(_$hash, window.hashCode);
    _$hash = $jc(_$hash, staleFixAfterSeconds.hashCode);
    _$hash = $jc(_$hash, trips.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OpsOverview')
          ..add('generatedAt', generatedAt)
          ..add('window', window)
          ..add('staleFixAfterSeconds', staleFixAfterSeconds)
          ..add('trips', trips))
        .toString();
  }
}

class OpsOverviewBuilder implements Builder<OpsOverview, OpsOverviewBuilder> {
  _$OpsOverview? _$v;

  DateTime? _generatedAt;
  DateTime? get generatedAt => _$this._generatedAt;
  set generatedAt(DateTime? generatedAt) => _$this._generatedAt = generatedAt;

  OpsOverviewWindowEnum? _window;
  OpsOverviewWindowEnum? get window => _$this._window;
  set window(OpsOverviewWindowEnum? window) => _$this._window = window;

  int? _staleFixAfterSeconds;
  int? get staleFixAfterSeconds => _$this._staleFixAfterSeconds;
  set staleFixAfterSeconds(int? staleFixAfterSeconds) =>
      _$this._staleFixAfterSeconds = staleFixAfterSeconds;

  ListBuilder<OpsOverviewTripsInner>? _trips;
  ListBuilder<OpsOverviewTripsInner> get trips =>
      _$this._trips ??= ListBuilder<OpsOverviewTripsInner>();
  set trips(ListBuilder<OpsOverviewTripsInner>? trips) => _$this._trips = trips;

  OpsOverviewBuilder() {
    OpsOverview._defaults(this);
  }

  OpsOverviewBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _generatedAt = $v.generatedAt;
      _window = $v.window;
      _staleFixAfterSeconds = $v.staleFixAfterSeconds;
      _trips = $v.trips.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OpsOverview other) {
    _$v = other as _$OpsOverview;
  }

  @override
  void update(void Function(OpsOverviewBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OpsOverview build() => _build();

  _$OpsOverview _build() {
    _$OpsOverview _$result;
    try {
      _$result = _$v ??
          _$OpsOverview._(
            generatedAt: BuiltValueNullFieldError.checkNotNull(
                generatedAt, r'OpsOverview', 'generatedAt'),
            window: BuiltValueNullFieldError.checkNotNull(
                window, r'OpsOverview', 'window'),
            staleFixAfterSeconds: BuiltValueNullFieldError.checkNotNull(
                staleFixAfterSeconds, r'OpsOverview', 'staleFixAfterSeconds'),
            trips: trips.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'trips';
        trips.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'OpsOverview', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
