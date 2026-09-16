// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pattern_version.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PatternVersionStateEnum _$patternVersionStateEnum_draft =
    const PatternVersionStateEnum._('draft');
const PatternVersionStateEnum _$patternVersionStateEnum_published =
    const PatternVersionStateEnum._('published');
const PatternVersionStateEnum _$patternVersionStateEnum_retired =
    const PatternVersionStateEnum._('retired');

PatternVersionStateEnum _$patternVersionStateEnumValueOf(String name) {
  switch (name) {
    case 'draft':
      return _$patternVersionStateEnum_draft;
    case 'published':
      return _$patternVersionStateEnum_published;
    case 'retired':
      return _$patternVersionStateEnum_retired;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PatternVersionStateEnum> _$patternVersionStateEnumValues =
    BuiltSet<PatternVersionStateEnum>(const <PatternVersionStateEnum>[
  _$patternVersionStateEnum_draft,
  _$patternVersionStateEnum_published,
  _$patternVersionStateEnum_retired,
]);

Serializer<PatternVersionStateEnum> _$patternVersionStateEnumSerializer =
    _$PatternVersionStateEnumSerializer();

class _$PatternVersionStateEnumSerializer
    implements PrimitiveSerializer<PatternVersionStateEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'draft': 'draft',
    'published': 'published',
    'retired': 'retired',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'draft': 'draft',
    'published': 'published',
    'retired': 'retired',
  };

  @override
  final Iterable<Type> types = const <Type>[PatternVersionStateEnum];
  @override
  final String wireName = 'PatternVersionStateEnum';

  @override
  Object serialize(Serializers serializers, PatternVersionStateEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PatternVersionStateEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PatternVersionStateEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PatternVersion extends PatternVersion {
  @override
  final String id;
  @override
  final String patternId;
  @override
  final int revision;
  @override
  final PatternVersionStateEnum state;
  @override
  final DateTime? effectiveFrom;
  @override
  final DateTime? effectiveTo;
  @override
  final BuiltList<StopOccurrence> stops;
  @override
  final String? geometryId;
  @override
  final String editToken;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final int version;

  factory _$PatternVersion([void Function(PatternVersionBuilder)? updates]) =>
      (PatternVersionBuilder()..update(updates))._build();

  _$PatternVersion._(
      {required this.id,
      required this.patternId,
      required this.revision,
      required this.state,
      this.effectiveFrom,
      this.effectiveTo,
      required this.stops,
      this.geometryId,
      required this.editToken,
      required this.createdAt,
      required this.updatedAt,
      required this.version})
      : super._();
  @override
  PatternVersion rebuild(void Function(PatternVersionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PatternVersionBuilder toBuilder() => PatternVersionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PatternVersion &&
        id == other.id &&
        patternId == other.patternId &&
        revision == other.revision &&
        state == other.state &&
        effectiveFrom == other.effectiveFrom &&
        effectiveTo == other.effectiveTo &&
        stops == other.stops &&
        geometryId == other.geometryId &&
        editToken == other.editToken &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        version == other.version;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, patternId.hashCode);
    _$hash = $jc(_$hash, revision.hashCode);
    _$hash = $jc(_$hash, state.hashCode);
    _$hash = $jc(_$hash, effectiveFrom.hashCode);
    _$hash = $jc(_$hash, effectiveTo.hashCode);
    _$hash = $jc(_$hash, stops.hashCode);
    _$hash = $jc(_$hash, geometryId.hashCode);
    _$hash = $jc(_$hash, editToken.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PatternVersion')
          ..add('id', id)
          ..add('patternId', patternId)
          ..add('revision', revision)
          ..add('state', state)
          ..add('effectiveFrom', effectiveFrom)
          ..add('effectiveTo', effectiveTo)
          ..add('stops', stops)
          ..add('geometryId', geometryId)
          ..add('editToken', editToken)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt)
          ..add('version', version))
        .toString();
  }
}

class PatternVersionBuilder
    implements Builder<PatternVersion, PatternVersionBuilder> {
  _$PatternVersion? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _patternId;
  String? get patternId => _$this._patternId;
  set patternId(String? patternId) => _$this._patternId = patternId;

  int? _revision;
  int? get revision => _$this._revision;
  set revision(int? revision) => _$this._revision = revision;

  PatternVersionStateEnum? _state;
  PatternVersionStateEnum? get state => _$this._state;
  set state(PatternVersionStateEnum? state) => _$this._state = state;

  DateTime? _effectiveFrom;
  DateTime? get effectiveFrom => _$this._effectiveFrom;
  set effectiveFrom(DateTime? effectiveFrom) =>
      _$this._effectiveFrom = effectiveFrom;

  DateTime? _effectiveTo;
  DateTime? get effectiveTo => _$this._effectiveTo;
  set effectiveTo(DateTime? effectiveTo) => _$this._effectiveTo = effectiveTo;

  ListBuilder<StopOccurrence>? _stops;
  ListBuilder<StopOccurrence> get stops =>
      _$this._stops ??= ListBuilder<StopOccurrence>();
  set stops(ListBuilder<StopOccurrence>? stops) => _$this._stops = stops;

  String? _geometryId;
  String? get geometryId => _$this._geometryId;
  set geometryId(String? geometryId) => _$this._geometryId = geometryId;

  String? _editToken;
  String? get editToken => _$this._editToken;
  set editToken(String? editToken) => _$this._editToken = editToken;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  int? _version;
  int? get version => _$this._version;
  set version(int? version) => _$this._version = version;

  PatternVersionBuilder() {
    PatternVersion._defaults(this);
  }

  PatternVersionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _patternId = $v.patternId;
      _revision = $v.revision;
      _state = $v.state;
      _effectiveFrom = $v.effectiveFrom;
      _effectiveTo = $v.effectiveTo;
      _stops = $v.stops.toBuilder();
      _geometryId = $v.geometryId;
      _editToken = $v.editToken;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _version = $v.version;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PatternVersion other) {
    _$v = other as _$PatternVersion;
  }

  @override
  void update(void Function(PatternVersionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PatternVersion build() => _build();

  _$PatternVersion _build() {
    _$PatternVersion _$result;
    try {
      _$result = _$v ??
          _$PatternVersion._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'PatternVersion', 'id'),
            patternId: BuiltValueNullFieldError.checkNotNull(
                patternId, r'PatternVersion', 'patternId'),
            revision: BuiltValueNullFieldError.checkNotNull(
                revision, r'PatternVersion', 'revision'),
            state: BuiltValueNullFieldError.checkNotNull(
                state, r'PatternVersion', 'state'),
            effectiveFrom: effectiveFrom,
            effectiveTo: effectiveTo,
            stops: stops.build(),
            geometryId: geometryId,
            editToken: BuiltValueNullFieldError.checkNotNull(
                editToken, r'PatternVersion', 'editToken'),
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'PatternVersion', 'createdAt'),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
                updatedAt, r'PatternVersion', 'updatedAt'),
            version: BuiltValueNullFieldError.checkNotNull(
                version, r'PatternVersion', 'version'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'stops';
        stops.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PatternVersion', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
