// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'readyz_get200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ReadyzGet200ResponseStatusEnum _$readyzGet200ResponseStatusEnum_ready =
    const ReadyzGet200ResponseStatusEnum._('ready');

ReadyzGet200ResponseStatusEnum _$readyzGet200ResponseStatusEnumValueOf(
    String name) {
  switch (name) {
    case 'ready':
      return _$readyzGet200ResponseStatusEnum_ready;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ReadyzGet200ResponseStatusEnum>
    _$readyzGet200ResponseStatusEnumValues = BuiltSet<
        ReadyzGet200ResponseStatusEnum>(const <ReadyzGet200ResponseStatusEnum>[
  _$readyzGet200ResponseStatusEnum_ready,
]);

Serializer<ReadyzGet200ResponseStatusEnum>
    _$readyzGet200ResponseStatusEnumSerializer =
    _$ReadyzGet200ResponseStatusEnumSerializer();

class _$ReadyzGet200ResponseStatusEnumSerializer
    implements PrimitiveSerializer<ReadyzGet200ResponseStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ready': 'ready',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ready': 'ready',
  };

  @override
  final Iterable<Type> types = const <Type>[ReadyzGet200ResponseStatusEnum];
  @override
  final String wireName = 'ReadyzGet200ResponseStatusEnum';

  @override
  Object serialize(
          Serializers serializers, ReadyzGet200ResponseStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ReadyzGet200ResponseStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ReadyzGet200ResponseStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ReadyzGet200Response extends ReadyzGet200Response {
  @override
  final ReadyzGet200ResponseStatusEnum status;

  factory _$ReadyzGet200Response(
          [void Function(ReadyzGet200ResponseBuilder)? updates]) =>
      (ReadyzGet200ResponseBuilder()..update(updates))._build();

  _$ReadyzGet200Response._({required this.status}) : super._();
  @override
  ReadyzGet200Response rebuild(
          void Function(ReadyzGet200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReadyzGet200ResponseBuilder toBuilder() =>
      ReadyzGet200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReadyzGet200Response && status == other.status;
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
    return (newBuiltValueToStringHelper(r'ReadyzGet200Response')
          ..add('status', status))
        .toString();
  }
}

class ReadyzGet200ResponseBuilder
    implements Builder<ReadyzGet200Response, ReadyzGet200ResponseBuilder> {
  _$ReadyzGet200Response? _$v;

  ReadyzGet200ResponseStatusEnum? _status;
  ReadyzGet200ResponseStatusEnum? get status => _$this._status;
  set status(ReadyzGet200ResponseStatusEnum? status) => _$this._status = status;

  ReadyzGet200ResponseBuilder() {
    ReadyzGet200Response._defaults(this);
  }

  ReadyzGet200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _status = $v.status;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReadyzGet200Response other) {
    _$v = other as _$ReadyzGet200Response;
  }

  @override
  void update(void Function(ReadyzGet200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReadyzGet200Response build() => _build();

  _$ReadyzGet200Response _build() {
    final _$result = _$v ??
        _$ReadyzGet200Response._(
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'ReadyzGet200Response', 'status'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
