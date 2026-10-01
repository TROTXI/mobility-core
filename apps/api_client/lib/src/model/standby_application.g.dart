// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'standby_application.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const StandbyApplicationStateEnum _$standbyApplicationStateEnum_submitted =
    const StandbyApplicationStateEnum._('submitted');
const StandbyApplicationStateEnum _$standbyApplicationStateEnum_offered =
    const StandbyApplicationStateEnum._('offered');
const StandbyApplicationStateEnum _$standbyApplicationStateEnum_withdrawn =
    const StandbyApplicationStateEnum._('withdrawn');
const StandbyApplicationStateEnum _$standbyApplicationStateEnum_checkoutOpen =
    const StandbyApplicationStateEnum._('checkoutOpen');

StandbyApplicationStateEnum _$standbyApplicationStateEnumValueOf(String name) {
  switch (name) {
    case 'submitted':
      return _$standbyApplicationStateEnum_submitted;
    case 'offered':
      return _$standbyApplicationStateEnum_offered;
    case 'withdrawn':
      return _$standbyApplicationStateEnum_withdrawn;
    case 'checkoutOpen':
      return _$standbyApplicationStateEnum_checkoutOpen;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<StandbyApplicationStateEnum>
    _$standbyApplicationStateEnumValues =
    BuiltSet<StandbyApplicationStateEnum>(const <StandbyApplicationStateEnum>[
  _$standbyApplicationStateEnum_submitted,
  _$standbyApplicationStateEnum_offered,
  _$standbyApplicationStateEnum_withdrawn,
  _$standbyApplicationStateEnum_checkoutOpen,
]);

Serializer<StandbyApplicationStateEnum>
    _$standbyApplicationStateEnumSerializer =
    _$StandbyApplicationStateEnumSerializer();

class _$StandbyApplicationStateEnumSerializer
    implements PrimitiveSerializer<StandbyApplicationStateEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'submitted': 'submitted',
    'offered': 'offered',
    'withdrawn': 'withdrawn',
    'checkoutOpen': 'checkout_open',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'submitted': 'submitted',
    'offered': 'offered',
    'withdrawn': 'withdrawn',
    'checkout_open': 'checkoutOpen',
  };

  @override
  final Iterable<Type> types = const <Type>[StandbyApplicationStateEnum];
  @override
  final String wireName = 'StandbyApplicationStateEnum';

  @override
  Object serialize(Serializers serializers, StandbyApplicationStateEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  StandbyApplicationStateEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      StandbyApplicationStateEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$StandbyApplication extends StandbyApplication {
  @override
  final String id;
  @override
  final String riderId;
  @override
  final String riderName;
  @override
  final String routeName;
  @override
  final StandbyApplicationStateEnum state;
  @override
  final PurchaseInput selection;
  @override
  final StandbyApplicationOffer? offer;
  @override
  final DateTime createdAt;

  factory _$StandbyApplication(
          [void Function(StandbyApplicationBuilder)? updates]) =>
      (StandbyApplicationBuilder()..update(updates))._build();

  _$StandbyApplication._(
      {required this.id,
      required this.riderId,
      required this.riderName,
      required this.routeName,
      required this.state,
      required this.selection,
      this.offer,
      required this.createdAt})
      : super._();
  @override
  StandbyApplication rebuild(
          void Function(StandbyApplicationBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  StandbyApplicationBuilder toBuilder() =>
      StandbyApplicationBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is StandbyApplication &&
        id == other.id &&
        riderId == other.riderId &&
        riderName == other.riderName &&
        routeName == other.routeName &&
        state == other.state &&
        selection == other.selection &&
        offer == other.offer &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, riderId.hashCode);
    _$hash = $jc(_$hash, riderName.hashCode);
    _$hash = $jc(_$hash, routeName.hashCode);
    _$hash = $jc(_$hash, state.hashCode);
    _$hash = $jc(_$hash, selection.hashCode);
    _$hash = $jc(_$hash, offer.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'StandbyApplication')
          ..add('id', id)
          ..add('riderId', riderId)
          ..add('riderName', riderName)
          ..add('routeName', routeName)
          ..add('state', state)
          ..add('selection', selection)
          ..add('offer', offer)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class StandbyApplicationBuilder
    implements Builder<StandbyApplication, StandbyApplicationBuilder> {
  _$StandbyApplication? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _riderId;
  String? get riderId => _$this._riderId;
  set riderId(String? riderId) => _$this._riderId = riderId;

  String? _riderName;
  String? get riderName => _$this._riderName;
  set riderName(String? riderName) => _$this._riderName = riderName;

  String? _routeName;
  String? get routeName => _$this._routeName;
  set routeName(String? routeName) => _$this._routeName = routeName;

  StandbyApplicationStateEnum? _state;
  StandbyApplicationStateEnum? get state => _$this._state;
  set state(StandbyApplicationStateEnum? state) => _$this._state = state;

  PurchaseInputBuilder? _selection;
  PurchaseInputBuilder get selection =>
      _$this._selection ??= PurchaseInputBuilder();
  set selection(PurchaseInputBuilder? selection) =>
      _$this._selection = selection;

  StandbyApplicationOfferBuilder? _offer;
  StandbyApplicationOfferBuilder get offer =>
      _$this._offer ??= StandbyApplicationOfferBuilder();
  set offer(StandbyApplicationOfferBuilder? offer) => _$this._offer = offer;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  StandbyApplicationBuilder() {
    StandbyApplication._defaults(this);
  }

  StandbyApplicationBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _riderId = $v.riderId;
      _riderName = $v.riderName;
      _routeName = $v.routeName;
      _state = $v.state;
      _selection = $v.selection.toBuilder();
      _offer = $v.offer?.toBuilder();
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(StandbyApplication other) {
    _$v = other as _$StandbyApplication;
  }

  @override
  void update(void Function(StandbyApplicationBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  StandbyApplication build() => _build();

  _$StandbyApplication _build() {
    _$StandbyApplication _$result;
    try {
      _$result = _$v ??
          _$StandbyApplication._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'StandbyApplication', 'id'),
            riderId: BuiltValueNullFieldError.checkNotNull(
                riderId, r'StandbyApplication', 'riderId'),
            riderName: BuiltValueNullFieldError.checkNotNull(
                riderName, r'StandbyApplication', 'riderName'),
            routeName: BuiltValueNullFieldError.checkNotNull(
                routeName, r'StandbyApplication', 'routeName'),
            state: BuiltValueNullFieldError.checkNotNull(
                state, r'StandbyApplication', 'state'),
            selection: selection.build(),
            offer: _offer?.build(),
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'StandbyApplication', 'createdAt'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'selection';
        selection.build();
        _$failedField = 'offer';
        _offer?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'StandbyApplication', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
