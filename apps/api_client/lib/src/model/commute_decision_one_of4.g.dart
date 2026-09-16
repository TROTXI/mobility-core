// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commute_decision_one_of4.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CommuteDecisionOneOf4ActionEnum _$commuteDecisionOneOf4ActionEnum_apply =
    const CommuteDecisionOneOf4ActionEnum._('apply');

CommuteDecisionOneOf4ActionEnum _$commuteDecisionOneOf4ActionEnumValueOf(
    String name) {
  switch (name) {
    case 'apply':
      return _$commuteDecisionOneOf4ActionEnum_apply;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CommuteDecisionOneOf4ActionEnum>
    _$commuteDecisionOneOf4ActionEnumValues = BuiltSet<
        CommuteDecisionOneOf4ActionEnum>(const <CommuteDecisionOneOf4ActionEnum>[
  _$commuteDecisionOneOf4ActionEnum_apply,
]);

Serializer<CommuteDecisionOneOf4ActionEnum>
    _$commuteDecisionOneOf4ActionEnumSerializer =
    _$CommuteDecisionOneOf4ActionEnumSerializer();

class _$CommuteDecisionOneOf4ActionEnumSerializer
    implements PrimitiveSerializer<CommuteDecisionOneOf4ActionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'apply': 'apply',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'apply': 'apply',
  };

  @override
  final Iterable<Type> types = const <Type>[CommuteDecisionOneOf4ActionEnum];
  @override
  final String wireName = 'CommuteDecisionOneOf4ActionEnum';

  @override
  Object serialize(
          Serializers serializers, CommuteDecisionOneOf4ActionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CommuteDecisionOneOf4ActionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CommuteDecisionOneOf4ActionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$CommuteDecisionOneOf4 extends CommuteDecisionOneOf4 {
  @override
  final CommuteDecisionOneOf4ActionEnum action;
  @override
  final String note;

  factory _$CommuteDecisionOneOf4(
          [void Function(CommuteDecisionOneOf4Builder)? updates]) =>
      (CommuteDecisionOneOf4Builder()..update(updates))._build();

  _$CommuteDecisionOneOf4._({required this.action, required this.note})
      : super._();
  @override
  CommuteDecisionOneOf4 rebuild(
          void Function(CommuteDecisionOneOf4Builder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CommuteDecisionOneOf4Builder toBuilder() =>
      CommuteDecisionOneOf4Builder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CommuteDecisionOneOf4 &&
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
    return (newBuiltValueToStringHelper(r'CommuteDecisionOneOf4')
          ..add('action', action)
          ..add('note', note))
        .toString();
  }
}

class CommuteDecisionOneOf4Builder
    implements Builder<CommuteDecisionOneOf4, CommuteDecisionOneOf4Builder> {
  _$CommuteDecisionOneOf4? _$v;

  CommuteDecisionOneOf4ActionEnum? _action;
  CommuteDecisionOneOf4ActionEnum? get action => _$this._action;
  set action(CommuteDecisionOneOf4ActionEnum? action) =>
      _$this._action = action;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  CommuteDecisionOneOf4Builder() {
    CommuteDecisionOneOf4._defaults(this);
  }

  CommuteDecisionOneOf4Builder get _$this {
    final $v = _$v;
    if ($v != null) {
      _action = $v.action;
      _note = $v.note;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CommuteDecisionOneOf4 other) {
    _$v = other as _$CommuteDecisionOneOf4;
  }

  @override
  void update(void Function(CommuteDecisionOneOf4Builder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CommuteDecisionOneOf4 build() => _build();

  _$CommuteDecisionOneOf4 _build() {
    final _$result = _$v ??
        _$CommuteDecisionOneOf4._(
          action: BuiltValueNullFieldError.checkNotNull(
              action, r'CommuteDecisionOneOf4', 'action'),
          note: BuiltValueNullFieldError.checkNotNull(
              note, r'CommuteDecisionOneOf4', 'note'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
