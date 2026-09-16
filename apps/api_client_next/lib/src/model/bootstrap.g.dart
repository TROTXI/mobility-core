// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bootstrap.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Bootstrap extends Bootstrap {
  @override
  final DateTime serverTime;
  @override
  final BuiltList<BootstrapApplicationsInner> applications;
  @override
  final BootstrapOperations operations;
  @override
  final BootstrapMapTiles mapTiles;
  @override
  final BuiltList<BootstrapFlagsInner> flags;

  factory _$Bootstrap([void Function(BootstrapBuilder)? updates]) =>
      (BootstrapBuilder()..update(updates))._build();

  _$Bootstrap._(
      {required this.serverTime,
      required this.applications,
      required this.operations,
      required this.mapTiles,
      required this.flags})
      : super._();
  @override
  Bootstrap rebuild(void Function(BootstrapBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BootstrapBuilder toBuilder() => BootstrapBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Bootstrap &&
        serverTime == other.serverTime &&
        applications == other.applications &&
        operations == other.operations &&
        mapTiles == other.mapTiles &&
        flags == other.flags;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, serverTime.hashCode);
    _$hash = $jc(_$hash, applications.hashCode);
    _$hash = $jc(_$hash, operations.hashCode);
    _$hash = $jc(_$hash, mapTiles.hashCode);
    _$hash = $jc(_$hash, flags.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Bootstrap')
          ..add('serverTime', serverTime)
          ..add('applications', applications)
          ..add('operations', operations)
          ..add('mapTiles', mapTiles)
          ..add('flags', flags))
        .toString();
  }
}

class BootstrapBuilder implements Builder<Bootstrap, BootstrapBuilder> {
  _$Bootstrap? _$v;

  DateTime? _serverTime;
  DateTime? get serverTime => _$this._serverTime;
  set serverTime(DateTime? serverTime) => _$this._serverTime = serverTime;

  ListBuilder<BootstrapApplicationsInner>? _applications;
  ListBuilder<BootstrapApplicationsInner> get applications =>
      _$this._applications ??= ListBuilder<BootstrapApplicationsInner>();
  set applications(ListBuilder<BootstrapApplicationsInner>? applications) =>
      _$this._applications = applications;

  BootstrapOperationsBuilder? _operations;
  BootstrapOperationsBuilder get operations =>
      _$this._operations ??= BootstrapOperationsBuilder();
  set operations(BootstrapOperationsBuilder? operations) =>
      _$this._operations = operations;

  BootstrapMapTilesBuilder? _mapTiles;
  BootstrapMapTilesBuilder get mapTiles =>
      _$this._mapTiles ??= BootstrapMapTilesBuilder();
  set mapTiles(BootstrapMapTilesBuilder? mapTiles) =>
      _$this._mapTiles = mapTiles;

  ListBuilder<BootstrapFlagsInner>? _flags;
  ListBuilder<BootstrapFlagsInner> get flags =>
      _$this._flags ??= ListBuilder<BootstrapFlagsInner>();
  set flags(ListBuilder<BootstrapFlagsInner>? flags) => _$this._flags = flags;

  BootstrapBuilder() {
    Bootstrap._defaults(this);
  }

  BootstrapBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _serverTime = $v.serverTime;
      _applications = $v.applications.toBuilder();
      _operations = $v.operations.toBuilder();
      _mapTiles = $v.mapTiles.toBuilder();
      _flags = $v.flags.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Bootstrap other) {
    _$v = other as _$Bootstrap;
  }

  @override
  void update(void Function(BootstrapBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Bootstrap build() => _build();

  _$Bootstrap _build() {
    _$Bootstrap _$result;
    try {
      _$result = _$v ??
          _$Bootstrap._(
            serverTime: BuiltValueNullFieldError.checkNotNull(
                serverTime, r'Bootstrap', 'serverTime'),
            applications: applications.build(),
            operations: operations.build(),
            mapTiles: mapTiles.build(),
            flags: flags.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'applications';
        applications.build();
        _$failedField = 'operations';
        operations.build();
        _$failedField = 'mapTiles';
        mapTiles.build();
        _$failedField = 'flags';
        flags.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'Bootstrap', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
