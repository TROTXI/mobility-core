// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stop_eta.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const StopEtaBasisEnum _$stopEtaBasisEnum_observed =
    const StopEtaBasisEnum._('observed');
const StopEtaBasisEnum _$stopEtaBasisEnum_fallback =
    const StopEtaBasisEnum._('fallback');

StopEtaBasisEnum _$stopEtaBasisEnumValueOf(String name) {
  switch (name) {
    case 'observed':
      return _$stopEtaBasisEnum_observed;
    case 'fallback':
      return _$stopEtaBasisEnum_fallback;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<StopEtaBasisEnum> _$stopEtaBasisEnumValues =
    BuiltSet<StopEtaBasisEnum>(const <StopEtaBasisEnum>[
  _$stopEtaBasisEnum_observed,
  _$stopEtaBasisEnum_fallback,
]);

Serializer<StopEtaBasisEnum> _$stopEtaBasisEnumSerializer =
    _$StopEtaBasisEnumSerializer();

class _$StopEtaBasisEnumSerializer
    implements PrimitiveSerializer<StopEtaBasisEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'observed': 'observed',
    'fallback': 'fallback',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'observed': 'observed',
    'fallback': 'fallback',
  };

  @override
  final Iterable<Type> types = const <Type>[StopEtaBasisEnum];
  @override
  final String wireName = 'StopEtaBasisEnum';

  @override
  Object serialize(Serializers serializers, StopEtaBasisEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  StopEtaBasisEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      StopEtaBasisEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$StopEta extends StopEta {
  @override
  final String stopOccurrenceId;
  @override
  final int durationSeconds;
  @override
  final num distanceMeters;
  @override
  final StopEtaBasisEnum basis;

  factory _$StopEta([void Function(StopEtaBuilder)? updates]) =>
      (StopEtaBuilder()..update(updates))._build();

  _$StopEta._(
      {required this.stopOccurrenceId,
      required this.durationSeconds,
      required this.distanceMeters,
      required this.basis})
      : super._();
  @override
  StopEta rebuild(void Function(StopEtaBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  StopEtaBuilder toBuilder() => StopEtaBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is StopEta &&
        stopOccurrenceId == other.stopOccurrenceId &&
        durationSeconds == other.durationSeconds &&
        distanceMeters == other.distanceMeters &&
        basis == other.basis;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, stopOccurrenceId.hashCode);
    _$hash = $jc(_$hash, durationSeconds.hashCode);
    _$hash = $jc(_$hash, distanceMeters.hashCode);
    _$hash = $jc(_$hash, basis.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'StopEta')
          ..add('stopOccurrenceId', stopOccurrenceId)
          ..add('durationSeconds', durationSeconds)
          ..add('distanceMeters', distanceMeters)
          ..add('basis', basis))
        .toString();
  }
}

class StopEtaBuilder implements Builder<StopEta, StopEtaBuilder> {
  _$StopEta? _$v;

  String? _stopOccurrenceId;
  String? get stopOccurrenceId => _$this._stopOccurrenceId;
  set stopOccurrenceId(String? stopOccurrenceId) =>
      _$this._stopOccurrenceId = stopOccurrenceId;

  int? _durationSeconds;
  int? get durationSeconds => _$this._durationSeconds;
  set durationSeconds(int? durationSeconds) =>
      _$this._durationSeconds = durationSeconds;

  num? _distanceMeters;
  num? get distanceMeters => _$this._distanceMeters;
  set distanceMeters(num? distanceMeters) =>
      _$this._distanceMeters = distanceMeters;

  StopEtaBasisEnum? _basis;
  StopEtaBasisEnum? get basis => _$this._basis;
  set basis(StopEtaBasisEnum? basis) => _$this._basis = basis;

  StopEtaBuilder() {
    StopEta._defaults(this);
  }

  StopEtaBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _stopOccurrenceId = $v.stopOccurrenceId;
      _durationSeconds = $v.durationSeconds;
      _distanceMeters = $v.distanceMeters;
      _basis = $v.basis;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(StopEta other) {
    _$v = other as _$StopEta;
  }

  @override
  void update(void Function(StopEtaBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  StopEta build() => _build();

  _$StopEta _build() {
    final _$result = _$v ??
        _$StopEta._(
          stopOccurrenceId: BuiltValueNullFieldError.checkNotNull(
              stopOccurrenceId, r'StopEta', 'stopOccurrenceId'),
          durationSeconds: BuiltValueNullFieldError.checkNotNull(
              durationSeconds, r'StopEta', 'durationSeconds'),
          distanceMeters: BuiltValueNullFieldError.checkNotNull(
              distanceMeters, r'StopEta', 'distanceMeters'),
          basis:
              BuiltValueNullFieldError.checkNotNull(basis, r'StopEta', 'basis'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
