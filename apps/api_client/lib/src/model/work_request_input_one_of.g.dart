// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_request_input_one_of.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const WorkRequestInputOneOfKindEnum
    _$workRequestInputOneOfKindEnum_routeChange =
    const WorkRequestInputOneOfKindEnum._('routeChange');

WorkRequestInputOneOfKindEnum _$workRequestInputOneOfKindEnumValueOf(
    String name) {
  switch (name) {
    case 'routeChange':
      return _$workRequestInputOneOfKindEnum_routeChange;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<WorkRequestInputOneOfKindEnum>
    _$workRequestInputOneOfKindEnumValues = BuiltSet<
        WorkRequestInputOneOfKindEnum>(const <WorkRequestInputOneOfKindEnum>[
  _$workRequestInputOneOfKindEnum_routeChange,
]);

Serializer<WorkRequestInputOneOfKindEnum>
    _$workRequestInputOneOfKindEnumSerializer =
    _$WorkRequestInputOneOfKindEnumSerializer();

class _$WorkRequestInputOneOfKindEnumSerializer
    implements PrimitiveSerializer<WorkRequestInputOneOfKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'routeChange': 'route_change',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'route_change': 'routeChange',
  };

  @override
  final Iterable<Type> types = const <Type>[WorkRequestInputOneOfKindEnum];
  @override
  final String wireName = 'WorkRequestInputOneOfKindEnum';

  @override
  Object serialize(
          Serializers serializers, WorkRequestInputOneOfKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  WorkRequestInputOneOfKindEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      WorkRequestInputOneOfKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$WorkRequestInputOneOf extends WorkRequestInputOneOf {
  @override
  final WorkRequestInputOneOfKindEnum kind;
  @override
  final String routeId;
  @override
  final Date? fromDate;
  @override
  final String? note;

  factory _$WorkRequestInputOneOf(
          [void Function(WorkRequestInputOneOfBuilder)? updates]) =>
      (WorkRequestInputOneOfBuilder()..update(updates))._build();

  _$WorkRequestInputOneOf._(
      {required this.kind, required this.routeId, this.fromDate, this.note})
      : super._();
  @override
  WorkRequestInputOneOf rebuild(
          void Function(WorkRequestInputOneOfBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  WorkRequestInputOneOfBuilder toBuilder() =>
      WorkRequestInputOneOfBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WorkRequestInputOneOf &&
        kind == other.kind &&
        routeId == other.routeId &&
        fromDate == other.fromDate &&
        note == other.note;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, routeId.hashCode);
    _$hash = $jc(_$hash, fromDate.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'WorkRequestInputOneOf')
          ..add('kind', kind)
          ..add('routeId', routeId)
          ..add('fromDate', fromDate)
          ..add('note', note))
        .toString();
  }
}

class WorkRequestInputOneOfBuilder
    implements Builder<WorkRequestInputOneOf, WorkRequestInputOneOfBuilder> {
  _$WorkRequestInputOneOf? _$v;

  WorkRequestInputOneOfKindEnum? _kind;
  WorkRequestInputOneOfKindEnum? get kind => _$this._kind;
  set kind(WorkRequestInputOneOfKindEnum? kind) => _$this._kind = kind;

  String? _routeId;
  String? get routeId => _$this._routeId;
  set routeId(String? routeId) => _$this._routeId = routeId;

  Date? _fromDate;
  Date? get fromDate => _$this._fromDate;
  set fromDate(Date? fromDate) => _$this._fromDate = fromDate;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  WorkRequestInputOneOfBuilder() {
    WorkRequestInputOneOf._defaults(this);
  }

  WorkRequestInputOneOfBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _kind = $v.kind;
      _routeId = $v.routeId;
      _fromDate = $v.fromDate;
      _note = $v.note;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WorkRequestInputOneOf other) {
    _$v = other as _$WorkRequestInputOneOf;
  }

  @override
  void update(void Function(WorkRequestInputOneOfBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WorkRequestInputOneOf build() => _build();

  _$WorkRequestInputOneOf _build() {
    final _$result = _$v ??
        _$WorkRequestInputOneOf._(
          kind: BuiltValueNullFieldError.checkNotNull(
              kind, r'WorkRequestInputOneOf', 'kind'),
          routeId: BuiltValueNullFieldError.checkNotNull(
              routeId, r'WorkRequestInputOneOf', 'routeId'),
          fromDate: fromDate,
          note: note,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
