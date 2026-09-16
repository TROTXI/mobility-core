// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commute_decision_one_of3.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CommuteDecisionOneOf3ActionEnum _$commuteDecisionOneOf3ActionEnum_resume =
    const CommuteDecisionOneOf3ActionEnum._('resume');

CommuteDecisionOneOf3ActionEnum _$commuteDecisionOneOf3ActionEnumValueOf(
    String name) {
  switch (name) {
    case 'resume':
      return _$commuteDecisionOneOf3ActionEnum_resume;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CommuteDecisionOneOf3ActionEnum>
    _$commuteDecisionOneOf3ActionEnumValues = BuiltSet<
        CommuteDecisionOneOf3ActionEnum>(const <CommuteDecisionOneOf3ActionEnum>[
  _$commuteDecisionOneOf3ActionEnum_resume,
]);

Serializer<CommuteDecisionOneOf3ActionEnum>
    _$commuteDecisionOneOf3ActionEnumSerializer =
    _$CommuteDecisionOneOf3ActionEnumSerializer();

class _$CommuteDecisionOneOf3ActionEnumSerializer
    implements PrimitiveSerializer<CommuteDecisionOneOf3ActionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'resume': 'resume',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'resume': 'resume',
  };

  @override
  final Iterable<Type> types = const <Type>[CommuteDecisionOneOf3ActionEnum];
  @override
  final String wireName = 'CommuteDecisionOneOf3ActionEnum';

  @override
  Object serialize(
          Serializers serializers, CommuteDecisionOneOf3ActionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CommuteDecisionOneOf3ActionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CommuteDecisionOneOf3ActionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$CommuteDecisionOneOf3 extends CommuteDecisionOneOf3 {
  @override
  final CommuteDecisionOneOf3ActionEnum action;
  @override
  final String note;

  factory _$CommuteDecisionOneOf3(
          [void Function(CommuteDecisionOneOf3Builder)? updates]) =>
      (CommuteDecisionOneOf3Builder()..update(updates))._build();

  _$CommuteDecisionOneOf3._({required this.action, required this.note})
      : super._();
  @override
  CommuteDecisionOneOf3 rebuild(
          void Function(CommuteDecisionOneOf3Builder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CommuteDecisionOneOf3Builder toBuilder() =>
      CommuteDecisionOneOf3Builder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CommuteDecisionOneOf3 &&
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
    return (newBuiltValueToStringHelper(r'CommuteDecisionOneOf3')
          ..add('action', action)
          ..add('note', note))
        .toString();
  }
}

class CommuteDecisionOneOf3Builder
    implements Builder<CommuteDecisionOneOf3, CommuteDecisionOneOf3Builder> {
  _$CommuteDecisionOneOf3? _$v;

  CommuteDecisionOneOf3ActionEnum? _action;
  CommuteDecisionOneOf3ActionEnum? get action => _$this._action;
  set action(CommuteDecisionOneOf3ActionEnum? action) =>
      _$this._action = action;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  CommuteDecisionOneOf3Builder() {
    CommuteDecisionOneOf3._defaults(this);
  }

  CommuteDecisionOneOf3Builder get _$this {
    final $v = _$v;
    if ($v != null) {
      _action = $v.action;
      _note = $v.note;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CommuteDecisionOneOf3 other) {
    _$v = other as _$CommuteDecisionOneOf3;
  }

  @override
  void update(void Function(CommuteDecisionOneOf3Builder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CommuteDecisionOneOf3 build() => _build();

  _$CommuteDecisionOneOf3 _build() {
    final _$result = _$v ??
        _$CommuteDecisionOneOf3._(
          action: BuiltValueNullFieldError.checkNotNull(
              action, r'CommuteDecisionOneOf3', 'action'),
          note: BuiltValueNullFieldError.checkNotNull(
              note, r'CommuteDecisionOneOf3', 'note'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
