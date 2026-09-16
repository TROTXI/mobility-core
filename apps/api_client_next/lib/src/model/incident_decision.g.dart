// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'incident_decision.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const IncidentDecisionStatusEnum _$incidentDecisionStatusEnum_acknowledged =
    const IncidentDecisionStatusEnum._('acknowledged');
const IncidentDecisionStatusEnum _$incidentDecisionStatusEnum_resolved =
    const IncidentDecisionStatusEnum._('resolved');

IncidentDecisionStatusEnum _$incidentDecisionStatusEnumValueOf(String name) {
  switch (name) {
    case 'acknowledged':
      return _$incidentDecisionStatusEnum_acknowledged;
    case 'resolved':
      return _$incidentDecisionStatusEnum_resolved;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<IncidentDecisionStatusEnum> _$incidentDecisionStatusEnumValues =
    BuiltSet<IncidentDecisionStatusEnum>(const <IncidentDecisionStatusEnum>[
  _$incidentDecisionStatusEnum_acknowledged,
  _$incidentDecisionStatusEnum_resolved,
]);

Serializer<IncidentDecisionStatusEnum> _$incidentDecisionStatusEnumSerializer =
    _$IncidentDecisionStatusEnumSerializer();

class _$IncidentDecisionStatusEnumSerializer
    implements PrimitiveSerializer<IncidentDecisionStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'acknowledged': 'acknowledged',
    'resolved': 'resolved',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'acknowledged': 'acknowledged',
    'resolved': 'resolved',
  };

  @override
  final Iterable<Type> types = const <Type>[IncidentDecisionStatusEnum];
  @override
  final String wireName = 'IncidentDecisionStatusEnum';

  @override
  Object serialize(Serializers serializers, IncidentDecisionStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  IncidentDecisionStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      IncidentDecisionStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$IncidentDecision extends IncidentDecision {
  @override
  final IncidentDecisionStatusEnum status;
  @override
  final String resolution;

  factory _$IncidentDecision(
          [void Function(IncidentDecisionBuilder)? updates]) =>
      (IncidentDecisionBuilder()..update(updates))._build();

  _$IncidentDecision._({required this.status, required this.resolution})
      : super._();
  @override
  IncidentDecision rebuild(void Function(IncidentDecisionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  IncidentDecisionBuilder toBuilder() =>
      IncidentDecisionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is IncidentDecision &&
        status == other.status &&
        resolution == other.resolution;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, resolution.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'IncidentDecision')
          ..add('status', status)
          ..add('resolution', resolution))
        .toString();
  }
}

class IncidentDecisionBuilder
    implements Builder<IncidentDecision, IncidentDecisionBuilder> {
  _$IncidentDecision? _$v;

  IncidentDecisionStatusEnum? _status;
  IncidentDecisionStatusEnum? get status => _$this._status;
  set status(IncidentDecisionStatusEnum? status) => _$this._status = status;

  String? _resolution;
  String? get resolution => _$this._resolution;
  set resolution(String? resolution) => _$this._resolution = resolution;

  IncidentDecisionBuilder() {
    IncidentDecision._defaults(this);
  }

  IncidentDecisionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _status = $v.status;
      _resolution = $v.resolution;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(IncidentDecision other) {
    _$v = other as _$IncidentDecision;
  }

  @override
  void update(void Function(IncidentDecisionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  IncidentDecision build() => _build();

  _$IncidentDecision _build() {
    final _$result = _$v ??
        _$IncidentDecision._(
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'IncidentDecision', 'status'),
          resolution: BuiltValueNullFieldError.checkNotNull(
              resolution, r'IncidentDecision', 'resolution'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
