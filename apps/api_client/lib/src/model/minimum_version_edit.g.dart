// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'minimum_version_edit.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MinimumVersionEditApiMajorEnum _$minimumVersionEditApiMajorEnum_number1 =
    const MinimumVersionEditApiMajorEnum._('number1');

MinimumVersionEditApiMajorEnum _$minimumVersionEditApiMajorEnumValueOf(
    String name) {
  switch (name) {
    case 'number1':
      return _$minimumVersionEditApiMajorEnum_number1;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<MinimumVersionEditApiMajorEnum>
    _$minimumVersionEditApiMajorEnumValues = BuiltSet<
        MinimumVersionEditApiMajorEnum>(const <MinimumVersionEditApiMajorEnum>[
  _$minimumVersionEditApiMajorEnum_number1,
]);

Serializer<MinimumVersionEditApiMajorEnum>
    _$minimumVersionEditApiMajorEnumSerializer =
    _$MinimumVersionEditApiMajorEnumSerializer();

class _$MinimumVersionEditApiMajorEnumSerializer
    implements PrimitiveSerializer<MinimumVersionEditApiMajorEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number1': 1,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    1: 'number1',
  };

  @override
  final Iterable<Type> types = const <Type>[MinimumVersionEditApiMajorEnum];
  @override
  final String wireName = 'MinimumVersionEditApiMajorEnum';

  @override
  Object serialize(
          Serializers serializers, MinimumVersionEditApiMajorEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  MinimumVersionEditApiMajorEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      MinimumVersionEditApiMajorEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$MinimumVersionEdit extends MinimumVersionEdit {
  @override
  final int minSupportedBuild;
  @override
  final MinimumVersionEditApiMajorEnum apiMajor;
  @override
  final String storeUrl;

  factory _$MinimumVersionEdit(
          [void Function(MinimumVersionEditBuilder)? updates]) =>
      (MinimumVersionEditBuilder()..update(updates))._build();

  _$MinimumVersionEdit._(
      {required this.minSupportedBuild,
      required this.apiMajor,
      required this.storeUrl})
      : super._();
  @override
  MinimumVersionEdit rebuild(
          void Function(MinimumVersionEditBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MinimumVersionEditBuilder toBuilder() =>
      MinimumVersionEditBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MinimumVersionEdit &&
        minSupportedBuild == other.minSupportedBuild &&
        apiMajor == other.apiMajor &&
        storeUrl == other.storeUrl;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, minSupportedBuild.hashCode);
    _$hash = $jc(_$hash, apiMajor.hashCode);
    _$hash = $jc(_$hash, storeUrl.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MinimumVersionEdit')
          ..add('minSupportedBuild', minSupportedBuild)
          ..add('apiMajor', apiMajor)
          ..add('storeUrl', storeUrl))
        .toString();
  }
}

class MinimumVersionEditBuilder
    implements Builder<MinimumVersionEdit, MinimumVersionEditBuilder> {
  _$MinimumVersionEdit? _$v;

  int? _minSupportedBuild;
  int? get minSupportedBuild => _$this._minSupportedBuild;
  set minSupportedBuild(int? minSupportedBuild) =>
      _$this._minSupportedBuild = minSupportedBuild;

  MinimumVersionEditApiMajorEnum? _apiMajor;
  MinimumVersionEditApiMajorEnum? get apiMajor => _$this._apiMajor;
  set apiMajor(MinimumVersionEditApiMajorEnum? apiMajor) =>
      _$this._apiMajor = apiMajor;

  String? _storeUrl;
  String? get storeUrl => _$this._storeUrl;
  set storeUrl(String? storeUrl) => _$this._storeUrl = storeUrl;

  MinimumVersionEditBuilder() {
    MinimumVersionEdit._defaults(this);
  }

  MinimumVersionEditBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _minSupportedBuild = $v.minSupportedBuild;
      _apiMajor = $v.apiMajor;
      _storeUrl = $v.storeUrl;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MinimumVersionEdit other) {
    _$v = other as _$MinimumVersionEdit;
  }

  @override
  void update(void Function(MinimumVersionEditBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MinimumVersionEdit build() => _build();

  _$MinimumVersionEdit _build() {
    final _$result = _$v ??
        _$MinimumVersionEdit._(
          minSupportedBuild: BuiltValueNullFieldError.checkNotNull(
              minSupportedBuild, r'MinimumVersionEdit', 'minSupportedBuild'),
          apiMajor: BuiltValueNullFieldError.checkNotNull(
              apiMajor, r'MinimumVersionEdit', 'apiMajor'),
          storeUrl: BuiltValueNullFieldError.checkNotNull(
              storeUrl, r'MinimumVersionEdit', 'storeUrl'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
