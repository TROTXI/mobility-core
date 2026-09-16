// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const TripInputRunNumberEnum _$tripInputRunNumberEnum_number1 =
    const TripInputRunNumberEnum._('number1');

TripInputRunNumberEnum _$tripInputRunNumberEnumValueOf(String name) {
  switch (name) {
    case 'number1':
      return _$tripInputRunNumberEnum_number1;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<TripInputRunNumberEnum> _$tripInputRunNumberEnumValues =
    BuiltSet<TripInputRunNumberEnum>(const <TripInputRunNumberEnum>[
  _$tripInputRunNumberEnum_number1,
]);

Serializer<TripInputRunNumberEnum> _$tripInputRunNumberEnumSerializer =
    _$TripInputRunNumberEnumSerializer();

class _$TripInputRunNumberEnumSerializer
    implements PrimitiveSerializer<TripInputRunNumberEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number1': 1,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    1: 'number1',
  };

  @override
  final Iterable<Type> types = const <Type>[TripInputRunNumberEnum];
  @override
  final String wireName = 'TripInputRunNumberEnum';

  @override
  Object serialize(Serializers serializers, TripInputRunNumberEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  TripInputRunNumberEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      TripInputRunNumberEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$TripInput extends TripInput {
  @override
  final String scheduleId;
  @override
  final Date serviceDate;
  @override
  final TripInputRunNumberEnum? runNumber;
  @override
  final DateTime scheduledAt;

  factory _$TripInput([void Function(TripInputBuilder)? updates]) =>
      (TripInputBuilder()..update(updates))._build();

  _$TripInput._(
      {required this.scheduleId,
      required this.serviceDate,
      this.runNumber,
      required this.scheduledAt})
      : super._();
  @override
  TripInput rebuild(void Function(TripInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TripInputBuilder toBuilder() => TripInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TripInput &&
        scheduleId == other.scheduleId &&
        serviceDate == other.serviceDate &&
        runNumber == other.runNumber &&
        scheduledAt == other.scheduledAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, scheduleId.hashCode);
    _$hash = $jc(_$hash, serviceDate.hashCode);
    _$hash = $jc(_$hash, runNumber.hashCode);
    _$hash = $jc(_$hash, scheduledAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TripInput')
          ..add('scheduleId', scheduleId)
          ..add('serviceDate', serviceDate)
          ..add('runNumber', runNumber)
          ..add('scheduledAt', scheduledAt))
        .toString();
  }
}

class TripInputBuilder implements Builder<TripInput, TripInputBuilder> {
  _$TripInput? _$v;

  String? _scheduleId;
  String? get scheduleId => _$this._scheduleId;
  set scheduleId(String? scheduleId) => _$this._scheduleId = scheduleId;

  Date? _serviceDate;
  Date? get serviceDate => _$this._serviceDate;
  set serviceDate(Date? serviceDate) => _$this._serviceDate = serviceDate;

  TripInputRunNumberEnum? _runNumber;
  TripInputRunNumberEnum? get runNumber => _$this._runNumber;
  set runNumber(TripInputRunNumberEnum? runNumber) =>
      _$this._runNumber = runNumber;

  DateTime? _scheduledAt;
  DateTime? get scheduledAt => _$this._scheduledAt;
  set scheduledAt(DateTime? scheduledAt) => _$this._scheduledAt = scheduledAt;

  TripInputBuilder() {
    TripInput._defaults(this);
  }

  TripInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _scheduleId = $v.scheduleId;
      _serviceDate = $v.serviceDate;
      _runNumber = $v.runNumber;
      _scheduledAt = $v.scheduledAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TripInput other) {
    _$v = other as _$TripInput;
  }

  @override
  void update(void Function(TripInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TripInput build() => _build();

  _$TripInput _build() {
    final _$result = _$v ??
        _$TripInput._(
          scheduleId: BuiltValueNullFieldError.checkNotNull(
              scheduleId, r'TripInput', 'scheduleId'),
          serviceDate: BuiltValueNullFieldError.checkNotNull(
              serviceDate, r'TripInput', 'serviceDate'),
          runNumber: runNumber,
          scheduledAt: BuiltValueNullFieldError.checkNotNull(
              scheduledAt, r'TripInput', 'scheduledAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
