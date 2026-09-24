// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'personal_pause.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PersonalPauseStatusEnum _$personalPauseStatusEnum_scheduled =
    const PersonalPauseStatusEnum._('scheduled');
const PersonalPauseStatusEnum _$personalPauseStatusEnum_paused =
    const PersonalPauseStatusEnum._('paused');
const PersonalPauseStatusEnum _$personalPauseStatusEnum_resumed =
    const PersonalPauseStatusEnum._('resumed');
const PersonalPauseStatusEnum _$personalPauseStatusEnum_terminated =
    const PersonalPauseStatusEnum._('terminated');

PersonalPauseStatusEnum _$personalPauseStatusEnumValueOf(String name) {
  switch (name) {
    case 'scheduled':
      return _$personalPauseStatusEnum_scheduled;
    case 'paused':
      return _$personalPauseStatusEnum_paused;
    case 'resumed':
      return _$personalPauseStatusEnum_resumed;
    case 'terminated':
      return _$personalPauseStatusEnum_terminated;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PersonalPauseStatusEnum> _$personalPauseStatusEnumValues =
    BuiltSet<PersonalPauseStatusEnum>(const <PersonalPauseStatusEnum>[
  _$personalPauseStatusEnum_scheduled,
  _$personalPauseStatusEnum_paused,
  _$personalPauseStatusEnum_resumed,
  _$personalPauseStatusEnum_terminated,
]);

Serializer<PersonalPauseStatusEnum> _$personalPauseStatusEnumSerializer =
    _$PersonalPauseStatusEnumSerializer();

class _$PersonalPauseStatusEnumSerializer
    implements PrimitiveSerializer<PersonalPauseStatusEnum> {
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
  final Iterable<Type> types = const <Type>[PersonalPauseStatusEnum];
  @override
  final String wireName = 'PersonalPauseStatusEnum';

  @override
  Object serialize(Serializers serializers, PersonalPauseStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PersonalPauseStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PersonalPauseStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PersonalPause extends PersonalPause {
  @override
  final String id;
  @override
  final Date startDate;
  @override
  final Date resumeDate;
  @override
  final PersonalPauseStatusEnum status;
  @override
  final DateTime? projectedEndsAt;
  @override
  final bool extensionApplied;

  factory _$PersonalPause([void Function(PersonalPauseBuilder)? updates]) =>
      (PersonalPauseBuilder()..update(updates))._build();

  _$PersonalPause._(
      {required this.id,
      required this.startDate,
      required this.resumeDate,
      required this.status,
      this.projectedEndsAt,
      required this.extensionApplied})
      : super._();
  @override
  PersonalPause rebuild(void Function(PersonalPauseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PersonalPauseBuilder toBuilder() => PersonalPauseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PersonalPause &&
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
    return (newBuiltValueToStringHelper(r'PersonalPause')
          ..add('id', id)
          ..add('startDate', startDate)
          ..add('resumeDate', resumeDate)
          ..add('status', status)
          ..add('projectedEndsAt', projectedEndsAt)
          ..add('extensionApplied', extensionApplied))
        .toString();
  }
}

class PersonalPauseBuilder
    implements Builder<PersonalPause, PersonalPauseBuilder> {
  _$PersonalPause? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  Date? _startDate;
  Date? get startDate => _$this._startDate;
  set startDate(Date? startDate) => _$this._startDate = startDate;

  Date? _resumeDate;
  Date? get resumeDate => _$this._resumeDate;
  set resumeDate(Date? resumeDate) => _$this._resumeDate = resumeDate;

  PersonalPauseStatusEnum? _status;
  PersonalPauseStatusEnum? get status => _$this._status;
  set status(PersonalPauseStatusEnum? status) => _$this._status = status;

  DateTime? _projectedEndsAt;
  DateTime? get projectedEndsAt => _$this._projectedEndsAt;
  set projectedEndsAt(DateTime? projectedEndsAt) =>
      _$this._projectedEndsAt = projectedEndsAt;

  bool? _extensionApplied;
  bool? get extensionApplied => _$this._extensionApplied;
  set extensionApplied(bool? extensionApplied) =>
      _$this._extensionApplied = extensionApplied;

  PersonalPauseBuilder() {
    PersonalPause._defaults(this);
  }

  PersonalPauseBuilder get _$this {
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
  void replace(PersonalPause other) {
    _$v = other as _$PersonalPause;
  }

  @override
  void update(void Function(PersonalPauseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PersonalPause build() => _build();

  _$PersonalPause _build() {
    final _$result = _$v ??
        _$PersonalPause._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'PersonalPause', 'id'),
          startDate: BuiltValueNullFieldError.checkNotNull(
              startDate, r'PersonalPause', 'startDate'),
          resumeDate: BuiltValueNullFieldError.checkNotNull(
              resumeDate, r'PersonalPause', 'resumeDate'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'PersonalPause', 'status'),
          projectedEndsAt: projectedEndsAt,
          extensionApplied: BuiltValueNullFieldError.checkNotNull(
              extensionApplied, r'PersonalPause', 'extensionApplied'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
