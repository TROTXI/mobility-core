// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_request_input_one_of1.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const WorkRequestInputOneOf1KindEnum _$workRequestInputOneOf1KindEnum_leave =
    const WorkRequestInputOneOf1KindEnum._('leave');

WorkRequestInputOneOf1KindEnum _$workRequestInputOneOf1KindEnumValueOf(
    String name) {
  switch (name) {
    case 'leave':
      return _$workRequestInputOneOf1KindEnum_leave;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<WorkRequestInputOneOf1KindEnum>
    _$workRequestInputOneOf1KindEnumValues = BuiltSet<
        WorkRequestInputOneOf1KindEnum>(const <WorkRequestInputOneOf1KindEnum>[
  _$workRequestInputOneOf1KindEnum_leave,
]);

Serializer<WorkRequestInputOneOf1KindEnum>
    _$workRequestInputOneOf1KindEnumSerializer =
    _$WorkRequestInputOneOf1KindEnumSerializer();

class _$WorkRequestInputOneOf1KindEnumSerializer
    implements PrimitiveSerializer<WorkRequestInputOneOf1KindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'leave': 'leave',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'leave': 'leave',
  };

  @override
  final Iterable<Type> types = const <Type>[WorkRequestInputOneOf1KindEnum];
  @override
  final String wireName = 'WorkRequestInputOneOf1KindEnum';

  @override
  Object serialize(
          Serializers serializers, WorkRequestInputOneOf1KindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  WorkRequestInputOneOf1KindEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      WorkRequestInputOneOf1KindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$WorkRequestInputOneOf1 extends WorkRequestInputOneOf1 {
  @override
  final WorkRequestInputOneOf1KindEnum kind;
  @override
  final Date fromDate;
  @override
  final Date toDate;
  @override
  final String? note;

  factory _$WorkRequestInputOneOf1(
          [void Function(WorkRequestInputOneOf1Builder)? updates]) =>
      (WorkRequestInputOneOf1Builder()..update(updates))._build();

  _$WorkRequestInputOneOf1._(
      {required this.kind,
      required this.fromDate,
      required this.toDate,
      this.note})
      : super._();
  @override
  WorkRequestInputOneOf1 rebuild(
          void Function(WorkRequestInputOneOf1Builder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  WorkRequestInputOneOf1Builder toBuilder() =>
      WorkRequestInputOneOf1Builder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WorkRequestInputOneOf1 &&
        kind == other.kind &&
        fromDate == other.fromDate &&
        toDate == other.toDate &&
        note == other.note;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, fromDate.hashCode);
    _$hash = $jc(_$hash, toDate.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'WorkRequestInputOneOf1')
          ..add('kind', kind)
          ..add('fromDate', fromDate)
          ..add('toDate', toDate)
          ..add('note', note))
        .toString();
  }
}

class WorkRequestInputOneOf1Builder
    implements Builder<WorkRequestInputOneOf1, WorkRequestInputOneOf1Builder> {
  _$WorkRequestInputOneOf1? _$v;

  WorkRequestInputOneOf1KindEnum? _kind;
  WorkRequestInputOneOf1KindEnum? get kind => _$this._kind;
  set kind(WorkRequestInputOneOf1KindEnum? kind) => _$this._kind = kind;

  Date? _fromDate;
  Date? get fromDate => _$this._fromDate;
  set fromDate(Date? fromDate) => _$this._fromDate = fromDate;

  Date? _toDate;
  Date? get toDate => _$this._toDate;
  set toDate(Date? toDate) => _$this._toDate = toDate;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  WorkRequestInputOneOf1Builder() {
    WorkRequestInputOneOf1._defaults(this);
  }

  WorkRequestInputOneOf1Builder get _$this {
    final $v = _$v;
    if ($v != null) {
      _kind = $v.kind;
      _fromDate = $v.fromDate;
      _toDate = $v.toDate;
      _note = $v.note;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WorkRequestInputOneOf1 other) {
    _$v = other as _$WorkRequestInputOneOf1;
  }

  @override
  void update(void Function(WorkRequestInputOneOf1Builder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WorkRequestInputOneOf1 build() => _build();

  _$WorkRequestInputOneOf1 _build() {
    final _$result = _$v ??
        _$WorkRequestInputOneOf1._(
          kind: BuiltValueNullFieldError.checkNotNull(
              kind, r'WorkRequestInputOneOf1', 'kind'),
          fromDate: BuiltValueNullFieldError.checkNotNull(
              fromDate, r'WorkRequestInputOneOf1', 'fromDate'),
          toDate: BuiltValueNullFieldError.checkNotNull(
              toDate, r'WorkRequestInputOneOf1', 'toDate'),
          note: note,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
