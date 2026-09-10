// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flags_get200_response_map_tiles.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$FlagsGet200ResponseMapTiles extends FlagsGet200ResponseMapTiles {
  @override
  final String? url;
  @override
  final String? styleUrl;
  @override
  final String? darkStyleUrl;
  @override
  final String attribution;

  factory _$FlagsGet200ResponseMapTiles(
          [void Function(FlagsGet200ResponseMapTilesBuilder)? updates]) =>
      (FlagsGet200ResponseMapTilesBuilder()..update(updates))._build();

  _$FlagsGet200ResponseMapTiles._(
      {this.url, this.styleUrl, this.darkStyleUrl, required this.attribution})
      : super._();
  @override
  FlagsGet200ResponseMapTiles rebuild(
          void Function(FlagsGet200ResponseMapTilesBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FlagsGet200ResponseMapTilesBuilder toBuilder() =>
      FlagsGet200ResponseMapTilesBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FlagsGet200ResponseMapTiles &&
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
    return (newBuiltValueToStringHelper(r'FlagsGet200ResponseMapTiles')
          ..add('url', url)
          ..add('styleUrl', styleUrl)
          ..add('darkStyleUrl', darkStyleUrl)
          ..add('attribution', attribution))
        .toString();
  }
}

class FlagsGet200ResponseMapTilesBuilder
    implements
        Builder<FlagsGet200ResponseMapTiles,
            FlagsGet200ResponseMapTilesBuilder> {
  _$FlagsGet200ResponseMapTiles? _$v;

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

  FlagsGet200ResponseMapTilesBuilder() {
    FlagsGet200ResponseMapTiles._defaults(this);
  }

  FlagsGet200ResponseMapTilesBuilder get _$this {
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
  void replace(FlagsGet200ResponseMapTiles other) {
    _$v = other as _$FlagsGet200ResponseMapTiles;
  }

  @override
  void update(void Function(FlagsGet200ResponseMapTilesBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FlagsGet200ResponseMapTiles build() => _build();

  _$FlagsGet200ResponseMapTiles _build() {
    final _$result = _$v ??
        _$FlagsGet200ResponseMapTiles._(
          url: url,
          styleUrl: styleUrl,
          darkStyleUrl: darkStyleUrl,
          attribution: BuiltValueNullFieldError.checkNotNull(
              attribution, r'FlagsGet200ResponseMapTiles', 'attribution'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
