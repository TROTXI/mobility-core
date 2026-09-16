// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ScheduleServiceWindowEnum _$scheduleServiceWindowEnum_morning =
    const ScheduleServiceWindowEnum._('morning');
const ScheduleServiceWindowEnum _$scheduleServiceWindowEnum_evening =
    const ScheduleServiceWindowEnum._('evening');

ScheduleServiceWindowEnum _$scheduleServiceWindowEnumValueOf(String name) {
  switch (name) {
    case 'morning':
      return _$scheduleServiceWindowEnum_morning;
    case 'evening':
      return _$scheduleServiceWindowEnum_evening;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ScheduleServiceWindowEnum> _$scheduleServiceWindowEnumValues =
    BuiltSet<ScheduleServiceWindowEnum>(const <ScheduleServiceWindowEnum>[
  _$scheduleServiceWindowEnum_morning,
  _$scheduleServiceWindowEnum_evening,
]);

const ScheduleTimeZoneEnum _$scheduleTimeZoneEnum_africaSlashAccra =
    const ScheduleTimeZoneEnum._('africaSlashAccra');

ScheduleTimeZoneEnum _$scheduleTimeZoneEnumValueOf(String name) {
  switch (name) {
    case 'africaSlashAccra':
      return _$scheduleTimeZoneEnum_africaSlashAccra;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ScheduleTimeZoneEnum> _$scheduleTimeZoneEnumValues =
    BuiltSet<ScheduleTimeZoneEnum>(const <ScheduleTimeZoneEnum>[
  _$scheduleTimeZoneEnum_africaSlashAccra,
]);

Serializer<ScheduleServiceWindowEnum> _$scheduleServiceWindowEnumSerializer =
    _$ScheduleServiceWindowEnumSerializer();
Serializer<ScheduleTimeZoneEnum> _$scheduleTimeZoneEnumSerializer =
    _$ScheduleTimeZoneEnumSerializer();

class _$ScheduleServiceWindowEnumSerializer
    implements PrimitiveSerializer<ScheduleServiceWindowEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'morning': 'morning',
    'evening': 'evening',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'morning': 'morning',
    'evening': 'evening',
  };

  @override
  final Iterable<Type> types = const <Type>[ScheduleServiceWindowEnum];
  @override
  final String wireName = 'ScheduleServiceWindowEnum';

  @override
  Object serialize(Serializers serializers, ScheduleServiceWindowEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ScheduleServiceWindowEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ScheduleServiceWindowEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ScheduleTimeZoneEnumSerializer
    implements PrimitiveSerializer<ScheduleTimeZoneEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'africaSlashAccra': 'Africa/Accra',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'Africa/Accra': 'africaSlashAccra',
  };

  @override
  final Iterable<Type> types = const <Type>[ScheduleTimeZoneEnum];
  @override
  final String wireName = 'ScheduleTimeZoneEnum';

  @override
  Object serialize(Serializers serializers, ScheduleTimeZoneEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ScheduleTimeZoneEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ScheduleTimeZoneEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$Schedule extends Schedule {
  @override
  final String id;
  @override
  final String departureId;
  @override
  final String patternVersionId;
  @override
  final ScheduleServiceWindowEnum serviceWindow;
  @override
  final String localDeparture;
  @override
  final ScheduleTimeZoneEnum timeZone;
  @override
  final BuiltList<int> weekdays;
  @override
  final Date effectiveFrom;
  @override
  final Date? effectiveTo;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final int version;

  factory _$Schedule([void Function(ScheduleBuilder)? updates]) =>
      (ScheduleBuilder()..update(updates))._build();

  _$Schedule._(
      {required this.id,
      required this.departureId,
      required this.patternVersionId,
      required this.serviceWindow,
      required this.localDeparture,
      required this.timeZone,
      required this.weekdays,
      required this.effectiveFrom,
      this.effectiveTo,
      required this.createdAt,
      required this.updatedAt,
      required this.version})
      : super._();
  @override
  Schedule rebuild(void Function(ScheduleBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ScheduleBuilder toBuilder() => ScheduleBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Schedule &&
        id == other.id &&
        departureId == other.departureId &&
        patternVersionId == other.patternVersionId &&
        serviceWindow == other.serviceWindow &&
        localDeparture == other.localDeparture &&
        timeZone == other.timeZone &&
        weekdays == other.weekdays &&
        effectiveFrom == other.effectiveFrom &&
        effectiveTo == other.effectiveTo &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        version == other.version;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, departureId.hashCode);
    _$hash = $jc(_$hash, patternVersionId.hashCode);
    _$hash = $jc(_$hash, serviceWindow.hashCode);
    _$hash = $jc(_$hash, localDeparture.hashCode);
    _$hash = $jc(_$hash, timeZone.hashCode);
    _$hash = $jc(_$hash, weekdays.hashCode);
    _$hash = $jc(_$hash, effectiveFrom.hashCode);
    _$hash = $jc(_$hash, effectiveTo.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Schedule')
          ..add('id', id)
          ..add('departureId', departureId)
          ..add('patternVersionId', patternVersionId)
          ..add('serviceWindow', serviceWindow)
          ..add('localDeparture', localDeparture)
          ..add('timeZone', timeZone)
          ..add('weekdays', weekdays)
          ..add('effectiveFrom', effectiveFrom)
          ..add('effectiveTo', effectiveTo)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt)
          ..add('version', version))
        .toString();
  }
}

class ScheduleBuilder implements Builder<Schedule, ScheduleBuilder> {
  _$Schedule? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _departureId;
  String? get departureId => _$this._departureId;
  set departureId(String? departureId) => _$this._departureId = departureId;

  String? _patternVersionId;
  String? get patternVersionId => _$this._patternVersionId;
  set patternVersionId(String? patternVersionId) =>
      _$this._patternVersionId = patternVersionId;

  ScheduleServiceWindowEnum? _serviceWindow;
  ScheduleServiceWindowEnum? get serviceWindow => _$this._serviceWindow;
  set serviceWindow(ScheduleServiceWindowEnum? serviceWindow) =>
      _$this._serviceWindow = serviceWindow;

  String? _localDeparture;
  String? get localDeparture => _$this._localDeparture;
  set localDeparture(String? localDeparture) =>
      _$this._localDeparture = localDeparture;

  ScheduleTimeZoneEnum? _timeZone;
  ScheduleTimeZoneEnum? get timeZone => _$this._timeZone;
  set timeZone(ScheduleTimeZoneEnum? timeZone) => _$this._timeZone = timeZone;

  ListBuilder<int>? _weekdays;
  ListBuilder<int> get weekdays => _$this._weekdays ??= ListBuilder<int>();
  set weekdays(ListBuilder<int>? weekdays) => _$this._weekdays = weekdays;

  Date? _effectiveFrom;
  Date? get effectiveFrom => _$this._effectiveFrom;
  set effectiveFrom(Date? effectiveFrom) =>
      _$this._effectiveFrom = effectiveFrom;

  Date? _effectiveTo;
  Date? get effectiveTo => _$this._effectiveTo;
  set effectiveTo(Date? effectiveTo) => _$this._effectiveTo = effectiveTo;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  int? _version;
  int? get version => _$this._version;
  set version(int? version) => _$this._version = version;

  ScheduleBuilder() {
    Schedule._defaults(this);
  }

  ScheduleBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _departureId = $v.departureId;
      _patternVersionId = $v.patternVersionId;
      _serviceWindow = $v.serviceWindow;
      _localDeparture = $v.localDeparture;
      _timeZone = $v.timeZone;
      _weekdays = $v.weekdays.toBuilder();
      _effectiveFrom = $v.effectiveFrom;
      _effectiveTo = $v.effectiveTo;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _version = $v.version;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Schedule other) {
    _$v = other as _$Schedule;
  }

  @override
  void update(void Function(ScheduleBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Schedule build() => _build();

  _$Schedule _build() {
    _$Schedule _$result;
    try {
      _$result = _$v ??
          _$Schedule._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'Schedule', 'id'),
            departureId: BuiltValueNullFieldError.checkNotNull(
                departureId, r'Schedule', 'departureId'),
            patternVersionId: BuiltValueNullFieldError.checkNotNull(
                patternVersionId, r'Schedule', 'patternVersionId'),
            serviceWindow: BuiltValueNullFieldError.checkNotNull(
                serviceWindow, r'Schedule', 'serviceWindow'),
            localDeparture: BuiltValueNullFieldError.checkNotNull(
                localDeparture, r'Schedule', 'localDeparture'),
            timeZone: BuiltValueNullFieldError.checkNotNull(
                timeZone, r'Schedule', 'timeZone'),
            weekdays: weekdays.build(),
            effectiveFrom: BuiltValueNullFieldError.checkNotNull(
                effectiveFrom, r'Schedule', 'effectiveFrom'),
            effectiveTo: effectiveTo,
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'Schedule', 'createdAt'),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
                updatedAt, r'Schedule', 'updatedAt'),
            version: BuiltValueNullFieldError.checkNotNull(
                version, r'Schedule', 'version'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'weekdays';
        weekdays.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'Schedule', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
