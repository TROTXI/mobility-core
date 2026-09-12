// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_learn_routes_post200_response_routes_inner_segments_learned.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminLearnRoutesPost200ResponseRoutesInnerSegmentsLearned
    extends AdminLearnRoutesPost200ResponseRoutesInnerSegmentsLearned {
  @override
  final int morning;
  @override
  final int evening;

  factory _$AdminLearnRoutesPost200ResponseRoutesInnerSegmentsLearned(
          [void Function(
                  AdminLearnRoutesPost200ResponseRoutesInnerSegmentsLearnedBuilder)?
              updates]) =>
      (AdminLearnRoutesPost200ResponseRoutesInnerSegmentsLearnedBuilder()
            ..update(updates))
          ._build();

  _$AdminLearnRoutesPost200ResponseRoutesInnerSegmentsLearned._(
      {required this.morning, required this.evening})
      : super._();
  @override
  AdminLearnRoutesPost200ResponseRoutesInnerSegmentsLearned rebuild(
          void Function(
                  AdminLearnRoutesPost200ResponseRoutesInnerSegmentsLearnedBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminLearnRoutesPost200ResponseRoutesInnerSegmentsLearnedBuilder
      toBuilder() =>
          AdminLearnRoutesPost200ResponseRoutesInnerSegmentsLearnedBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminLearnRoutesPost200ResponseRoutesInnerSegmentsLearned &&
        morning == other.morning &&
        evening == other.evening;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, morning.hashCode);
    _$hash = $jc(_$hash, evening.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'AdminLearnRoutesPost200ResponseRoutesInnerSegmentsLearned')
          ..add('morning', morning)
          ..add('evening', evening))
        .toString();
  }
}

class AdminLearnRoutesPost200ResponseRoutesInnerSegmentsLearnedBuilder
    implements
        Builder<AdminLearnRoutesPost200ResponseRoutesInnerSegmentsLearned,
            AdminLearnRoutesPost200ResponseRoutesInnerSegmentsLearnedBuilder> {
  _$AdminLearnRoutesPost200ResponseRoutesInnerSegmentsLearned? _$v;

  int? _morning;
  int? get morning => _$this._morning;
  set morning(int? morning) => _$this._morning = morning;

  int? _evening;
  int? get evening => _$this._evening;
  set evening(int? evening) => _$this._evening = evening;

  AdminLearnRoutesPost200ResponseRoutesInnerSegmentsLearnedBuilder() {
    AdminLearnRoutesPost200ResponseRoutesInnerSegmentsLearned._defaults(this);
  }

  AdminLearnRoutesPost200ResponseRoutesInnerSegmentsLearnedBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _morning = $v.morning;
      _evening = $v.evening;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      AdminLearnRoutesPost200ResponseRoutesInnerSegmentsLearned other) {
    _$v = other as _$AdminLearnRoutesPost200ResponseRoutesInnerSegmentsLearned;
  }

  @override
  void update(
      void Function(
              AdminLearnRoutesPost200ResponseRoutesInnerSegmentsLearnedBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminLearnRoutesPost200ResponseRoutesInnerSegmentsLearned build() => _build();

  _$AdminLearnRoutesPost200ResponseRoutesInnerSegmentsLearned _build() {
    final _$result = _$v ??
        _$AdminLearnRoutesPost200ResponseRoutesInnerSegmentsLearned._(
          morning: BuiltValueNullFieldError.checkNotNull(
              morning,
              r'AdminLearnRoutesPost200ResponseRoutesInnerSegmentsLearned',
              'morning'),
          evening: BuiltValueNullFieldError.checkNotNull(
              evening,
              r'AdminLearnRoutesPost200ResponseRoutesInnerSegmentsLearned',
              'evening'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
