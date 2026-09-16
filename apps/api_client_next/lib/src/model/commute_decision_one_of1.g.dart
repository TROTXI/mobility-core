// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commute_decision_one_of1.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CommuteDecisionOneOf1ActionEnum
    _$commuteDecisionOneOf1ActionEnum_waitlist =
    const CommuteDecisionOneOf1ActionEnum._('waitlist');

CommuteDecisionOneOf1ActionEnum _$commuteDecisionOneOf1ActionEnumValueOf(
    String name) {
  switch (name) {
    case 'waitlist':
      return _$commuteDecisionOneOf1ActionEnum_waitlist;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CommuteDecisionOneOf1ActionEnum>
    _$commuteDecisionOneOf1ActionEnumValues = BuiltSet<
        CommuteDecisionOneOf1ActionEnum>(const <CommuteDecisionOneOf1ActionEnum>[
  _$commuteDecisionOneOf1ActionEnum_waitlist,
]);

Serializer<CommuteDecisionOneOf1ActionEnum>
    _$commuteDecisionOneOf1ActionEnumSerializer =
    _$CommuteDecisionOneOf1ActionEnumSerializer();

class _$CommuteDecisionOneOf1ActionEnumSerializer
    implements PrimitiveSerializer<CommuteDecisionOneOf1ActionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'waitlist': 'waitlist',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'waitlist': 'waitlist',
  };

  @override
  final Iterable<Type> types = const <Type>[CommuteDecisionOneOf1ActionEnum];
  @override
  final String wireName = 'CommuteDecisionOneOf1ActionEnum';

  @override
  Object serialize(
          Serializers serializers, CommuteDecisionOneOf1ActionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CommuteDecisionOneOf1ActionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CommuteDecisionOneOf1ActionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$CommuteDecisionOneOf1 extends CommuteDecisionOneOf1 {
  @override
  final CommuteDecisionOneOf1ActionEnum action;
  @override
  final String note;

  factory _$CommuteDecisionOneOf1(
          [void Function(CommuteDecisionOneOf1Builder)? updates]) =>
      (CommuteDecisionOneOf1Builder()..update(updates))._build();

  _$CommuteDecisionOneOf1._({required this.action, required this.note})
      : super._();
  @override
  CommuteDecisionOneOf1 rebuild(
          void Function(CommuteDecisionOneOf1Builder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CommuteDecisionOneOf1Builder toBuilder() =>
      CommuteDecisionOneOf1Builder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CommuteDecisionOneOf1 &&
        action == other.action &&
        note == other.note;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, action.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CommuteDecisionOneOf1')
          ..add('action', action)
          ..add('note', note))
        .toString();
  }
}

class CommuteDecisionOneOf1Builder
    implements Builder<CommuteDecisionOneOf1, CommuteDecisionOneOf1Builder> {
  _$CommuteDecisionOneOf1? _$v;

  CommuteDecisionOneOf1ActionEnum? _action;
  CommuteDecisionOneOf1ActionEnum? get action => _$this._action;
  set action(CommuteDecisionOneOf1ActionEnum? action) =>
      _$this._action = action;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  CommuteDecisionOneOf1Builder() {
    CommuteDecisionOneOf1._defaults(this);
  }

  CommuteDecisionOneOf1Builder get _$this {
    final $v = _$v;
    if ($v != null) {
      _action = $v.action;
      _note = $v.note;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CommuteDecisionOneOf1 other) {
    _$v = other as _$CommuteDecisionOneOf1;
  }

  @override
  void update(void Function(CommuteDecisionOneOf1Builder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CommuteDecisionOneOf1 build() => _build();

  _$CommuteDecisionOneOf1 _build() {
    final _$result = _$v ??
        _$CommuteDecisionOneOf1._(
          action: BuiltValueNullFieldError.checkNotNull(
              action, r'CommuteDecisionOneOf1', 'action'),
          note: BuiltValueNullFieldError.checkNotNull(
              note, r'CommuteDecisionOneOf1', 'note'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
