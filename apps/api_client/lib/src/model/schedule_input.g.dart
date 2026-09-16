// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ScheduleInputServiceWindowEnum _$scheduleInputServiceWindowEnum_morning =
    const ScheduleInputServiceWindowEnum._('morning');
const ScheduleInputServiceWindowEnum _$scheduleInputServiceWindowEnum_evening =
    const ScheduleInputServiceWindowEnum._('evening');

ScheduleInputServiceWindowEnum _$scheduleInputServiceWindowEnumValueOf(
    String name) {
  switch (name) {
    case 'morning':
      return _$scheduleInputServiceWindowEnum_morning;
    case 'evening':
      return _$scheduleInputServiceWindowEnum_evening;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ScheduleInputServiceWindowEnum>
    _$scheduleInputServiceWindowEnumValues = BuiltSet<
        ScheduleInputServiceWindowEnum>(const <ScheduleInputServiceWindowEnum>[
  _$scheduleInputServiceWindowEnum_morning,
  _$scheduleInputServiceWindowEnum_evening,
]);

const ScheduleInputTimeZoneEnum _$scheduleInputTimeZoneEnum_africaSlashAccra =
    const ScheduleInputTimeZoneEnum._('africaSlashAccra');

ScheduleInputTimeZoneEnum _$scheduleInputTimeZoneEnumValueOf(String name) {
  switch (name) {
    case 'africaSlashAccra':
      return _$scheduleInputTimeZoneEnum_africaSlashAccra;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ScheduleInputTimeZoneEnum> _$scheduleInputTimeZoneEnumValues =
    BuiltSet<ScheduleInputTimeZoneEnum>(const <ScheduleInputTimeZoneEnum>[
  _$scheduleInputTimeZoneEnum_africaSlashAccra,
]);

Serializer<ScheduleInputServiceWindowEnum>
    _$scheduleInputServiceWindowEnumSerializer =
    _$ScheduleInputServiceWindowEnumSerializer();
Serializer<ScheduleInputTimeZoneEnum> _$scheduleInputTimeZoneEnumSerializer =
    _$ScheduleInputTimeZoneEnumSerializer();

class _$ScheduleInputServiceWindowEnumSerializer
    implements PrimitiveSerializer<ScheduleInputServiceWindowEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'morning': 'morning',
    'evening': 'evening',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'morning': 'morning',
    'evening': 'evening',
  };

  @override
  final Iterable<Type> types = const <Type>[ScheduleInputServiceWindowEnum];
  @override
  final String wireName = 'ScheduleInputServiceWindowEnum';

  @override
  Object serialize(
          Serializers serializers, ScheduleInputServiceWindowEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ScheduleInputServiceWindowEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ScheduleInputServiceWindowEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ScheduleInputTimeZoneEnumSerializer
    implements PrimitiveSerializer<ScheduleInputTimeZoneEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'africaSlashAccra': 'Africa/Accra',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'Africa/Accra': 'africaSlashAccra',
  };

  @override
  final Iterable<Type> types = const <Type>[ScheduleInputTimeZoneEnum];
  @override
  final String wireName = 'ScheduleInputTimeZoneEnum';

  @override
  Object serialize(Serializers serializers, ScheduleInputTimeZoneEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ScheduleInputTimeZoneEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ScheduleInputTimeZoneEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ScheduleInput extends ScheduleInput {
  @override
  final ScheduleInputDeparture departure;
  @override
  final String patternVersionId;
  @override
  final ScheduleInputServiceWindowEnum serviceWindow;
  @override
  final String localDeparture;
  @override
  final ScheduleInputTimeZoneEnum timeZone;
  @override
  final BuiltList<int> weekdays;
  @override
  final Date effectiveFrom;
  @override
  final Date? effectiveTo;

  factory _$ScheduleInput([void Function(ScheduleInputBuilder)? updates]) =>
      (ScheduleInputBuilder()..update(updates))._build();

  _$ScheduleInput._(
      {required this.departure,
      required this.patternVersionId,
      required this.serviceWindow,
      required this.localDeparture,
      required this.timeZone,
      required this.weekdays,
      required this.effectiveFrom,
      this.effectiveTo})
      : super._();
  @override
  ScheduleInput rebuild(void Function(ScheduleInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ScheduleInputBuilder toBuilder() => ScheduleInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ScheduleInput &&
        departure == other.departure &&
        patternVersionId == other.patternVersionId &&
        serviceWindow == other.serviceWindow &&
        localDeparture == other.localDeparture &&
        timeZone == other.timeZone &&
        weekdays == other.weekdays &&
        effectiveFrom == other.effectiveFrom &&
        effectiveTo == other.effectiveTo;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, departure.hashCode);
    _$hash = $jc(_$hash, patternVersionId.hashCode);
    _$hash = $jc(_$hash, serviceWindow.hashCode);
    _$hash = $jc(_$hash, localDeparture.hashCode);
    _$hash = $jc(_$hash, timeZone.hashCode);
    _$hash = $jc(_$hash, weekdays.hashCode);
    _$hash = $jc(_$hash, effectiveFrom.hashCode);
    _$hash = $jc(_$hash, effectiveTo.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ScheduleInput')
          ..add('departure', departure)
          ..add('patternVersionId', patternVersionId)
          ..add('serviceWindow', serviceWindow)
          ..add('localDeparture', localDeparture)
          ..add('timeZone', timeZone)
          ..add('weekdays', weekdays)
          ..add('effectiveFrom', effectiveFrom)
          ..add('effectiveTo', effectiveTo))
        .toString();
  }
}

class ScheduleInputBuilder
    implements Builder<ScheduleInput, ScheduleInputBuilder> {
  _$ScheduleInput? _$v;

  ScheduleInputDepartureBuilder? _departure;
  ScheduleInputDepartureBuilder get departure =>
      _$this._departure ??= ScheduleInputDepartureBuilder();
  set departure(ScheduleInputDepartureBuilder? departure) =>
      _$this._departure = departure;

  String? _patternVersionId;
  String? get patternVersionId => _$this._patternVersionId;
  set patternVersionId(String? patternVersionId) =>
      _$this._patternVersionId = patternVersionId;

  ScheduleInputServiceWindowEnum? _serviceWindow;
  ScheduleInputServiceWindowEnum? get serviceWindow => _$this._serviceWindow;
  set serviceWindow(ScheduleInputServiceWindowEnum? serviceWindow) =>
      _$this._serviceWindow = serviceWindow;

  String? _localDeparture;
  String? get localDeparture => _$this._localDeparture;
  set localDeparture(String? localDeparture) =>
      _$this._localDeparture = localDeparture;

  ScheduleInputTimeZoneEnum? _timeZone;
  ScheduleInputTimeZoneEnum? get timeZone => _$this._timeZone;
  set timeZone(ScheduleInputTimeZoneEnum? timeZone) =>
      _$this._timeZone = timeZone;

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

  ScheduleInputBuilder() {
    ScheduleInput._defaults(this);
  }

  ScheduleInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _departure = $v.departure.toBuilder();
      _patternVersionId = $v.patternVersionId;
      _serviceWindow = $v.serviceWindow;
      _localDeparture = $v.localDeparture;
      _timeZone = $v.timeZone;
      _weekdays = $v.weekdays.toBuilder();
      _effectiveFrom = $v.effectiveFrom;
      _effectiveTo = $v.effectiveTo;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ScheduleInput other) {
    _$v = other as _$ScheduleInput;
  }

  @override
  void update(void Function(ScheduleInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ScheduleInput build() => _build();

  _$ScheduleInput _build() {
    _$ScheduleInput _$result;
    try {
      _$result = _$v ??
          _$ScheduleInput._(
            departure: departure.build(),
            patternVersionId: BuiltValueNullFieldError.checkNotNull(
                patternVersionId, r'ScheduleInput', 'patternVersionId'),
            serviceWindow: BuiltValueNullFieldError.checkNotNull(
                serviceWindow, r'ScheduleInput', 'serviceWindow'),
            localDeparture: BuiltValueNullFieldError.checkNotNull(
                localDeparture, r'ScheduleInput', 'localDeparture'),
            timeZone: BuiltValueNullFieldError.checkNotNull(
                timeZone, r'ScheduleInput', 'timeZone'),
            weekdays: weekdays.build(),
            effectiveFrom: BuiltValueNullFieldError.checkNotNull(
                effectiveFrom, r'ScheduleInput', 'effectiveFrom'),
            effectiveTo: effectiveTo,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'departure';
        departure.build();

        _$failedField = 'weekdays';
        weekdays.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ScheduleInput', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
