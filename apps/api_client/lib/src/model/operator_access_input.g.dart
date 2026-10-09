// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'operator_access_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const OperatorAccessInputActionEnum _$operatorAccessInputActionEnum_delete =
    const OperatorAccessInputActionEnum._('delete');
const OperatorAccessInputActionEnum
    _$operatorAccessInputActionEnum_makeSuperadmin =
    const OperatorAccessInputActionEnum._('makeSuperadmin');
const OperatorAccessInputActionEnum _$operatorAccessInputActionEnum_makeAdmin =
    const OperatorAccessInputActionEnum._('makeAdmin');

OperatorAccessInputActionEnum _$operatorAccessInputActionEnumValueOf(
    String name) {
  switch (name) {
    case 'delete':
      return _$operatorAccessInputActionEnum_delete;
    case 'makeSuperadmin':
      return _$operatorAccessInputActionEnum_makeSuperadmin;
    case 'makeAdmin':
      return _$operatorAccessInputActionEnum_makeAdmin;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<OperatorAccessInputActionEnum>
    _$operatorAccessInputActionEnumValues = BuiltSet<
        OperatorAccessInputActionEnum>(const <OperatorAccessInputActionEnum>[
  _$operatorAccessInputActionEnum_delete,
  _$operatorAccessInputActionEnum_makeSuperadmin,
  _$operatorAccessInputActionEnum_makeAdmin,
]);

Serializer<OperatorAccessInputActionEnum>
    _$operatorAccessInputActionEnumSerializer =
    _$OperatorAccessInputActionEnumSerializer();

class _$OperatorAccessInputActionEnumSerializer
    implements PrimitiveSerializer<OperatorAccessInputActionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'delete': 'delete',
    'makeSuperadmin': 'make_superadmin',
    'makeAdmin': 'make_admin',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'delete': 'delete',
    'make_superadmin': 'makeSuperadmin',
    'make_admin': 'makeAdmin',
  };

  @override
  final Iterable<Type> types = const <Type>[OperatorAccessInputActionEnum];
  @override
  final String wireName = 'OperatorAccessInputActionEnum';

  @override
  Object serialize(
          Serializers serializers, OperatorAccessInputActionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  OperatorAccessInputActionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      OperatorAccessInputActionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$OperatorAccessInput extends OperatorAccessInput {
  @override
  final OperatorAccessInputActionEnum action;

  factory _$OperatorAccessInput(
          [void Function(OperatorAccessInputBuilder)? updates]) =>
      (OperatorAccessInputBuilder()..update(updates))._build();

  _$OperatorAccessInput._({required this.action}) : super._();
  @override
  OperatorAccessInput rebuild(
          void Function(OperatorAccessInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OperatorAccessInputBuilder toBuilder() =>
      OperatorAccessInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OperatorAccessInput && action == other.action;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, action.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OperatorAccessInput')
          ..add('action', action))
        .toString();
  }
}

class OperatorAccessInputBuilder
    implements Builder<OperatorAccessInput, OperatorAccessInputBuilder> {
  _$OperatorAccessInput? _$v;

  OperatorAccessInputActionEnum? _action;
  OperatorAccessInputActionEnum? get action => _$this._action;
  set action(OperatorAccessInputActionEnum? action) => _$this._action = action;

  OperatorAccessInputBuilder() {
    OperatorAccessInput._defaults(this);
  }

  OperatorAccessInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _action = $v.action;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OperatorAccessInput other) {
    _$v = other as _$OperatorAccessInput;
  }

  @override
  void update(void Function(OperatorAccessInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OperatorAccessInput build() => _build();

  _$OperatorAccessInput _build() {
    final _$result = _$v ??
        _$OperatorAccessInput._(
          action: BuiltValueNullFieldError.checkNotNull(
              action, r'OperatorAccessInput', 'action'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
