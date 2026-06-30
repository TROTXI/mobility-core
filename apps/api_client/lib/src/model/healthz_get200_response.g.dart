// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'healthz_get200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const HealthzGet200ResponseStatusEnum _$healthzGet200ResponseStatusEnum_ok =
    const HealthzGet200ResponseStatusEnum._('ok');

HealthzGet200ResponseStatusEnum _$healthzGet200ResponseStatusEnumValueOf(
    String name) {
  switch (name) {
    case 'ok':
      return _$healthzGet200ResponseStatusEnum_ok;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<HealthzGet200ResponseStatusEnum>
    _$healthzGet200ResponseStatusEnumValues = BuiltSet<
        HealthzGet200ResponseStatusEnum>(const <HealthzGet200ResponseStatusEnum>[
  _$healthzGet200ResponseStatusEnum_ok,
]);

Serializer<HealthzGet200ResponseStatusEnum>
    _$healthzGet200ResponseStatusEnumSerializer =
    _$HealthzGet200ResponseStatusEnumSerializer();

class _$HealthzGet200ResponseStatusEnumSerializer
    implements PrimitiveSerializer<HealthzGet200ResponseStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ok': 'ok',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ok': 'ok',
  };

  @override
  final Iterable<Type> types = const <Type>[HealthzGet200ResponseStatusEnum];
  @override
  final String wireName = 'HealthzGet200ResponseStatusEnum';

  @override
  Object serialize(
          Serializers serializers, HealthzGet200ResponseStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  HealthzGet200ResponseStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      HealthzGet200ResponseStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$HealthzGet200Response extends HealthzGet200Response {
  @override
  final HealthzGet200ResponseStatusEnum status;

  factory _$HealthzGet200Response(
          [void Function(HealthzGet200ResponseBuilder)? updates]) =>
      (HealthzGet200ResponseBuilder()..update(updates))._build();

  _$HealthzGet200Response._({required this.status}) : super._();
  @override
  HealthzGet200Response rebuild(
          void Function(HealthzGet200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  HealthzGet200ResponseBuilder toBuilder() =>
      HealthzGet200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is HealthzGet200Response && status == other.status;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'HealthzGet200Response')
          ..add('status', status))
        .toString();
  }
}

class HealthzGet200ResponseBuilder
    implements Builder<HealthzGet200Response, HealthzGet200ResponseBuilder> {
  _$HealthzGet200Response? _$v;

  HealthzGet200ResponseStatusEnum? _status;
  HealthzGet200ResponseStatusEnum? get status => _$this._status;
  set status(HealthzGet200ResponseStatusEnum? status) =>
      _$this._status = status;

  HealthzGet200ResponseBuilder() {
    HealthzGet200Response._defaults(this);
  }

  HealthzGet200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _status = $v.status;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(HealthzGet200Response other) {
    _$v = other as _$HealthzGet200Response;
  }

  @override
  void update(void Function(HealthzGet200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  HealthzGet200Response build() => _build();

  _$HealthzGet200Response _build() {
    final _$result = _$v ??
        _$HealthzGet200Response._(
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'HealthzGet200Response', 'status'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
