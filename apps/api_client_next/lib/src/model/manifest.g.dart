// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manifest.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Manifest extends Manifest {
  @override
  final String tripId;
  @override
  final String revision;
  @override
  final DateTime generatedAt;
  @override
  final DateTime expiresAt;
  @override
  final bool complete;
  @override
  final BuiltList<ManifestRider> riders;

  factory _$Manifest([void Function(ManifestBuilder)? updates]) =>
      (ManifestBuilder()..update(updates))._build();

  _$Manifest._(
      {required this.tripId,
      required this.revision,
      required this.generatedAt,
      required this.expiresAt,
      required this.complete,
      required this.riders})
      : super._();
  @override
  Manifest rebuild(void Function(ManifestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ManifestBuilder toBuilder() => ManifestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Manifest &&
        tripId == other.tripId &&
        revision == other.revision &&
        generatedAt == other.generatedAt &&
        expiresAt == other.expiresAt &&
        complete == other.complete &&
        riders == other.riders;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, tripId.hashCode);
    _$hash = $jc(_$hash, revision.hashCode);
    _$hash = $jc(_$hash, generatedAt.hashCode);
    _$hash = $jc(_$hash, expiresAt.hashCode);
    _$hash = $jc(_$hash, complete.hashCode);
    _$hash = $jc(_$hash, riders.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Manifest')
          ..add('tripId', tripId)
          ..add('revision', revision)
          ..add('generatedAt', generatedAt)
          ..add('expiresAt', expiresAt)
          ..add('complete', complete)
          ..add('riders', riders))
        .toString();
  }
}

class ManifestBuilder implements Builder<Manifest, ManifestBuilder> {
  _$Manifest? _$v;

  String? _tripId;
  String? get tripId => _$this._tripId;
  set tripId(String? tripId) => _$this._tripId = tripId;

  String? _revision;
  String? get revision => _$this._revision;
  set revision(String? revision) => _$this._revision = revision;

  DateTime? _generatedAt;
  DateTime? get generatedAt => _$this._generatedAt;
  set generatedAt(DateTime? generatedAt) => _$this._generatedAt = generatedAt;

  DateTime? _expiresAt;
  DateTime? get expiresAt => _$this._expiresAt;
  set expiresAt(DateTime? expiresAt) => _$this._expiresAt = expiresAt;

  bool? _complete;
  bool? get complete => _$this._complete;
  set complete(bool? complete) => _$this._complete = complete;

  ListBuilder<ManifestRider>? _riders;
  ListBuilder<ManifestRider> get riders =>
      _$this._riders ??= ListBuilder<ManifestRider>();
  set riders(ListBuilder<ManifestRider>? riders) => _$this._riders = riders;

  ManifestBuilder() {
    Manifest._defaults(this);
  }

  ManifestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _tripId = $v.tripId;
      _revision = $v.revision;
      _generatedAt = $v.generatedAt;
      _expiresAt = $v.expiresAt;
      _complete = $v.complete;
      _riders = $v.riders.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Manifest other) {
    _$v = other as _$Manifest;
  }

  @override
  void update(void Function(ManifestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Manifest build() => _build();

  _$Manifest _build() {
    _$Manifest _$result;
    try {
      _$result = _$v ??
          _$Manifest._(
            tripId: BuiltValueNullFieldError.checkNotNull(
                tripId, r'Manifest', 'tripId'),
            revision: BuiltValueNullFieldError.checkNotNull(
                revision, r'Manifest', 'revision'),
            generatedAt: BuiltValueNullFieldError.checkNotNull(
                generatedAt, r'Manifest', 'generatedAt'),
            expiresAt: BuiltValueNullFieldError.checkNotNull(
                expiresAt, r'Manifest', 'expiresAt'),
            complete: BuiltValueNullFieldError.checkNotNull(
                complete, r'Manifest', 'complete'),
            riders: riders.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'riders';
        riders.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'Manifest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
