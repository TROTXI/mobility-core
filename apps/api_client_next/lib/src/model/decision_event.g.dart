// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'decision_event.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DecisionEvent extends DecisionEvent {
  @override
  final String id;
  @override
  final String action;
  @override
  final String? note;
  @override
  final DateTime occurredAt;

  factory _$DecisionEvent([void Function(DecisionEventBuilder)? updates]) =>
      (DecisionEventBuilder()..update(updates))._build();

  _$DecisionEvent._(
      {required this.id,
      required this.action,
      this.note,
      required this.occurredAt})
      : super._();
  @override
  DecisionEvent rebuild(void Function(DecisionEventBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DecisionEventBuilder toBuilder() => DecisionEventBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DecisionEvent &&
        id == other.id &&
        action == other.action &&
        note == other.note &&
        occurredAt == other.occurredAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, action.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, occurredAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DecisionEvent')
          ..add('id', id)
          ..add('action', action)
          ..add('note', note)
          ..add('occurredAt', occurredAt))
        .toString();
  }
}

class DecisionEventBuilder
    implements Builder<DecisionEvent, DecisionEventBuilder> {
  _$DecisionEvent? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _action;
  String? get action => _$this._action;
  set action(String? action) => _$this._action = action;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  DateTime? _occurredAt;
  DateTime? get occurredAt => _$this._occurredAt;
  set occurredAt(DateTime? occurredAt) => _$this._occurredAt = occurredAt;

  DecisionEventBuilder() {
    DecisionEvent._defaults(this);
  }

  DecisionEventBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _action = $v.action;
      _note = $v.note;
      _occurredAt = $v.occurredAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DecisionEvent other) {
    _$v = other as _$DecisionEvent;
  }

  @override
  void update(void Function(DecisionEventBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DecisionEvent build() => _build();

  _$DecisionEvent _build() {
    final _$result = _$v ??
        _$DecisionEvent._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'DecisionEvent', 'id'),
          action: BuiltValueNullFieldError.checkNotNull(
              action, r'DecisionEvent', 'action'),
          note: note,
          occurredAt: BuiltValueNullFieldError.checkNotNull(
              occurredAt, r'DecisionEvent', 'occurredAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
