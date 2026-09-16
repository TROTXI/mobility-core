// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bootstrap_map_tiles.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BootstrapMapTiles extends BootstrapMapTiles {
  @override
  final String? url;
  @override
  final String? styleUrl;
  @override
  final String? darkStyleUrl;
  @override
  final String attribution;

  factory _$BootstrapMapTiles(
          [void Function(BootstrapMapTilesBuilder)? updates]) =>
      (BootstrapMapTilesBuilder()..update(updates))._build();

  _$BootstrapMapTiles._(
      {this.url, this.styleUrl, this.darkStyleUrl, required this.attribution})
      : super._();
  @override
  BootstrapMapTiles rebuild(void Function(BootstrapMapTilesBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BootstrapMapTilesBuilder toBuilder() =>
      BootstrapMapTilesBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BootstrapMapTiles &&
        url == other.url &&
        styleUrl == other.styleUrl &&
        darkStyleUrl == other.darkStyleUrl &&
        attribution == other.attribution;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, url.hashCode);
    _$hash = $jc(_$hash, styleUrl.hashCode);
    _$hash = $jc(_$hash, darkStyleUrl.hashCode);
    _$hash = $jc(_$hash, attribution.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BootstrapMapTiles')
          ..add('url', url)
          ..add('styleUrl', styleUrl)
          ..add('darkStyleUrl', darkStyleUrl)
          ..add('attribution', attribution))
        .toString();
  }
}

class BootstrapMapTilesBuilder
    implements Builder<BootstrapMapTiles, BootstrapMapTilesBuilder> {
  _$BootstrapMapTiles? _$v;

  String? _url;
  String? get url => _$this._url;
  set url(String? url) => _$this._url = url;

  String? _styleUrl;
  String? get styleUrl => _$this._styleUrl;
  set styleUrl(String? styleUrl) => _$this._styleUrl = styleUrl;

  String? _darkStyleUrl;
  String? get darkStyleUrl => _$this._darkStyleUrl;
  set darkStyleUrl(String? darkStyleUrl) => _$this._darkStyleUrl = darkStyleUrl;

  String? _attribution;
  String? get attribution => _$this._attribution;
  set attribution(String? attribution) => _$this._attribution = attribution;

  BootstrapMapTilesBuilder() {
    BootstrapMapTiles._defaults(this);
  }

  BootstrapMapTilesBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _url = $v.url;
      _styleUrl = $v.styleUrl;
      _darkStyleUrl = $v.darkStyleUrl;
      _attribution = $v.attribution;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BootstrapMapTiles other) {
    _$v = other as _$BootstrapMapTiles;
  }

  @override
  void update(void Function(BootstrapMapTilesBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BootstrapMapTiles build() => _build();

  _$BootstrapMapTiles _build() {
    final _$result = _$v ??
        _$BootstrapMapTiles._(
          url: url,
          styleUrl: styleUrl,
          darkStyleUrl: darkStyleUrl,
          attribution: BuiltValueNullFieldError.checkNotNull(
              attribution, r'BootstrapMapTiles', 'attribution'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
