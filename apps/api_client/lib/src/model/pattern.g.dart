// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pattern.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PatternDirectionEnum _$patternDirectionEnum_outbound =
    const PatternDirectionEnum._('outbound');
const PatternDirectionEnum _$patternDirectionEnum_return_ =
    const PatternDirectionEnum._('return_');

PatternDirectionEnum _$patternDirectionEnumValueOf(String name) {
  switch (name) {
    case 'outbound':
      return _$patternDirectionEnum_outbound;
    case 'return_':
      return _$patternDirectionEnum_return_;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PatternDirectionEnum> _$patternDirectionEnumValues =
    BuiltSet<PatternDirectionEnum>(const <PatternDirectionEnum>[
  _$patternDirectionEnum_outbound,
  _$patternDirectionEnum_return_,
]);

Serializer<PatternDirectionEnum> _$patternDirectionEnumSerializer =
    _$PatternDirectionEnumSerializer();

class _$PatternDirectionEnumSerializer
    implements PrimitiveSerializer<PatternDirectionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'outbound': 'outbound',
    'return_': 'return',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'outbound': 'outbound',
    'return': 'return_',
  };

  @override
  final Iterable<Type> types = const <Type>[PatternDirectionEnum];
  @override
  final String wireName = 'PatternDirectionEnum';

  @override
  Object serialize(Serializers serializers, PatternDirectionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PatternDirectionEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PatternDirectionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$Pattern extends Pattern {
  @override
  final String id;
  @override
  final String routeId;
  @override
  final PatternDirectionEnum direction;
  @override
  final String? publishedVersionId;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final int version;

  factory _$Pattern([void Function(PatternBuilder)? updates]) =>
      (PatternBuilder()..update(updates))._build();

  _$Pattern._(
      {required this.id,
      required this.routeId,
      required this.direction,
      this.publishedVersionId,
      required this.createdAt,
      required this.updatedAt,
      required this.version})
      : super._();
  @override
  Pattern rebuild(void Function(PatternBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PatternBuilder toBuilder() => PatternBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Pattern &&
        id == other.id &&
        routeId == other.routeId &&
        direction == other.direction &&
        publishedVersionId == other.publishedVersionId &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        version == other.version;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, routeId.hashCode);
    _$hash = $jc(_$hash, direction.hashCode);
    _$hash = $jc(_$hash, publishedVersionId.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Pattern')
          ..add('id', id)
          ..add('routeId', routeId)
          ..add('direction', direction)
          ..add('publishedVersionId', publishedVersionId)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt)
          ..add('version', version))
        .toString();
  }
}

class PatternBuilder implements Builder<Pattern, PatternBuilder> {
  _$Pattern? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _routeId;
  String? get routeId => _$this._routeId;
  set routeId(String? routeId) => _$this._routeId = routeId;

  PatternDirectionEnum? _direction;
  PatternDirectionEnum? get direction => _$this._direction;
  set direction(PatternDirectionEnum? direction) =>
      _$this._direction = direction;

  String? _publishedVersionId;
  String? get publishedVersionId => _$this._publishedVersionId;
  set publishedVersionId(String? publishedVersionId) =>
      _$this._publishedVersionId = publishedVersionId;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  int? _version;
  int? get version => _$this._version;
  set version(int? version) => _$this._version = version;

  PatternBuilder() {
    Pattern._defaults(this);
  }

  PatternBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _routeId = $v.routeId;
      _direction = $v.direction;
      _publishedVersionId = $v.publishedVersionId;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _version = $v.version;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Pattern other) {
    _$v = other as _$Pattern;
  }

  @override
  void update(void Function(PatternBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Pattern build() => _build();

  _$Pattern _build() {
    final _$result = _$v ??
        _$Pattern._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'Pattern', 'id'),
          routeId: BuiltValueNullFieldError.checkNotNull(
              routeId, r'Pattern', 'routeId'),
          direction: BuiltValueNullFieldError.checkNotNull(
              direction, r'Pattern', 'direction'),
          publishedVersionId: publishedVersionId,
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'Pattern', 'createdAt'),
          updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt, r'Pattern', 'updatedAt'),
          version: BuiltValueNullFieldError.checkNotNull(
              version, r'Pattern', 'version'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
