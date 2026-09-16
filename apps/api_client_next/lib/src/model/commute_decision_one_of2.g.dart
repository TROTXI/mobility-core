// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commute_decision_one_of2.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CommuteDecisionOneOf2ActionEnum _$commuteDecisionOneOf2ActionEnum_pause =
    const CommuteDecisionOneOf2ActionEnum._('pause');

CommuteDecisionOneOf2ActionEnum _$commuteDecisionOneOf2ActionEnumValueOf(
    String name) {
  switch (name) {
    case 'pause':
      return _$commuteDecisionOneOf2ActionEnum_pause;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CommuteDecisionOneOf2ActionEnum>
    _$commuteDecisionOneOf2ActionEnumValues = BuiltSet<
        CommuteDecisionOneOf2ActionEnum>(const <CommuteDecisionOneOf2ActionEnum>[
  _$commuteDecisionOneOf2ActionEnum_pause,
]);

Serializer<CommuteDecisionOneOf2ActionEnum>
    _$commuteDecisionOneOf2ActionEnumSerializer =
    _$CommuteDecisionOneOf2ActionEnumSerializer();

class _$CommuteDecisionOneOf2ActionEnumSerializer
    implements PrimitiveSerializer<CommuteDecisionOneOf2ActionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'pause': 'pause',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'pause': 'pause',
  };

  @override
  final Iterable<Type> types = const <Type>[CommuteDecisionOneOf2ActionEnum];
  @override
  final String wireName = 'CommuteDecisionOneOf2ActionEnum';

  @override
  Object serialize(
          Serializers serializers, CommuteDecisionOneOf2ActionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CommuteDecisionOneOf2ActionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CommuteDecisionOneOf2ActionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$CommuteDecisionOneOf2 extends CommuteDecisionOneOf2 {
  @override
  final CommuteDecisionOneOf2ActionEnum action;
  @override
  final String note;

  factory _$CommuteDecisionOneOf2(
          [void Function(CommuteDecisionOneOf2Builder)? updates]) =>
      (CommuteDecisionOneOf2Builder()..update(updates))._build();

  _$CommuteDecisionOneOf2._({required this.action, required this.note})
      : super._();
  @override
  CommuteDecisionOneOf2 rebuild(
          void Function(CommuteDecisionOneOf2Builder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CommuteDecisionOneOf2Builder toBuilder() =>
      CommuteDecisionOneOf2Builder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CommuteDecisionOneOf2 &&
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
    return (newBuiltValueToStringHelper(r'CommuteDecisionOneOf2')
          ..add('action', action)
          ..add('note', note))
        .toString();
  }
}

class CommuteDecisionOneOf2Builder
    implements Builder<CommuteDecisionOneOf2, CommuteDecisionOneOf2Builder> {
  _$CommuteDecisionOneOf2? _$v;

  CommuteDecisionOneOf2ActionEnum? _action;
  CommuteDecisionOneOf2ActionEnum? get action => _$this._action;
  set action(CommuteDecisionOneOf2ActionEnum? action) =>
      _$this._action = action;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  CommuteDecisionOneOf2Builder() {
    CommuteDecisionOneOf2._defaults(this);
  }

  CommuteDecisionOneOf2Builder get _$this {
    final $v = _$v;
    if ($v != null) {
      _action = $v.action;
      _note = $v.note;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CommuteDecisionOneOf2 other) {
    _$v = other as _$CommuteDecisionOneOf2;
  }

  @override
  void update(void Function(CommuteDecisionOneOf2Builder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CommuteDecisionOneOf2 build() => _build();

  _$CommuteDecisionOneOf2 _build() {
    final _$result = _$v ??
        _$CommuteDecisionOneOf2._(
          action: BuiltValueNullFieldError.checkNotNull(
              action, r'CommuteDecisionOneOf2', 'action'),
          note: BuiltValueNullFieldError.checkNotNull(
              note, r'CommuteDecisionOneOf2', 'note'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
