// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commute_decision.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CommuteDecisionActionEnum _$commuteDecisionActionEnum_reject =
    const CommuteDecisionActionEnum._('reject');

CommuteDecisionActionEnum _$commuteDecisionActionEnumValueOf(String name) {
  switch (name) {
    case 'reject':
      return _$commuteDecisionActionEnum_reject;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CommuteDecisionActionEnum> _$commuteDecisionActionEnumValues =
    BuiltSet<CommuteDecisionActionEnum>(const <CommuteDecisionActionEnum>[
  _$commuteDecisionActionEnum_reject,
]);

Serializer<CommuteDecisionActionEnum> _$commuteDecisionActionEnumSerializer =
    _$CommuteDecisionActionEnumSerializer();

class _$CommuteDecisionActionEnumSerializer
    implements PrimitiveSerializer<CommuteDecisionActionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'reject': 'reject',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'reject': 'reject',
  };

  @override
  final Iterable<Type> types = const <Type>[CommuteDecisionActionEnum];
  @override
  final String wireName = 'CommuteDecisionActionEnum';

  @override
  Object serialize(Serializers serializers, CommuteDecisionActionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CommuteDecisionActionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CommuteDecisionActionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$CommuteDecision extends CommuteDecision {
  @override
  final OneOf oneOf;

  factory _$CommuteDecision([void Function(CommuteDecisionBuilder)? updates]) =>
      (CommuteDecisionBuilder()..update(updates))._build();

  _$CommuteDecision._({required this.oneOf}) : super._();
  @override
  CommuteDecision rebuild(void Function(CommuteDecisionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CommuteDecisionBuilder toBuilder() => CommuteDecisionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CommuteDecision && oneOf == other.oneOf;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, oneOf.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CommuteDecision')
          ..add('oneOf', oneOf))
        .toString();
  }
}

class CommuteDecisionBuilder
    implements Builder<CommuteDecision, CommuteDecisionBuilder> {
  _$CommuteDecision? _$v;

  OneOf? _oneOf;
  OneOf? get oneOf => _$this._oneOf;
  set oneOf(OneOf? oneOf) => _$this._oneOf = oneOf;

  CommuteDecisionBuilder() {
    CommuteDecision._defaults(this);
  }

  CommuteDecisionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _oneOf = $v.oneOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CommuteDecision other) {
    _$v = other as _$CommuteDecision;
  }

  @override
  void update(void Function(CommuteDecisionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CommuteDecision build() => _build();

  _$CommuteDecision _build() {
    final _$result = _$v ??
        _$CommuteDecision._(
          oneOf: BuiltValueNullFieldError.checkNotNull(
              oneOf, r'CommuteDecision', 'oneOf'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
