// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'personal_pause_preview.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PersonalPausePreview extends PersonalPausePreview {
  @override
  final Date startDate;
  @override
  final Date resumeDate;
  @override
  final DateTime projectedEndsAt;
  @override
  final BuiltList<String> cancelledReservationIds;

  factory _$PersonalPausePreview(
          [void Function(PersonalPausePreviewBuilder)? updates]) =>
      (PersonalPausePreviewBuilder()..update(updates))._build();

  _$PersonalPausePreview._(
      {required this.startDate,
      required this.resumeDate,
      required this.projectedEndsAt,
      required this.cancelledReservationIds})
      : super._();
  @override
  PersonalPausePreview rebuild(
          void Function(PersonalPausePreviewBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PersonalPausePreviewBuilder toBuilder() =>
      PersonalPausePreviewBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PersonalPausePreview &&
        startDate == other.startDate &&
        resumeDate == other.resumeDate &&
        projectedEndsAt == other.projectedEndsAt &&
        cancelledReservationIds == other.cancelledReservationIds;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, startDate.hashCode);
    _$hash = $jc(_$hash, resumeDate.hashCode);
    _$hash = $jc(_$hash, projectedEndsAt.hashCode);
    _$hash = $jc(_$hash, cancelledReservationIds.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PersonalPausePreview')
          ..add('startDate', startDate)
          ..add('resumeDate', resumeDate)
          ..add('projectedEndsAt', projectedEndsAt)
          ..add('cancelledReservationIds', cancelledReservationIds))
        .toString();
  }
}

class PersonalPausePreviewBuilder
    implements Builder<PersonalPausePreview, PersonalPausePreviewBuilder> {
  _$PersonalPausePreview? _$v;

  Date? _startDate;
  Date? get startDate => _$this._startDate;
  set startDate(Date? startDate) => _$this._startDate = startDate;

  Date? _resumeDate;
  Date? get resumeDate => _$this._resumeDate;
  set resumeDate(Date? resumeDate) => _$this._resumeDate = resumeDate;

  DateTime? _projectedEndsAt;
  DateTime? get projectedEndsAt => _$this._projectedEndsAt;
  set projectedEndsAt(DateTime? projectedEndsAt) =>
      _$this._projectedEndsAt = projectedEndsAt;

  ListBuilder<String>? _cancelledReservationIds;
  ListBuilder<String> get cancelledReservationIds =>
      _$this._cancelledReservationIds ??= ListBuilder<String>();
  set cancelledReservationIds(ListBuilder<String>? cancelledReservationIds) =>
      _$this._cancelledReservationIds = cancelledReservationIds;

  PersonalPausePreviewBuilder() {
    PersonalPausePreview._defaults(this);
  }

  PersonalPausePreviewBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _startDate = $v.startDate;
      _resumeDate = $v.resumeDate;
      _projectedEndsAt = $v.projectedEndsAt;
      _cancelledReservationIds = $v.cancelledReservationIds.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PersonalPausePreview other) {
    _$v = other as _$PersonalPausePreview;
  }

  @override
  void update(void Function(PersonalPausePreviewBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PersonalPausePreview build() => _build();

  _$PersonalPausePreview _build() {
    _$PersonalPausePreview _$result;
    try {
      _$result = _$v ??
          _$PersonalPausePreview._(
            startDate: BuiltValueNullFieldError.checkNotNull(
                startDate, r'PersonalPausePreview', 'startDate'),
            resumeDate: BuiltValueNullFieldError.checkNotNull(
                resumeDate, r'PersonalPausePreview', 'resumeDate'),
            projectedEndsAt: BuiltValueNullFieldError.checkNotNull(
                projectedEndsAt, r'PersonalPausePreview', 'projectedEndsAt'),
            cancelledReservationIds: cancelledReservationIds.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'cancelledReservationIds';
        cancelledReservationIds.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PersonalPausePreview', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
