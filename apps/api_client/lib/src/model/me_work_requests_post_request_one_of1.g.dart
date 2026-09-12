// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'me_work_requests_post_request_one_of1.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MeWorkRequestsPostRequestOneOf1KindEnum
    _$meWorkRequestsPostRequestOneOf1KindEnum_leave =
    const MeWorkRequestsPostRequestOneOf1KindEnum._('leave');

MeWorkRequestsPostRequestOneOf1KindEnum
    _$meWorkRequestsPostRequestOneOf1KindEnumValueOf(String name) {
  switch (name) {
    case 'leave':
      return _$meWorkRequestsPostRequestOneOf1KindEnum_leave;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<MeWorkRequestsPostRequestOneOf1KindEnum>
    _$meWorkRequestsPostRequestOneOf1KindEnumValues = BuiltSet<
        MeWorkRequestsPostRequestOneOf1KindEnum>(const <MeWorkRequestsPostRequestOneOf1KindEnum>[
  _$meWorkRequestsPostRequestOneOf1KindEnum_leave,
]);

Serializer<MeWorkRequestsPostRequestOneOf1KindEnum>
    _$meWorkRequestsPostRequestOneOf1KindEnumSerializer =
    _$MeWorkRequestsPostRequestOneOf1KindEnumSerializer();

class _$MeWorkRequestsPostRequestOneOf1KindEnumSerializer
    implements PrimitiveSerializer<MeWorkRequestsPostRequestOneOf1KindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'leave': 'leave',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'leave': 'leave',
  };

  @override
  final Iterable<Type> types = const <Type>[
    MeWorkRequestsPostRequestOneOf1KindEnum
  ];
  @override
  final String wireName = 'MeWorkRequestsPostRequestOneOf1KindEnum';

  @override
  Object serialize(Serializers serializers,
          MeWorkRequestsPostRequestOneOf1KindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  MeWorkRequestsPostRequestOneOf1KindEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      MeWorkRequestsPostRequestOneOf1KindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$MeWorkRequestsPostRequestOneOf1
    extends MeWorkRequestsPostRequestOneOf1 {
  @override
  final MeWorkRequestsPostRequestOneOf1KindEnum kind;
  @override
  final String fromDate;
  @override
  final String toDate;
  @override
  final String? note;

  factory _$MeWorkRequestsPostRequestOneOf1(
          [void Function(MeWorkRequestsPostRequestOneOf1Builder)? updates]) =>
      (MeWorkRequestsPostRequestOneOf1Builder()..update(updates))._build();

  _$MeWorkRequestsPostRequestOneOf1._(
      {required this.kind,
      required this.fromDate,
      required this.toDate,
      this.note})
      : super._();
  @override
  MeWorkRequestsPostRequestOneOf1 rebuild(
          void Function(MeWorkRequestsPostRequestOneOf1Builder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MeWorkRequestsPostRequestOneOf1Builder toBuilder() =>
      MeWorkRequestsPostRequestOneOf1Builder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MeWorkRequestsPostRequestOneOf1 &&
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
    return (newBuiltValueToStringHelper(r'MeWorkRequestsPostRequestOneOf1')
          ..add('kind', kind)
          ..add('fromDate', fromDate)
          ..add('toDate', toDate)
          ..add('note', note))
        .toString();
  }
}

class MeWorkRequestsPostRequestOneOf1Builder
    implements
        Builder<MeWorkRequestsPostRequestOneOf1,
            MeWorkRequestsPostRequestOneOf1Builder> {
  _$MeWorkRequestsPostRequestOneOf1? _$v;

  MeWorkRequestsPostRequestOneOf1KindEnum? _kind;
  MeWorkRequestsPostRequestOneOf1KindEnum? get kind => _$this._kind;
  set kind(MeWorkRequestsPostRequestOneOf1KindEnum? kind) =>
      _$this._kind = kind;

  String? _fromDate;
  String? get fromDate => _$this._fromDate;
  set fromDate(String? fromDate) => _$this._fromDate = fromDate;

  String? _toDate;
  String? get toDate => _$this._toDate;
  set toDate(String? toDate) => _$this._toDate = toDate;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  MeWorkRequestsPostRequestOneOf1Builder() {
    MeWorkRequestsPostRequestOneOf1._defaults(this);
  }

  MeWorkRequestsPostRequestOneOf1Builder get _$this {
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
  void replace(MeWorkRequestsPostRequestOneOf1 other) {
    _$v = other as _$MeWorkRequestsPostRequestOneOf1;
  }

  @override
  void update(void Function(MeWorkRequestsPostRequestOneOf1Builder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MeWorkRequestsPostRequestOneOf1 build() => _build();

  _$MeWorkRequestsPostRequestOneOf1 _build() {
    final _$result = _$v ??
        _$MeWorkRequestsPostRequestOneOf1._(
          kind: BuiltValueNullFieldError.checkNotNull(
              kind, r'MeWorkRequestsPostRequestOneOf1', 'kind'),
          fromDate: BuiltValueNullFieldError.checkNotNull(
              fromDate, r'MeWorkRequestsPostRequestOneOf1', 'fromDate'),
          toDate: BuiltValueNullFieldError.checkNotNull(
              toDate, r'MeWorkRequestsPostRequestOneOf1', 'toDate'),
          note: note,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
