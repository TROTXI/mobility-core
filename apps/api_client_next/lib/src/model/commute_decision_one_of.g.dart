// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commute_decision_one_of.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CommuteDecisionOneOfActionEnum _$commuteDecisionOneOfActionEnum_approve =
    const CommuteDecisionOneOfActionEnum._('approve');

CommuteDecisionOneOfActionEnum _$commuteDecisionOneOfActionEnumValueOf(
    String name) {
  switch (name) {
    case 'approve':
      return _$commuteDecisionOneOfActionEnum_approve;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CommuteDecisionOneOfActionEnum>
    _$commuteDecisionOneOfActionEnumValues = BuiltSet<
        CommuteDecisionOneOfActionEnum>(const <CommuteDecisionOneOfActionEnum>[
  _$commuteDecisionOneOfActionEnum_approve,
]);

Serializer<CommuteDecisionOneOfActionEnum>
    _$commuteDecisionOneOfActionEnumSerializer =
    _$CommuteDecisionOneOfActionEnumSerializer();

class _$CommuteDecisionOneOfActionEnumSerializer
    implements PrimitiveSerializer<CommuteDecisionOneOfActionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'approve': 'approve',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'approve': 'approve',
  };

  @override
  final Iterable<Type> types = const <Type>[CommuteDecisionOneOfActionEnum];
  @override
  final String wireName = 'CommuteDecisionOneOfActionEnum';

  @override
  Object serialize(
          Serializers serializers, CommuteDecisionOneOfActionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CommuteDecisionOneOfActionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CommuteDecisionOneOfActionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$CommuteDecisionOneOf extends CommuteDecisionOneOf {
  @override
  final CommuteDecisionOneOfActionEnum action;
  @override
  final String slotId;
  @override
  final Date effectiveDate;
  @override
  final String note;

  factory _$CommuteDecisionOneOf(
          [void Function(CommuteDecisionOneOfBuilder)? updates]) =>
      (CommuteDecisionOneOfBuilder()..update(updates))._build();

  _$CommuteDecisionOneOf._(
      {required this.action,
      required this.slotId,
      required this.effectiveDate,
      required this.note})
      : super._();
  @override
  CommuteDecisionOneOf rebuild(
          void Function(CommuteDecisionOneOfBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CommuteDecisionOneOfBuilder toBuilder() =>
      CommuteDecisionOneOfBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CommuteDecisionOneOf &&
        action == other.action &&
        slotId == other.slotId &&
        effectiveDate == other.effectiveDate &&
        note == other.note;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, action.hashCode);
    _$hash = $jc(_$hash, slotId.hashCode);
    _$hash = $jc(_$hash, effectiveDate.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CommuteDecisionOneOf')
          ..add('action', action)
          ..add('slotId', slotId)
          ..add('effectiveDate', effectiveDate)
          ..add('note', note))
        .toString();
  }
}

class CommuteDecisionOneOfBuilder
    implements Builder<CommuteDecisionOneOf, CommuteDecisionOneOfBuilder> {
  _$CommuteDecisionOneOf? _$v;

  CommuteDecisionOneOfActionEnum? _action;
  CommuteDecisionOneOfActionEnum? get action => _$this._action;
  set action(CommuteDecisionOneOfActionEnum? action) => _$this._action = action;

  String? _slotId;
  String? get slotId => _$this._slotId;
  set slotId(String? slotId) => _$this._slotId = slotId;

  Date? _effectiveDate;
  Date? get effectiveDate => _$this._effectiveDate;
  set effectiveDate(Date? effectiveDate) =>
      _$this._effectiveDate = effectiveDate;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  CommuteDecisionOneOfBuilder() {
    CommuteDecisionOneOf._defaults(this);
  }

  CommuteDecisionOneOfBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _action = $v.action;
      _slotId = $v.slotId;
      _effectiveDate = $v.effectiveDate;
      _note = $v.note;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CommuteDecisionOneOf other) {
    _$v = other as _$CommuteDecisionOneOf;
  }

  @override
  void update(void Function(CommuteDecisionOneOfBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CommuteDecisionOneOf build() => _build();

  _$CommuteDecisionOneOf _build() {
    final _$result = _$v ??
        _$CommuteDecisionOneOf._(
          action: BuiltValueNullFieldError.checkNotNull(
              action, r'CommuteDecisionOneOf', 'action'),
          slotId: BuiltValueNullFieldError.checkNotNull(
              slotId, r'CommuteDecisionOneOf', 'slotId'),
          effectiveDate: BuiltValueNullFieldError.checkNotNull(
              effectiveDate, r'CommuteDecisionOneOf', 'effectiveDate'),
          note: BuiltValueNullFieldError.checkNotNull(
              note, r'CommuteDecisionOneOf', 'note'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
