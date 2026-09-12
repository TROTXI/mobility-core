// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'me_work_requests_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MeWorkRequestsPostRequestKindEnum
    _$meWorkRequestsPostRequestKindEnum_leave =
    const MeWorkRequestsPostRequestKindEnum._('leave');

MeWorkRequestsPostRequestKindEnum _$meWorkRequestsPostRequestKindEnumValueOf(
    String name) {
  switch (name) {
    case 'leave':
      return _$meWorkRequestsPostRequestKindEnum_leave;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<MeWorkRequestsPostRequestKindEnum>
    _$meWorkRequestsPostRequestKindEnumValues = BuiltSet<
        MeWorkRequestsPostRequestKindEnum>(const <MeWorkRequestsPostRequestKindEnum>[
  _$meWorkRequestsPostRequestKindEnum_leave,
]);

Serializer<MeWorkRequestsPostRequestKindEnum>
    _$meWorkRequestsPostRequestKindEnumSerializer =
    _$MeWorkRequestsPostRequestKindEnumSerializer();

class _$MeWorkRequestsPostRequestKindEnumSerializer
    implements PrimitiveSerializer<MeWorkRequestsPostRequestKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'leave': 'leave',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'leave': 'leave',
  };

  @override
  final Iterable<Type> types = const <Type>[MeWorkRequestsPostRequestKindEnum];
  @override
  final String wireName = 'MeWorkRequestsPostRequestKindEnum';

  @override
  Object serialize(
          Serializers serializers, MeWorkRequestsPostRequestKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  MeWorkRequestsPostRequestKindEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      MeWorkRequestsPostRequestKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$MeWorkRequestsPostRequest extends MeWorkRequestsPostRequest {
  @override
  final OneOf oneOf;

  factory _$MeWorkRequestsPostRequest(
          [void Function(MeWorkRequestsPostRequestBuilder)? updates]) =>
      (MeWorkRequestsPostRequestBuilder()..update(updates))._build();

  _$MeWorkRequestsPostRequest._({required this.oneOf}) : super._();
  @override
  MeWorkRequestsPostRequest rebuild(
          void Function(MeWorkRequestsPostRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MeWorkRequestsPostRequestBuilder toBuilder() =>
      MeWorkRequestsPostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MeWorkRequestsPostRequest && oneOf == other.oneOf;
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
    return (newBuiltValueToStringHelper(r'MeWorkRequestsPostRequest')
          ..add('oneOf', oneOf))
        .toString();
  }
}

class MeWorkRequestsPostRequestBuilder
    implements
        Builder<MeWorkRequestsPostRequest, MeWorkRequestsPostRequestBuilder> {
  _$MeWorkRequestsPostRequest? _$v;

  OneOf? _oneOf;
  OneOf? get oneOf => _$this._oneOf;
  set oneOf(OneOf? oneOf) => _$this._oneOf = oneOf;

  MeWorkRequestsPostRequestBuilder() {
    MeWorkRequestsPostRequest._defaults(this);
  }

  MeWorkRequestsPostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _oneOf = $v.oneOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MeWorkRequestsPostRequest other) {
    _$v = other as _$MeWorkRequestsPostRequest;
  }

  @override
  void update(void Function(MeWorkRequestsPostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MeWorkRequestsPostRequest build() => _build();

  _$MeWorkRequestsPostRequest _build() {
    final _$result = _$v ??
        _$MeWorkRequestsPostRequest._(
          oneOf: BuiltValueNullFieldError.checkNotNull(
              oneOf, r'MeWorkRequestsPostRequest', 'oneOf'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
