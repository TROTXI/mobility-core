// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_ask_dispatch_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminAskDispatchPostRequestDirectionEnum
    _$adminAskDispatchPostRequestDirectionEnum_morning =
    const AdminAskDispatchPostRequestDirectionEnum._('morning');
const AdminAskDispatchPostRequestDirectionEnum
    _$adminAskDispatchPostRequestDirectionEnum_evening =
    const AdminAskDispatchPostRequestDirectionEnum._('evening');

AdminAskDispatchPostRequestDirectionEnum
    _$adminAskDispatchPostRequestDirectionEnumValueOf(String name) {
  switch (name) {
    case 'morning':
      return _$adminAskDispatchPostRequestDirectionEnum_morning;
    case 'evening':
      return _$adminAskDispatchPostRequestDirectionEnum_evening;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<AdminAskDispatchPostRequestDirectionEnum>
    _$adminAskDispatchPostRequestDirectionEnumValues = BuiltSet<
        AdminAskDispatchPostRequestDirectionEnum>(const <AdminAskDispatchPostRequestDirectionEnum>[
  _$adminAskDispatchPostRequestDirectionEnum_morning,
  _$adminAskDispatchPostRequestDirectionEnum_evening,
]);

Serializer<AdminAskDispatchPostRequestDirectionEnum>
    _$adminAskDispatchPostRequestDirectionEnumSerializer =
    _$AdminAskDispatchPostRequestDirectionEnumSerializer();

class _$AdminAskDispatchPostRequestDirectionEnumSerializer
    implements PrimitiveSerializer<AdminAskDispatchPostRequestDirectionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'morning': 'morning',
    'evening': 'evening',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'morning': 'morning',
    'evening': 'evening',
  };

  @override
  final Iterable<Type> types = const <Type>[
    AdminAskDispatchPostRequestDirectionEnum
  ];
  @override
  final String wireName = 'AdminAskDispatchPostRequestDirectionEnum';

  @override
  Object serialize(Serializers serializers,
          AdminAskDispatchPostRequestDirectionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  AdminAskDispatchPostRequestDirectionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      AdminAskDispatchPostRequestDirectionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$AdminAskDispatchPostRequest extends AdminAskDispatchPostRequest {
  @override
  final String travelDate;
  @override
  final AdminAskDispatchPostRequestDirectionEnum direction;

  factory _$AdminAskDispatchPostRequest(
          [void Function(AdminAskDispatchPostRequestBuilder)? updates]) =>
      (AdminAskDispatchPostRequestBuilder()..update(updates))._build();

  _$AdminAskDispatchPostRequest._(
      {required this.travelDate, required this.direction})
      : super._();
  @override
  AdminAskDispatchPostRequest rebuild(
          void Function(AdminAskDispatchPostRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminAskDispatchPostRequestBuilder toBuilder() =>
      AdminAskDispatchPostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminAskDispatchPostRequest &&
        travelDate == other.travelDate &&
        direction == other.direction;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, travelDate.hashCode);
    _$hash = $jc(_$hash, direction.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminAskDispatchPostRequest')
          ..add('travelDate', travelDate)
          ..add('direction', direction))
        .toString();
  }
}

class AdminAskDispatchPostRequestBuilder
    implements
        Builder<AdminAskDispatchPostRequest,
            AdminAskDispatchPostRequestBuilder> {
  _$AdminAskDispatchPostRequest? _$v;

  String? _travelDate;
  String? get travelDate => _$this._travelDate;
  set travelDate(String? travelDate) => _$this._travelDate = travelDate;

  AdminAskDispatchPostRequestDirectionEnum? _direction;
  AdminAskDispatchPostRequestDirectionEnum? get direction => _$this._direction;
  set direction(AdminAskDispatchPostRequestDirectionEnum? direction) =>
      _$this._direction = direction;

  AdminAskDispatchPostRequestBuilder() {
    AdminAskDispatchPostRequest._defaults(this);
  }

  AdminAskDispatchPostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _travelDate = $v.travelDate;
      _direction = $v.direction;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminAskDispatchPostRequest other) {
    _$v = other as _$AdminAskDispatchPostRequest;
  }

  @override
  void update(void Function(AdminAskDispatchPostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminAskDispatchPostRequest build() => _build();

  _$AdminAskDispatchPostRequest _build() {
    final _$result = _$v ??
        _$AdminAskDispatchPostRequest._(
          travelDate: BuiltValueNullFieldError.checkNotNull(
              travelDate, r'AdminAskDispatchPostRequest', 'travelDate'),
          direction: BuiltValueNullFieldError.checkNotNull(
              direction, r'AdminAskDispatchPostRequest', 'direction'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
