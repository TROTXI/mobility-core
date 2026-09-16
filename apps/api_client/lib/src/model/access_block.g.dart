// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'access_block.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AccessBlockKindEnum _$accessBlockKindEnum_paused =
    const AccessBlockKindEnum._('paused');
const AccessBlockKindEnum _$accessBlockKindEnum_dispute =
    const AccessBlockKindEnum._('dispute');
const AccessBlockKindEnum _$accessBlockKindEnum_opsRestriction =
    const AccessBlockKindEnum._('opsRestriction');

AccessBlockKindEnum _$accessBlockKindEnumValueOf(String name) {
  switch (name) {
    case 'paused':
      return _$accessBlockKindEnum_paused;
    case 'dispute':
      return _$accessBlockKindEnum_dispute;
    case 'opsRestriction':
      return _$accessBlockKindEnum_opsRestriction;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<AccessBlockKindEnum> _$accessBlockKindEnumValues =
    BuiltSet<AccessBlockKindEnum>(const <AccessBlockKindEnum>[
  _$accessBlockKindEnum_paused,
  _$accessBlockKindEnum_dispute,
  _$accessBlockKindEnum_opsRestriction,
]);

const AccessBlockScopeEnum _$accessBlockScopeEnum_period =
    const AccessBlockScopeEnum._('period');
const AccessBlockScopeEnum _$accessBlockScopeEnum_account =
    const AccessBlockScopeEnum._('account');

AccessBlockScopeEnum _$accessBlockScopeEnumValueOf(String name) {
  switch (name) {
    case 'period':
      return _$accessBlockScopeEnum_period;
    case 'account':
      return _$accessBlockScopeEnum_account;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<AccessBlockScopeEnum> _$accessBlockScopeEnumValues =
    BuiltSet<AccessBlockScopeEnum>(const <AccessBlockScopeEnum>[
  _$accessBlockScopeEnum_period,
  _$accessBlockScopeEnum_account,
]);

Serializer<AccessBlockKindEnum> _$accessBlockKindEnumSerializer =
    _$AccessBlockKindEnumSerializer();
Serializer<AccessBlockScopeEnum> _$accessBlockScopeEnumSerializer =
    _$AccessBlockScopeEnumSerializer();

class _$AccessBlockKindEnumSerializer
    implements PrimitiveSerializer<AccessBlockKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'paused': 'paused',
    'dispute': 'dispute',
    'opsRestriction': 'ops_restriction',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'paused': 'paused',
    'dispute': 'dispute',
    'ops_restriction': 'opsRestriction',
  };

  @override
  final Iterable<Type> types = const <Type>[AccessBlockKindEnum];
  @override
  final String wireName = 'AccessBlockKindEnum';

  @override
  Object serialize(Serializers serializers, AccessBlockKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  AccessBlockKindEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      AccessBlockKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$AccessBlockScopeEnumSerializer
    implements PrimitiveSerializer<AccessBlockScopeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'period': 'period',
    'account': 'account',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'period': 'period',
    'account': 'account',
  };

  @override
  final Iterable<Type> types = const <Type>[AccessBlockScopeEnum];
  @override
  final String wireName = 'AccessBlockScopeEnum';

  @override
  Object serialize(Serializers serializers, AccessBlockScopeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  AccessBlockScopeEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      AccessBlockScopeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$AccessBlock extends AccessBlock {
  @override
  final AccessBlockKindEnum kind;
  @override
  final AccessBlockScopeEnum scope;
  @override
  final String? periodId;

  factory _$AccessBlock([void Function(AccessBlockBuilder)? updates]) =>
      (AccessBlockBuilder()..update(updates))._build();

  _$AccessBlock._({required this.kind, required this.scope, this.periodId})
      : super._();
  @override
  AccessBlock rebuild(void Function(AccessBlockBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AccessBlockBuilder toBuilder() => AccessBlockBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AccessBlock &&
        kind == other.kind &&
        scope == other.scope &&
        periodId == other.periodId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, scope.hashCode);
    _$hash = $jc(_$hash, periodId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AccessBlock')
          ..add('kind', kind)
          ..add('scope', scope)
          ..add('periodId', periodId))
        .toString();
  }
}

class AccessBlockBuilder implements Builder<AccessBlock, AccessBlockBuilder> {
  _$AccessBlock? _$v;

  AccessBlockKindEnum? _kind;
  AccessBlockKindEnum? get kind => _$this._kind;
  set kind(AccessBlockKindEnum? kind) => _$this._kind = kind;

  AccessBlockScopeEnum? _scope;
  AccessBlockScopeEnum? get scope => _$this._scope;
  set scope(AccessBlockScopeEnum? scope) => _$this._scope = scope;

  String? _periodId;
  String? get periodId => _$this._periodId;
  set periodId(String? periodId) => _$this._periodId = periodId;

  AccessBlockBuilder() {
    AccessBlock._defaults(this);
  }

  AccessBlockBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _kind = $v.kind;
      _scope = $v.scope;
      _periodId = $v.periodId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AccessBlock other) {
    _$v = other as _$AccessBlock;
  }

  @override
  void update(void Function(AccessBlockBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AccessBlock build() => _build();

  _$AccessBlock _build() {
    final _$result = _$v ??
        _$AccessBlock._(
          kind: BuiltValueNullFieldError.checkNotNull(
              kind, r'AccessBlock', 'kind'),
          scope: BuiltValueNullFieldError.checkNotNull(
              scope, r'AccessBlock', 'scope'),
          periodId: periodId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
