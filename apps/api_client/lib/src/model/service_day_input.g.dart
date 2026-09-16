// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_day_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ServiceDayInputDirectionEnum _$serviceDayInputDirectionEnum_outbound =
    const ServiceDayInputDirectionEnum._('outbound');
const ServiceDayInputDirectionEnum _$serviceDayInputDirectionEnum_return_ =
    const ServiceDayInputDirectionEnum._('return_');

ServiceDayInputDirectionEnum _$serviceDayInputDirectionEnumValueOf(
    String name) {
  switch (name) {
    case 'outbound':
      return _$serviceDayInputDirectionEnum_outbound;
    case 'return_':
      return _$serviceDayInputDirectionEnum_return_;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ServiceDayInputDirectionEnum>
    _$serviceDayInputDirectionEnumValues =
    BuiltSet<ServiceDayInputDirectionEnum>(const <ServiceDayInputDirectionEnum>[
  _$serviceDayInputDirectionEnum_outbound,
  _$serviceDayInputDirectionEnum_return_,
]);

Serializer<ServiceDayInputDirectionEnum>
    _$serviceDayInputDirectionEnumSerializer =
    _$ServiceDayInputDirectionEnumSerializer();

class _$ServiceDayInputDirectionEnumSerializer
    implements PrimitiveSerializer<ServiceDayInputDirectionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'outbound': 'outbound',
    'return_': 'return',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'outbound': 'outbound',
    'return': 'return_',
  };

  @override
  final Iterable<Type> types = const <Type>[ServiceDayInputDirectionEnum];
  @override
  final String wireName = 'ServiceDayInputDirectionEnum';

  @override
  Object serialize(Serializers serializers, ServiceDayInputDirectionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ServiceDayInputDirectionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ServiceDayInputDirectionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ServiceDayInput extends ServiceDayInput {
  @override
  final Date travelDate;
  @override
  final ServiceDayInputDirectionEnum direction;
  @override
  final int limit;
  @override
  final String? routeId;

  factory _$ServiceDayInput([void Function(ServiceDayInputBuilder)? updates]) =>
      (ServiceDayInputBuilder()..update(updates))._build();

  _$ServiceDayInput._(
      {required this.travelDate,
      required this.direction,
      required this.limit,
      this.routeId})
      : super._();
  @override
  ServiceDayInput rebuild(void Function(ServiceDayInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ServiceDayInputBuilder toBuilder() => ServiceDayInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ServiceDayInput &&
        travelDate == other.travelDate &&
        direction == other.direction &&
        limit == other.limit &&
        routeId == other.routeId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, travelDate.hashCode);
    _$hash = $jc(_$hash, direction.hashCode);
    _$hash = $jc(_$hash, limit.hashCode);
    _$hash = $jc(_$hash, routeId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ServiceDayInput')
          ..add('travelDate', travelDate)
          ..add('direction', direction)
          ..add('limit', limit)
          ..add('routeId', routeId))
        .toString();
  }
}

class ServiceDayInputBuilder
    implements Builder<ServiceDayInput, ServiceDayInputBuilder> {
  _$ServiceDayInput? _$v;

  Date? _travelDate;
  Date? get travelDate => _$this._travelDate;
  set travelDate(Date? travelDate) => _$this._travelDate = travelDate;

  ServiceDayInputDirectionEnum? _direction;
  ServiceDayInputDirectionEnum? get direction => _$this._direction;
  set direction(ServiceDayInputDirectionEnum? direction) =>
      _$this._direction = direction;

  int? _limit;
  int? get limit => _$this._limit;
  set limit(int? limit) => _$this._limit = limit;

  String? _routeId;
  String? get routeId => _$this._routeId;
  set routeId(String? routeId) => _$this._routeId = routeId;

  ServiceDayInputBuilder() {
    ServiceDayInput._defaults(this);
  }

  ServiceDayInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _travelDate = $v.travelDate;
      _direction = $v.direction;
      _limit = $v.limit;
      _routeId = $v.routeId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ServiceDayInput other) {
    _$v = other as _$ServiceDayInput;
  }

  @override
  void update(void Function(ServiceDayInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ServiceDayInput build() => _build();

  _$ServiceDayInput _build() {
    final _$result = _$v ??
        _$ServiceDayInput._(
          travelDate: BuiltValueNullFieldError.checkNotNull(
              travelDate, r'ServiceDayInput', 'travelDate'),
          direction: BuiltValueNullFieldError.checkNotNull(
              direction, r'ServiceDayInput', 'direction'),
          limit: BuiltValueNullFieldError.checkNotNull(
              limit, r'ServiceDayInput', 'limit'),
          routeId: routeId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
