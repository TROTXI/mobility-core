// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commute_decision_one_of5.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CommuteDecisionOneOf5ActionEnum _$commuteDecisionOneOf5ActionEnum_cancel =
    const CommuteDecisionOneOf5ActionEnum._('cancel');

CommuteDecisionOneOf5ActionEnum _$commuteDecisionOneOf5ActionEnumValueOf(
    String name) {
  switch (name) {
    case 'cancel':
      return _$commuteDecisionOneOf5ActionEnum_cancel;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CommuteDecisionOneOf5ActionEnum>
    _$commuteDecisionOneOf5ActionEnumValues = BuiltSet<
        CommuteDecisionOneOf5ActionEnum>(const <CommuteDecisionOneOf5ActionEnum>[
  _$commuteDecisionOneOf5ActionEnum_cancel,
]);

Serializer<CommuteDecisionOneOf5ActionEnum>
    _$commuteDecisionOneOf5ActionEnumSerializer =
    _$CommuteDecisionOneOf5ActionEnumSerializer();

class _$CommuteDecisionOneOf5ActionEnumSerializer
    implements PrimitiveSerializer<CommuteDecisionOneOf5ActionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'cancel': 'cancel',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'cancel': 'cancel',
  };

  @override
  final Iterable<Type> types = const <Type>[CommuteDecisionOneOf5ActionEnum];
  @override
  final String wireName = 'CommuteDecisionOneOf5ActionEnum';

  @override
  Object serialize(
          Serializers serializers, CommuteDecisionOneOf5ActionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CommuteDecisionOneOf5ActionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CommuteDecisionOneOf5ActionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$CommuteDecisionOneOf5 extends CommuteDecisionOneOf5 {
  @override
  final CommuteDecisionOneOf5ActionEnum action;
  @override
  final String note;

  factory _$CommuteDecisionOneOf5(
          [void Function(CommuteDecisionOneOf5Builder)? updates]) =>
      (CommuteDecisionOneOf5Builder()..update(updates))._build();

  _$CommuteDecisionOneOf5._({required this.action, required this.note})
      : super._();
  @override
  CommuteDecisionOneOf5 rebuild(
          void Function(CommuteDecisionOneOf5Builder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CommuteDecisionOneOf5Builder toBuilder() =>
      CommuteDecisionOneOf5Builder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CommuteDecisionOneOf5 &&
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
    return (newBuiltValueToStringHelper(r'CommuteDecisionOneOf5')
          ..add('action', action)
          ..add('note', note))
        .toString();
  }
}

class CommuteDecisionOneOf5Builder
    implements Builder<CommuteDecisionOneOf5, CommuteDecisionOneOf5Builder> {
  _$CommuteDecisionOneOf5? _$v;

  CommuteDecisionOneOf5ActionEnum? _action;
  CommuteDecisionOneOf5ActionEnum? get action => _$this._action;
  set action(CommuteDecisionOneOf5ActionEnum? action) =>
      _$this._action = action;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  CommuteDecisionOneOf5Builder() {
    CommuteDecisionOneOf5._defaults(this);
  }

  CommuteDecisionOneOf5Builder get _$this {
    final $v = _$v;
    if ($v != null) {
      _action = $v.action;
      _note = $v.note;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CommuteDecisionOneOf5 other) {
    _$v = other as _$CommuteDecisionOneOf5;
  }

  @override
  void update(void Function(CommuteDecisionOneOf5Builder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CommuteDecisionOneOf5 build() => _build();

  _$CommuteDecisionOneOf5 _build() {
    final _$result = _$v ??
        _$CommuteDecisionOneOf5._(
          action: BuiltValueNullFieldError.checkNotNull(
              action, r'CommuteDecisionOneOf5', 'action'),
          note: BuiltValueNullFieldError.checkNotNull(
              note, r'CommuteDecisionOneOf5', 'note'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
