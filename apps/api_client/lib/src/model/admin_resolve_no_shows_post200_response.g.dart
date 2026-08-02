// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_resolve_no_shows_post200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminResolveNoShowsPost200Response
    extends AdminResolveNoShowsPost200Response {
  @override
  final int noShows;

  factory _$AdminResolveNoShowsPost200Response(
          [void Function(AdminResolveNoShowsPost200ResponseBuilder)?
              updates]) =>
      (AdminResolveNoShowsPost200ResponseBuilder()..update(updates))._build();

  _$AdminResolveNoShowsPost200Response._({required this.noShows}) : super._();
  @override
  AdminResolveNoShowsPost200Response rebuild(
          void Function(AdminResolveNoShowsPost200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminResolveNoShowsPost200ResponseBuilder toBuilder() =>
      AdminResolveNoShowsPost200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminResolveNoShowsPost200Response &&
        noShows == other.noShows;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, noShows.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminResolveNoShowsPost200Response')
          ..add('noShows', noShows))
        .toString();
  }
}

class AdminResolveNoShowsPost200ResponseBuilder
    implements
        Builder<AdminResolveNoShowsPost200Response,
            AdminResolveNoShowsPost200ResponseBuilder> {
  _$AdminResolveNoShowsPost200Response? _$v;

  int? _noShows;
  int? get noShows => _$this._noShows;
  set noShows(int? noShows) => _$this._noShows = noShows;

  AdminResolveNoShowsPost200ResponseBuilder() {
    AdminResolveNoShowsPost200Response._defaults(this);
  }

  AdminResolveNoShowsPost200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _noShows = $v.noShows;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminResolveNoShowsPost200Response other) {
    _$v = other as _$AdminResolveNoShowsPost200Response;
  }

  @override
  void update(
      void Function(AdminResolveNoShowsPost200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminResolveNoShowsPost200Response build() => _build();

  _$AdminResolveNoShowsPost200Response _build() {
    final _$result = _$v ??
        _$AdminResolveNoShowsPost200Response._(
          noShows: BuiltValueNullFieldError.checkNotNull(
              noShows, r'AdminResolveNoShowsPost200Response', 'noShows'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
