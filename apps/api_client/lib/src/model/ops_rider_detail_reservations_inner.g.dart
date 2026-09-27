// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ops_rider_detail_reservations_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const OpsRiderDetailReservationsInnerDirectionEnum
    _$opsRiderDetailReservationsInnerDirectionEnum_outbound =
    const OpsRiderDetailReservationsInnerDirectionEnum._('outbound');
const OpsRiderDetailReservationsInnerDirectionEnum
    _$opsRiderDetailReservationsInnerDirectionEnum_return_ =
    const OpsRiderDetailReservationsInnerDirectionEnum._('return_');

OpsRiderDetailReservationsInnerDirectionEnum
    _$opsRiderDetailReservationsInnerDirectionEnumValueOf(String name) {
  switch (name) {
    case 'outbound':
      return _$opsRiderDetailReservationsInnerDirectionEnum_outbound;
    case 'return_':
      return _$opsRiderDetailReservationsInnerDirectionEnum_return_;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<OpsRiderDetailReservationsInnerDirectionEnum>
    _$opsRiderDetailReservationsInnerDirectionEnumValues = BuiltSet<
        OpsRiderDetailReservationsInnerDirectionEnum>(const <OpsRiderDetailReservationsInnerDirectionEnum>[
  _$opsRiderDetailReservationsInnerDirectionEnum_outbound,
  _$opsRiderDetailReservationsInnerDirectionEnum_return_,
]);

Serializer<OpsRiderDetailReservationsInnerDirectionEnum>
    _$opsRiderDetailReservationsInnerDirectionEnumSerializer =
    _$OpsRiderDetailReservationsInnerDirectionEnumSerializer();

class _$OpsRiderDetailReservationsInnerDirectionEnumSerializer
    implements
        PrimitiveSerializer<OpsRiderDetailReservationsInnerDirectionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'outbound': 'outbound',
    'return_': 'return',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'outbound': 'outbound',
    'return': 'return_',
  };

  @override
  final Iterable<Type> types = const <Type>[
    OpsRiderDetailReservationsInnerDirectionEnum
  ];
  @override
  final String wireName = 'OpsRiderDetailReservationsInnerDirectionEnum';

  @override
  Object serialize(Serializers serializers,
          OpsRiderDetailReservationsInnerDirectionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  OpsRiderDetailReservationsInnerDirectionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      OpsRiderDetailReservationsInnerDirectionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$OpsRiderDetailReservationsInner
    extends OpsRiderDetailReservationsInner {
  @override
  final String id;
  @override
  final Date serviceDate;
  @override
  final OpsRiderDetailReservationsInnerDirectionEnum direction;
  @override
  final String status;
  @override
  final String? routeName;
  @override
  final DateTime? scheduledAt;

  factory _$OpsRiderDetailReservationsInner(
          [void Function(OpsRiderDetailReservationsInnerBuilder)? updates]) =>
      (OpsRiderDetailReservationsInnerBuilder()..update(updates))._build();

  _$OpsRiderDetailReservationsInner._(
      {required this.id,
      required this.serviceDate,
      required this.direction,
      required this.status,
      this.routeName,
      this.scheduledAt})
      : super._();
  @override
  OpsRiderDetailReservationsInner rebuild(
          void Function(OpsRiderDetailReservationsInnerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OpsRiderDetailReservationsInnerBuilder toBuilder() =>
      OpsRiderDetailReservationsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OpsRiderDetailReservationsInner &&
        id == other.id &&
        serviceDate == other.serviceDate &&
        direction == other.direction &&
        status == other.status &&
        routeName == other.routeName &&
        scheduledAt == other.scheduledAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, serviceDate.hashCode);
    _$hash = $jc(_$hash, direction.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, routeName.hashCode);
    _$hash = $jc(_$hash, scheduledAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OpsRiderDetailReservationsInner')
          ..add('id', id)
          ..add('serviceDate', serviceDate)
          ..add('direction', direction)
          ..add('status', status)
          ..add('routeName', routeName)
          ..add('scheduledAt', scheduledAt))
        .toString();
  }
}

class OpsRiderDetailReservationsInnerBuilder
    implements
        Builder<OpsRiderDetailReservationsInner,
            OpsRiderDetailReservationsInnerBuilder> {
  _$OpsRiderDetailReservationsInner? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  Date? _serviceDate;
  Date? get serviceDate => _$this._serviceDate;
  set serviceDate(Date? serviceDate) => _$this._serviceDate = serviceDate;

  OpsRiderDetailReservationsInnerDirectionEnum? _direction;
  OpsRiderDetailReservationsInnerDirectionEnum? get direction =>
      _$this._direction;
  set direction(OpsRiderDetailReservationsInnerDirectionEnum? direction) =>
      _$this._direction = direction;

  String? _status;
  String? get status => _$this._status;
  set status(String? status) => _$this._status = status;

  String? _routeName;
  String? get routeName => _$this._routeName;
  set routeName(String? routeName) => _$this._routeName = routeName;

  DateTime? _scheduledAt;
  DateTime? get scheduledAt => _$this._scheduledAt;
  set scheduledAt(DateTime? scheduledAt) => _$this._scheduledAt = scheduledAt;

  OpsRiderDetailReservationsInnerBuilder() {
    OpsRiderDetailReservationsInner._defaults(this);
  }

  OpsRiderDetailReservationsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _serviceDate = $v.serviceDate;
      _direction = $v.direction;
      _status = $v.status;
      _routeName = $v.routeName;
      _scheduledAt = $v.scheduledAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OpsRiderDetailReservationsInner other) {
    _$v = other as _$OpsRiderDetailReservationsInner;
  }

  @override
  void update(void Function(OpsRiderDetailReservationsInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OpsRiderDetailReservationsInner build() => _build();

  _$OpsRiderDetailReservationsInner _build() {
    final _$result = _$v ??
        _$OpsRiderDetailReservationsInner._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'OpsRiderDetailReservationsInner', 'id'),
          serviceDate: BuiltValueNullFieldError.checkNotNull(
              serviceDate, r'OpsRiderDetailReservationsInner', 'serviceDate'),
          direction: BuiltValueNullFieldError.checkNotNull(
              direction, r'OpsRiderDetailReservationsInner', 'direction'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'OpsRiderDetailReservationsInner', 'status'),
          routeName: routeName,
          scheduledAt: scheduledAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
