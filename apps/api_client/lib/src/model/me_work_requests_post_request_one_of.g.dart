// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'me_work_requests_post_request_one_of.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MeWorkRequestsPostRequestOneOfKindEnum
    _$meWorkRequestsPostRequestOneOfKindEnum_routeChange =
    const MeWorkRequestsPostRequestOneOfKindEnum._('routeChange');

MeWorkRequestsPostRequestOneOfKindEnum
    _$meWorkRequestsPostRequestOneOfKindEnumValueOf(String name) {
  switch (name) {
    case 'routeChange':
      return _$meWorkRequestsPostRequestOneOfKindEnum_routeChange;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<MeWorkRequestsPostRequestOneOfKindEnum>
    _$meWorkRequestsPostRequestOneOfKindEnumValues = BuiltSet<
        MeWorkRequestsPostRequestOneOfKindEnum>(const <MeWorkRequestsPostRequestOneOfKindEnum>[
  _$meWorkRequestsPostRequestOneOfKindEnum_routeChange,
]);

Serializer<MeWorkRequestsPostRequestOneOfKindEnum>
    _$meWorkRequestsPostRequestOneOfKindEnumSerializer =
    _$MeWorkRequestsPostRequestOneOfKindEnumSerializer();

class _$MeWorkRequestsPostRequestOneOfKindEnumSerializer
    implements PrimitiveSerializer<MeWorkRequestsPostRequestOneOfKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'routeChange': 'route_change',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'route_change': 'routeChange',
  };

  @override
  final Iterable<Type> types = const <Type>[
    MeWorkRequestsPostRequestOneOfKindEnum
  ];
  @override
  final String wireName = 'MeWorkRequestsPostRequestOneOfKindEnum';

  @override
  Object serialize(Serializers serializers,
          MeWorkRequestsPostRequestOneOfKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  MeWorkRequestsPostRequestOneOfKindEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      MeWorkRequestsPostRequestOneOfKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$MeWorkRequestsPostRequestOneOf extends MeWorkRequestsPostRequestOneOf {
  @override
  final MeWorkRequestsPostRequestOneOfKindEnum kind;
  @override
  final String routeId;
  @override
  final String? fromDate;
  @override
  final String? note;

  factory _$MeWorkRequestsPostRequestOneOf(
          [void Function(MeWorkRequestsPostRequestOneOfBuilder)? updates]) =>
      (MeWorkRequestsPostRequestOneOfBuilder()..update(updates))._build();

  _$MeWorkRequestsPostRequestOneOf._(
      {required this.kind, required this.routeId, this.fromDate, this.note})
      : super._();
  @override
  MeWorkRequestsPostRequestOneOf rebuild(
          void Function(MeWorkRequestsPostRequestOneOfBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MeWorkRequestsPostRequestOneOfBuilder toBuilder() =>
      MeWorkRequestsPostRequestOneOfBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MeWorkRequestsPostRequestOneOf &&
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
    return (newBuiltValueToStringHelper(r'MeWorkRequestsPostRequestOneOf')
          ..add('kind', kind)
          ..add('routeId', routeId)
          ..add('fromDate', fromDate)
          ..add('note', note))
        .toString();
  }
}

class MeWorkRequestsPostRequestOneOfBuilder
    implements
        Builder<MeWorkRequestsPostRequestOneOf,
            MeWorkRequestsPostRequestOneOfBuilder> {
  _$MeWorkRequestsPostRequestOneOf? _$v;

  MeWorkRequestsPostRequestOneOfKindEnum? _kind;
  MeWorkRequestsPostRequestOneOfKindEnum? get kind => _$this._kind;
  set kind(MeWorkRequestsPostRequestOneOfKindEnum? kind) => _$this._kind = kind;

  String? _routeId;
  String? get routeId => _$this._routeId;
  set routeId(String? routeId) => _$this._routeId = routeId;

  String? _fromDate;
  String? get fromDate => _$this._fromDate;
  set fromDate(String? fromDate) => _$this._fromDate = fromDate;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  MeWorkRequestsPostRequestOneOfBuilder() {
    MeWorkRequestsPostRequestOneOf._defaults(this);
  }

  MeWorkRequestsPostRequestOneOfBuilder get _$this {
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
  void replace(MeWorkRequestsPostRequestOneOf other) {
    _$v = other as _$MeWorkRequestsPostRequestOneOf;
  }

  @override
  void update(void Function(MeWorkRequestsPostRequestOneOfBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MeWorkRequestsPostRequestOneOf build() => _build();

  _$MeWorkRequestsPostRequestOneOf _build() {
    final _$result = _$v ??
        _$MeWorkRequestsPostRequestOneOf._(
          kind: BuiltValueNullFieldError.checkNotNull(
              kind, r'MeWorkRequestsPostRequestOneOf', 'kind'),
          routeId: BuiltValueNullFieldError.checkNotNull(
              routeId, r'MeWorkRequestsPostRequestOneOf', 'routeId'),
          fromDate: fromDate,
          note: note,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
