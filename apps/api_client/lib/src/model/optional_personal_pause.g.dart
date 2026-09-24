// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'optional_personal_pause.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const OptionalPersonalPauseStatusEnum
    _$optionalPersonalPauseStatusEnum_scheduled =
    const OptionalPersonalPauseStatusEnum._('scheduled');
const OptionalPersonalPauseStatusEnum _$optionalPersonalPauseStatusEnum_paused =
    const OptionalPersonalPauseStatusEnum._('paused');
const OptionalPersonalPauseStatusEnum
    _$optionalPersonalPauseStatusEnum_resumed =
    const OptionalPersonalPauseStatusEnum._('resumed');
const OptionalPersonalPauseStatusEnum
    _$optionalPersonalPauseStatusEnum_terminated =
    const OptionalPersonalPauseStatusEnum._('terminated');

OptionalPersonalPauseStatusEnum _$optionalPersonalPauseStatusEnumValueOf(
    String name) {
  switch (name) {
    case 'scheduled':
      return _$optionalPersonalPauseStatusEnum_scheduled;
    case 'paused':
      return _$optionalPersonalPauseStatusEnum_paused;
    case 'resumed':
      return _$optionalPersonalPauseStatusEnum_resumed;
    case 'terminated':
      return _$optionalPersonalPauseStatusEnum_terminated;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<OptionalPersonalPauseStatusEnum>
    _$optionalPersonalPauseStatusEnumValues = BuiltSet<
        OptionalPersonalPauseStatusEnum>(const <OptionalPersonalPauseStatusEnum>[
  _$optionalPersonalPauseStatusEnum_scheduled,
  _$optionalPersonalPauseStatusEnum_paused,
  _$optionalPersonalPauseStatusEnum_resumed,
  _$optionalPersonalPauseStatusEnum_terminated,
]);

Serializer<OptionalPersonalPauseStatusEnum>
    _$optionalPersonalPauseStatusEnumSerializer =
    _$OptionalPersonalPauseStatusEnumSerializer();

class _$OptionalPersonalPauseStatusEnumSerializer
    implements PrimitiveSerializer<OptionalPersonalPauseStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'scheduled': 'scheduled',
    'paused': 'paused',
    'resumed': 'resumed',
    'terminated': 'terminated',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'scheduled': 'scheduled',
    'paused': 'paused',
    'resumed': 'resumed',
    'terminated': 'terminated',
  };

  @override
  final Iterable<Type> types = const <Type>[OptionalPersonalPauseStatusEnum];
  @override
  final String wireName = 'OptionalPersonalPauseStatusEnum';

  @override
  Object serialize(
          Serializers serializers, OptionalPersonalPauseStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  OptionalPersonalPauseStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      OptionalPersonalPauseStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$OptionalPersonalPause extends OptionalPersonalPause {
  @override
  final String id;
  @override
  final Date startDate;
  @override
  final Date resumeDate;
  @override
  final OptionalPersonalPauseStatusEnum status;
  @override
  final DateTime? projectedEndsAt;
  @override
  final bool extensionApplied;

  factory _$OptionalPersonalPause(
          [void Function(OptionalPersonalPauseBuilder)? updates]) =>
      (OptionalPersonalPauseBuilder()..update(updates))._build();

  _$OptionalPersonalPause._(
      {required this.id,
      required this.startDate,
      required this.resumeDate,
      required this.status,
      this.projectedEndsAt,
      required this.extensionApplied})
      : super._();
  @override
  OptionalPersonalPause rebuild(
          void Function(OptionalPersonalPauseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OptionalPersonalPauseBuilder toBuilder() =>
      OptionalPersonalPauseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OptionalPersonalPause &&
        id == other.id &&
        startDate == other.startDate &&
        resumeDate == other.resumeDate &&
        status == other.status &&
        projectedEndsAt == other.projectedEndsAt &&
        extensionApplied == other.extensionApplied;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, startDate.hashCode);
    _$hash = $jc(_$hash, resumeDate.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, projectedEndsAt.hashCode);
    _$hash = $jc(_$hash, extensionApplied.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OptionalPersonalPause')
          ..add('id', id)
          ..add('startDate', startDate)
          ..add('resumeDate', resumeDate)
          ..add('status', status)
          ..add('projectedEndsAt', projectedEndsAt)
          ..add('extensionApplied', extensionApplied))
        .toString();
  }
}

class OptionalPersonalPauseBuilder
    implements Builder<OptionalPersonalPause, OptionalPersonalPauseBuilder> {
  _$OptionalPersonalPause? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  Date? _startDate;
  Date? get startDate => _$this._startDate;
  set startDate(Date? startDate) => _$this._startDate = startDate;

  Date? _resumeDate;
  Date? get resumeDate => _$this._resumeDate;
  set resumeDate(Date? resumeDate) => _$this._resumeDate = resumeDate;

  OptionalPersonalPauseStatusEnum? _status;
  OptionalPersonalPauseStatusEnum? get status => _$this._status;
  set status(OptionalPersonalPauseStatusEnum? status) =>
      _$this._status = status;

  DateTime? _projectedEndsAt;
  DateTime? get projectedEndsAt => _$this._projectedEndsAt;
  set projectedEndsAt(DateTime? projectedEndsAt) =>
      _$this._projectedEndsAt = projectedEndsAt;

  bool? _extensionApplied;
  bool? get extensionApplied => _$this._extensionApplied;
  set extensionApplied(bool? extensionApplied) =>
      _$this._extensionApplied = extensionApplied;

  OptionalPersonalPauseBuilder() {
    OptionalPersonalPause._defaults(this);
  }

  OptionalPersonalPauseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _startDate = $v.startDate;
      _resumeDate = $v.resumeDate;
      _status = $v.status;
      _projectedEndsAt = $v.projectedEndsAt;
      _extensionApplied = $v.extensionApplied;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OptionalPersonalPause other) {
    _$v = other as _$OptionalPersonalPause;
  }

  @override
  void update(void Function(OptionalPersonalPauseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OptionalPersonalPause build() => _build();

  _$OptionalPersonalPause _build() {
    final _$result = _$v ??
        _$OptionalPersonalPause._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'OptionalPersonalPause', 'id'),
          startDate: BuiltValueNullFieldError.checkNotNull(
              startDate, r'OptionalPersonalPause', 'startDate'),
          resumeDate: BuiltValueNullFieldError.checkNotNull(
              resumeDate, r'OptionalPersonalPause', 'resumeDate'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'OptionalPersonalPause', 'status'),
          projectedEndsAt: projectedEndsAt,
          extensionApplied: BuiltValueNullFieldError.checkNotNull(
              extensionApplied, r'OptionalPersonalPause', 'extensionApplied'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
