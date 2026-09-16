// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_decision.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const WorkDecisionStatusEnum _$workDecisionStatusEnum_approved =
    const WorkDecisionStatusEnum._('approved');
const WorkDecisionStatusEnum _$workDecisionStatusEnum_declined =
    const WorkDecisionStatusEnum._('declined');

WorkDecisionStatusEnum _$workDecisionStatusEnumValueOf(String name) {
  switch (name) {
    case 'approved':
      return _$workDecisionStatusEnum_approved;
    case 'declined':
      return _$workDecisionStatusEnum_declined;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<WorkDecisionStatusEnum> _$workDecisionStatusEnumValues =
    BuiltSet<WorkDecisionStatusEnum>(const <WorkDecisionStatusEnum>[
  _$workDecisionStatusEnum_approved,
  _$workDecisionStatusEnum_declined,
]);

Serializer<WorkDecisionStatusEnum> _$workDecisionStatusEnumSerializer =
    _$WorkDecisionStatusEnumSerializer();

class _$WorkDecisionStatusEnumSerializer
    implements PrimitiveSerializer<WorkDecisionStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'approved': 'approved',
    'declined': 'declined',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'approved': 'approved',
    'declined': 'declined',
  };

  @override
  final Iterable<Type> types = const <Type>[WorkDecisionStatusEnum];
  @override
  final String wireName = 'WorkDecisionStatusEnum';

  @override
  Object serialize(Serializers serializers, WorkDecisionStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  WorkDecisionStatusEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      WorkDecisionStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$WorkDecision extends WorkDecision {
  @override
  final WorkDecisionStatusEnum status;
  @override
  final String decisionNote;

  factory _$WorkDecision([void Function(WorkDecisionBuilder)? updates]) =>
      (WorkDecisionBuilder()..update(updates))._build();

  _$WorkDecision._({required this.status, required this.decisionNote})
      : super._();
  @override
  WorkDecision rebuild(void Function(WorkDecisionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  WorkDecisionBuilder toBuilder() => WorkDecisionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WorkDecision &&
        status == other.status &&
        decisionNote == other.decisionNote;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, decisionNote.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'WorkDecision')
          ..add('status', status)
          ..add('decisionNote', decisionNote))
        .toString();
  }
}

class WorkDecisionBuilder
    implements Builder<WorkDecision, WorkDecisionBuilder> {
  _$WorkDecision? _$v;

  WorkDecisionStatusEnum? _status;
  WorkDecisionStatusEnum? get status => _$this._status;
  set status(WorkDecisionStatusEnum? status) => _$this._status = status;

  String? _decisionNote;
  String? get decisionNote => _$this._decisionNote;
  set decisionNote(String? decisionNote) => _$this._decisionNote = decisionNote;

  WorkDecisionBuilder() {
    WorkDecision._defaults(this);
  }

  WorkDecisionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _status = $v.status;
      _decisionNote = $v.decisionNote;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WorkDecision other) {
    _$v = other as _$WorkDecision;
  }

  @override
  void update(void Function(WorkDecisionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WorkDecision build() => _build();

  _$WorkDecision _build() {
    final _$result = _$v ??
        _$WorkDecision._(
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'WorkDecision', 'status'),
          decisionNote: BuiltValueNullFieldError.checkNotNull(
              decisionNote, r'WorkDecision', 'decisionNote'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
