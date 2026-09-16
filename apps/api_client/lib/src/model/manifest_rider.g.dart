// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manifest_rider.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ManifestRiderStatusEnum _$manifestRiderStatusEnum_pending =
    const ManifestRiderStatusEnum._('pending');
const ManifestRiderStatusEnum _$manifestRiderStatusEnum_reserved =
    const ManifestRiderStatusEnum._('reserved');
const ManifestRiderStatusEnum _$manifestRiderStatusEnum_declined =
    const ManifestRiderStatusEnum._('declined');
const ManifestRiderStatusEnum _$manifestRiderStatusEnum_unseated =
    const ManifestRiderStatusEnum._('unseated');
const ManifestRiderStatusEnum _$manifestRiderStatusEnum_boarded =
    const ManifestRiderStatusEnum._('boarded');
const ManifestRiderStatusEnum _$manifestRiderStatusEnum_noShow =
    const ManifestRiderStatusEnum._('noShow');
const ManifestRiderStatusEnum _$manifestRiderStatusEnum_operatorCancelled =
    const ManifestRiderStatusEnum._('operatorCancelled');

ManifestRiderStatusEnum _$manifestRiderStatusEnumValueOf(String name) {
  switch (name) {
    case 'pending':
      return _$manifestRiderStatusEnum_pending;
    case 'reserved':
      return _$manifestRiderStatusEnum_reserved;
    case 'declined':
      return _$manifestRiderStatusEnum_declined;
    case 'unseated':
      return _$manifestRiderStatusEnum_unseated;
    case 'boarded':
      return _$manifestRiderStatusEnum_boarded;
    case 'noShow':
      return _$manifestRiderStatusEnum_noShow;
    case 'operatorCancelled':
      return _$manifestRiderStatusEnum_operatorCancelled;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ManifestRiderStatusEnum> _$manifestRiderStatusEnumValues =
    BuiltSet<ManifestRiderStatusEnum>(const <ManifestRiderStatusEnum>[
  _$manifestRiderStatusEnum_pending,
  _$manifestRiderStatusEnum_reserved,
  _$manifestRiderStatusEnum_declined,
  _$manifestRiderStatusEnum_unseated,
  _$manifestRiderStatusEnum_boarded,
  _$manifestRiderStatusEnum_noShow,
  _$manifestRiderStatusEnum_operatorCancelled,
]);

Serializer<ManifestRiderStatusEnum> _$manifestRiderStatusEnumSerializer =
    _$ManifestRiderStatusEnumSerializer();

class _$ManifestRiderStatusEnumSerializer
    implements PrimitiveSerializer<ManifestRiderStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'pending': 'pending',
    'reserved': 'reserved',
    'declined': 'declined',
    'unseated': 'unseated',
    'boarded': 'boarded',
    'noShow': 'no_show',
    'operatorCancelled': 'operator_cancelled',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'pending': 'pending',
    'reserved': 'reserved',
    'declined': 'declined',
    'unseated': 'unseated',
    'boarded': 'boarded',
    'no_show': 'noShow',
    'operator_cancelled': 'operatorCancelled',
  };

  @override
  final Iterable<Type> types = const <Type>[ManifestRiderStatusEnum];
  @override
  final String wireName = 'ManifestRiderStatusEnum';

  @override
  Object serialize(Serializers serializers, ManifestRiderStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ManifestRiderStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ManifestRiderStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ManifestRider extends ManifestRider {
  @override
  final String reservationId;
  @override
  final String displayName;
  @override
  final String? avatarUrl;
  @override
  final ManifestRiderStatusEnum status;
  @override
  final String pickupOccurrenceId;
  @override
  final String dropoffOccurrenceId;

  factory _$ManifestRider([void Function(ManifestRiderBuilder)? updates]) =>
      (ManifestRiderBuilder()..update(updates))._build();

  _$ManifestRider._(
      {required this.reservationId,
      required this.displayName,
      this.avatarUrl,
      required this.status,
      required this.pickupOccurrenceId,
      required this.dropoffOccurrenceId})
      : super._();
  @override
  ManifestRider rebuild(void Function(ManifestRiderBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ManifestRiderBuilder toBuilder() => ManifestRiderBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ManifestRider &&
        reservationId == other.reservationId &&
        displayName == other.displayName &&
        avatarUrl == other.avatarUrl &&
        status == other.status &&
        pickupOccurrenceId == other.pickupOccurrenceId &&
        dropoffOccurrenceId == other.dropoffOccurrenceId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, reservationId.hashCode);
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jc(_$hash, avatarUrl.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, pickupOccurrenceId.hashCode);
    _$hash = $jc(_$hash, dropoffOccurrenceId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ManifestRider')
          ..add('reservationId', reservationId)
          ..add('displayName', displayName)
          ..add('avatarUrl', avatarUrl)
          ..add('status', status)
          ..add('pickupOccurrenceId', pickupOccurrenceId)
          ..add('dropoffOccurrenceId', dropoffOccurrenceId))
        .toString();
  }
}

class ManifestRiderBuilder
    implements Builder<ManifestRider, ManifestRiderBuilder> {
  _$ManifestRider? _$v;

  String? _reservationId;
  String? get reservationId => _$this._reservationId;
  set reservationId(String? reservationId) =>
      _$this._reservationId = reservationId;

  String? _displayName;
  String? get displayName => _$this._displayName;
  set displayName(String? displayName) => _$this._displayName = displayName;

  String? _avatarUrl;
  String? get avatarUrl => _$this._avatarUrl;
  set avatarUrl(String? avatarUrl) => _$this._avatarUrl = avatarUrl;

  ManifestRiderStatusEnum? _status;
  ManifestRiderStatusEnum? get status => _$this._status;
  set status(ManifestRiderStatusEnum? status) => _$this._status = status;

  String? _pickupOccurrenceId;
  String? get pickupOccurrenceId => _$this._pickupOccurrenceId;
  set pickupOccurrenceId(String? pickupOccurrenceId) =>
      _$this._pickupOccurrenceId = pickupOccurrenceId;

  String? _dropoffOccurrenceId;
  String? get dropoffOccurrenceId => _$this._dropoffOccurrenceId;
  set dropoffOccurrenceId(String? dropoffOccurrenceId) =>
      _$this._dropoffOccurrenceId = dropoffOccurrenceId;

  ManifestRiderBuilder() {
    ManifestRider._defaults(this);
  }

  ManifestRiderBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _reservationId = $v.reservationId;
      _displayName = $v.displayName;
      _avatarUrl = $v.avatarUrl;
      _status = $v.status;
      _pickupOccurrenceId = $v.pickupOccurrenceId;
      _dropoffOccurrenceId = $v.dropoffOccurrenceId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ManifestRider other) {
    _$v = other as _$ManifestRider;
  }

  @override
  void update(void Function(ManifestRiderBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ManifestRider build() => _build();

  _$ManifestRider _build() {
    final _$result = _$v ??
        _$ManifestRider._(
          reservationId: BuiltValueNullFieldError.checkNotNull(
              reservationId, r'ManifestRider', 'reservationId'),
          displayName: BuiltValueNullFieldError.checkNotNull(
              displayName, r'ManifestRider', 'displayName'),
          avatarUrl: avatarUrl,
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'ManifestRider', 'status'),
          pickupOccurrenceId: BuiltValueNullFieldError.checkNotNull(
              pickupOccurrenceId, r'ManifestRider', 'pickupOccurrenceId'),
          dropoffOccurrenceId: BuiltValueNullFieldError.checkNotNull(
              dropoffOccurrenceId, r'ManifestRider', 'dropoffOccurrenceId'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
