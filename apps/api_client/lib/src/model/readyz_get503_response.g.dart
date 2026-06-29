// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'readyz_get503_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ReadyzGet503ResponseStatusEnum _$readyzGet503ResponseStatusEnum_notReady =
    const ReadyzGet503ResponseStatusEnum._('notReady');

ReadyzGet503ResponseStatusEnum _$readyzGet503ResponseStatusEnumValueOf(
    String name) {
  switch (name) {
    case 'notReady':
      return _$readyzGet503ResponseStatusEnum_notReady;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ReadyzGet503ResponseStatusEnum>
    _$readyzGet503ResponseStatusEnumValues = BuiltSet<
        ReadyzGet503ResponseStatusEnum>(const <ReadyzGet503ResponseStatusEnum>[
  _$readyzGet503ResponseStatusEnum_notReady,
]);

Serializer<ReadyzGet503ResponseStatusEnum>
    _$readyzGet503ResponseStatusEnumSerializer =
    _$ReadyzGet503ResponseStatusEnumSerializer();

class _$ReadyzGet503ResponseStatusEnumSerializer
    implements PrimitiveSerializer<ReadyzGet503ResponseStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'notReady': 'not_ready',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'not_ready': 'notReady',
  };

  @override
  final Iterable<Type> types = const <Type>[ReadyzGet503ResponseStatusEnum];
  @override
  final String wireName = 'ReadyzGet503ResponseStatusEnum';

  @override
  Object serialize(
          Serializers serializers, ReadyzGet503ResponseStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ReadyzGet503ResponseStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ReadyzGet503ResponseStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ReadyzGet503Response extends ReadyzGet503Response {
  @override
  final ReadyzGet503ResponseStatusEnum status;

  factory _$ReadyzGet503Response(
          [void Function(ReadyzGet503ResponseBuilder)? updates]) =>
      (ReadyzGet503ResponseBuilder()..update(updates))._build();

  _$ReadyzGet503Response._({required this.status}) : super._();
  @override
  ReadyzGet503Response rebuild(
          void Function(ReadyzGet503ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReadyzGet503ResponseBuilder toBuilder() =>
      ReadyzGet503ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReadyzGet503Response && status == other.status;
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
    return (newBuiltValueToStringHelper(r'ReadyzGet503Response')
          ..add('status', status))
        .toString();
  }
}

class ReadyzGet503ResponseBuilder
    implements Builder<ReadyzGet503Response, ReadyzGet503ResponseBuilder> {
  _$ReadyzGet503Response? _$v;

  ReadyzGet503ResponseStatusEnum? _status;
  ReadyzGet503ResponseStatusEnum? get status => _$this._status;
  set status(ReadyzGet503ResponseStatusEnum? status) => _$this._status = status;

  ReadyzGet503ResponseBuilder() {
    ReadyzGet503Response._defaults(this);
  }

  ReadyzGet503ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _status = $v.status;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReadyzGet503Response other) {
    _$v = other as _$ReadyzGet503Response;
  }

  @override
  void update(void Function(ReadyzGet503ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReadyzGet503Response build() => _build();

  _$ReadyzGet503Response _build() {
    final _$result = _$v ??
        _$ReadyzGet503Response._(
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'ReadyzGet503Response', 'status'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
