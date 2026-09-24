// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commute_decision_one_of6.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CommuteDecisionOneOf6ActionEnum _$commuteDecisionOneOf6ActionEnum_reject =
    const CommuteDecisionOneOf6ActionEnum._('reject');

CommuteDecisionOneOf6ActionEnum _$commuteDecisionOneOf6ActionEnumValueOf(
    String name) {
  switch (name) {
    case 'reject':
      return _$commuteDecisionOneOf6ActionEnum_reject;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CommuteDecisionOneOf6ActionEnum>
    _$commuteDecisionOneOf6ActionEnumValues = BuiltSet<
        CommuteDecisionOneOf6ActionEnum>(const <CommuteDecisionOneOf6ActionEnum>[
  _$commuteDecisionOneOf6ActionEnum_reject,
]);

Serializer<CommuteDecisionOneOf6ActionEnum>
    _$commuteDecisionOneOf6ActionEnumSerializer =
    _$CommuteDecisionOneOf6ActionEnumSerializer();

class _$CommuteDecisionOneOf6ActionEnumSerializer
    implements PrimitiveSerializer<CommuteDecisionOneOf6ActionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'reject': 'reject',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'reject': 'reject',
  };

  @override
  final Iterable<Type> types = const <Type>[CommuteDecisionOneOf6ActionEnum];
  @override
  final String wireName = 'CommuteDecisionOneOf6ActionEnum';

  @override
  Object serialize(
          Serializers serializers, CommuteDecisionOneOf6ActionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CommuteDecisionOneOf6ActionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CommuteDecisionOneOf6ActionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$CommuteDecisionOneOf6 extends CommuteDecisionOneOf6 {
  @override
  final CommuteDecisionOneOf6ActionEnum action;
  @override
  final String note;

  factory _$CommuteDecisionOneOf6(
          [void Function(CommuteDecisionOneOf6Builder)? updates]) =>
      (CommuteDecisionOneOf6Builder()..update(updates))._build();

  _$CommuteDecisionOneOf6._({required this.action, required this.note})
      : super._();
  @override
  CommuteDecisionOneOf6 rebuild(
          void Function(CommuteDecisionOneOf6Builder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CommuteDecisionOneOf6Builder toBuilder() =>
      CommuteDecisionOneOf6Builder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CommuteDecisionOneOf6 &&
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
    return (newBuiltValueToStringHelper(r'CommuteDecisionOneOf6')
          ..add('action', action)
          ..add('note', note))
        .toString();
  }
}

class CommuteDecisionOneOf6Builder
    implements Builder<CommuteDecisionOneOf6, CommuteDecisionOneOf6Builder> {
  _$CommuteDecisionOneOf6? _$v;

  CommuteDecisionOneOf6ActionEnum? _action;
  CommuteDecisionOneOf6ActionEnum? get action => _$this._action;
  set action(CommuteDecisionOneOf6ActionEnum? action) =>
      _$this._action = action;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  CommuteDecisionOneOf6Builder() {
    CommuteDecisionOneOf6._defaults(this);
  }

  CommuteDecisionOneOf6Builder get _$this {
    final $v = _$v;
    if ($v != null) {
      _action = $v.action;
      _note = $v.note;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CommuteDecisionOneOf6 other) {
    _$v = other as _$CommuteDecisionOneOf6;
  }

  @override
  void update(void Function(CommuteDecisionOneOf6Builder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CommuteDecisionOneOf6 build() => _build();

  _$CommuteDecisionOneOf6 _build() {
    final _$result = _$v ??
        _$CommuteDecisionOneOf6._(
          action: BuiltValueNullFieldError.checkNotNull(
              action, r'CommuteDecisionOneOf6', 'action'),
          note: BuiltValueNullFieldError.checkNotNull(
              note, r'CommuteDecisionOneOf6', 'note'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
