// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'standby_application_offer.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const StandbyApplicationOfferStateEnum
    _$standbyApplicationOfferStateEnum_offered =
    const StandbyApplicationOfferStateEnum._('offered');
const StandbyApplicationOfferStateEnum
    _$standbyApplicationOfferStateEnum_accepting =
    const StandbyApplicationOfferStateEnum._('accepting');
const StandbyApplicationOfferStateEnum
    _$standbyApplicationOfferStateEnum_checkoutOpen =
    const StandbyApplicationOfferStateEnum._('checkoutOpen');
const StandbyApplicationOfferStateEnum
    _$standbyApplicationOfferStateEnum_cancelled =
    const StandbyApplicationOfferStateEnum._('cancelled');

StandbyApplicationOfferStateEnum _$standbyApplicationOfferStateEnumValueOf(
    String name) {
  switch (name) {
    case 'offered':
      return _$standbyApplicationOfferStateEnum_offered;
    case 'accepting':
      return _$standbyApplicationOfferStateEnum_accepting;
    case 'checkoutOpen':
      return _$standbyApplicationOfferStateEnum_checkoutOpen;
    case 'cancelled':
      return _$standbyApplicationOfferStateEnum_cancelled;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<StandbyApplicationOfferStateEnum>
    _$standbyApplicationOfferStateEnumValues = BuiltSet<
        StandbyApplicationOfferStateEnum>(const <StandbyApplicationOfferStateEnum>[
  _$standbyApplicationOfferStateEnum_offered,
  _$standbyApplicationOfferStateEnum_accepting,
  _$standbyApplicationOfferStateEnum_checkoutOpen,
  _$standbyApplicationOfferStateEnum_cancelled,
]);

Serializer<StandbyApplicationOfferStateEnum>
    _$standbyApplicationOfferStateEnumSerializer =
    _$StandbyApplicationOfferStateEnumSerializer();

class _$StandbyApplicationOfferStateEnumSerializer
    implements PrimitiveSerializer<StandbyApplicationOfferStateEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'offered': 'offered',
    'accepting': 'accepting',
    'checkoutOpen': 'checkout_open',
    'cancelled': 'cancelled',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'offered': 'offered',
    'accepting': 'accepting',
    'checkout_open': 'checkoutOpen',
    'cancelled': 'cancelled',
  };

  @override
  final Iterable<Type> types = const <Type>[StandbyApplicationOfferStateEnum];
  @override
  final String wireName = 'StandbyApplicationOfferStateEnum';

  @override
  Object serialize(
          Serializers serializers, StandbyApplicationOfferStateEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  StandbyApplicationOfferStateEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      StandbyApplicationOfferStateEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$StandbyApplicationOffer extends StandbyApplicationOffer {
  @override
  final String id;
  @override
  final StandbyApplicationOfferStateEnum state;
  @override
  final DateTime expiresAt;
  @override
  final String? purchaseId;

  factory _$StandbyApplicationOffer(
          [void Function(StandbyApplicationOfferBuilder)? updates]) =>
      (StandbyApplicationOfferBuilder()..update(updates))._build();

  _$StandbyApplicationOffer._(
      {required this.id,
      required this.state,
      required this.expiresAt,
      this.purchaseId})
      : super._();
  @override
  StandbyApplicationOffer rebuild(
          void Function(StandbyApplicationOfferBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  StandbyApplicationOfferBuilder toBuilder() =>
      StandbyApplicationOfferBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is StandbyApplicationOffer &&
        id == other.id &&
        state == other.state &&
        expiresAt == other.expiresAt &&
        purchaseId == other.purchaseId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, state.hashCode);
    _$hash = $jc(_$hash, expiresAt.hashCode);
    _$hash = $jc(_$hash, purchaseId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'StandbyApplicationOffer')
          ..add('id', id)
          ..add('state', state)
          ..add('expiresAt', expiresAt)
          ..add('purchaseId', purchaseId))
        .toString();
  }
}

class StandbyApplicationOfferBuilder
    implements
        Builder<StandbyApplicationOffer, StandbyApplicationOfferBuilder> {
  _$StandbyApplicationOffer? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  StandbyApplicationOfferStateEnum? _state;
  StandbyApplicationOfferStateEnum? get state => _$this._state;
  set state(StandbyApplicationOfferStateEnum? state) => _$this._state = state;

  DateTime? _expiresAt;
  DateTime? get expiresAt => _$this._expiresAt;
  set expiresAt(DateTime? expiresAt) => _$this._expiresAt = expiresAt;

  String? _purchaseId;
  String? get purchaseId => _$this._purchaseId;
  set purchaseId(String? purchaseId) => _$this._purchaseId = purchaseId;

  StandbyApplicationOfferBuilder() {
    StandbyApplicationOffer._defaults(this);
  }

  StandbyApplicationOfferBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _state = $v.state;
      _expiresAt = $v.expiresAt;
      _purchaseId = $v.purchaseId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(StandbyApplicationOffer other) {
    _$v = other as _$StandbyApplicationOffer;
  }

  @override
  void update(void Function(StandbyApplicationOfferBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  StandbyApplicationOffer build() => _build();

  _$StandbyApplicationOffer _build() {
    final _$result = _$v ??
        _$StandbyApplicationOffer._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'StandbyApplicationOffer', 'id'),
          state: BuiltValueNullFieldError.checkNotNull(
              state, r'StandbyApplicationOffer', 'state'),
          expiresAt: BuiltValueNullFieldError.checkNotNull(
              expiresAt, r'StandbyApplicationOffer', 'expiresAt'),
          purchaseId: purchaseId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
