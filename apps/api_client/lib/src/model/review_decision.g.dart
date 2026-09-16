// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_decision.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ReviewDecisionDecisionEnum _$reviewDecisionDecisionEnum_resolved =
    const ReviewDecisionDecisionEnum._('resolved');
const ReviewDecisionDecisionEnum _$reviewDecisionDecisionEnum_waived =
    const ReviewDecisionDecisionEnum._('waived');

ReviewDecisionDecisionEnum _$reviewDecisionDecisionEnumValueOf(String name) {
  switch (name) {
    case 'resolved':
      return _$reviewDecisionDecisionEnum_resolved;
    case 'waived':
      return _$reviewDecisionDecisionEnum_waived;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ReviewDecisionDecisionEnum> _$reviewDecisionDecisionEnumValues =
    BuiltSet<ReviewDecisionDecisionEnum>(const <ReviewDecisionDecisionEnum>[
  _$reviewDecisionDecisionEnum_resolved,
  _$reviewDecisionDecisionEnum_waived,
]);

Serializer<ReviewDecisionDecisionEnum> _$reviewDecisionDecisionEnumSerializer =
    _$ReviewDecisionDecisionEnumSerializer();

class _$ReviewDecisionDecisionEnumSerializer
    implements PrimitiveSerializer<ReviewDecisionDecisionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'resolved': 'resolved',
    'waived': 'waived',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'resolved': 'resolved',
    'waived': 'waived',
  };

  @override
  final Iterable<Type> types = const <Type>[ReviewDecisionDecisionEnum];
  @override
  final String wireName = 'ReviewDecisionDecisionEnum';

  @override
  Object serialize(Serializers serializers, ReviewDecisionDecisionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ReviewDecisionDecisionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ReviewDecisionDecisionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ReviewDecision extends ReviewDecision {
  @override
  final ReviewDecisionDecisionEnum decision;
  @override
  final String reason;

  factory _$ReviewDecision([void Function(ReviewDecisionBuilder)? updates]) =>
      (ReviewDecisionBuilder()..update(updates))._build();

  _$ReviewDecision._({required this.decision, required this.reason})
      : super._();
  @override
  ReviewDecision rebuild(void Function(ReviewDecisionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReviewDecisionBuilder toBuilder() => ReviewDecisionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReviewDecision &&
        decision == other.decision &&
        reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, decision.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ReviewDecision')
          ..add('decision', decision)
          ..add('reason', reason))
        .toString();
  }
}

class ReviewDecisionBuilder
    implements Builder<ReviewDecision, ReviewDecisionBuilder> {
  _$ReviewDecision? _$v;

  ReviewDecisionDecisionEnum? _decision;
  ReviewDecisionDecisionEnum? get decision => _$this._decision;
  set decision(ReviewDecisionDecisionEnum? decision) =>
      _$this._decision = decision;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  ReviewDecisionBuilder() {
    ReviewDecision._defaults(this);
  }

  ReviewDecisionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _decision = $v.decision;
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReviewDecision other) {
    _$v = other as _$ReviewDecision;
  }

  @override
  void update(void Function(ReviewDecisionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReviewDecision build() => _build();

  _$ReviewDecision _build() {
    final _$result = _$v ??
        _$ReviewDecision._(
          decision: BuiltValueNullFieldError.checkNotNull(
              decision, r'ReviewDecision', 'decision'),
          reason: BuiltValueNullFieldError.checkNotNull(
              reason, r'ReviewDecision', 'reason'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
