// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'personal_pause_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PersonalPauseInput extends PersonalPauseInput {
  @override
  final Date startDate;
  @override
  final Date resumeDate;

  factory _$PersonalPauseInput(
          [void Function(PersonalPauseInputBuilder)? updates]) =>
      (PersonalPauseInputBuilder()..update(updates))._build();

  _$PersonalPauseInput._({required this.startDate, required this.resumeDate})
      : super._();
  @override
  PersonalPauseInput rebuild(
          void Function(PersonalPauseInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PersonalPauseInputBuilder toBuilder() =>
      PersonalPauseInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PersonalPauseInput &&
        startDate == other.startDate &&
        resumeDate == other.resumeDate;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, startDate.hashCode);
    _$hash = $jc(_$hash, resumeDate.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PersonalPauseInput')
          ..add('startDate', startDate)
          ..add('resumeDate', resumeDate))
        .toString();
  }
}

class PersonalPauseInputBuilder
    implements Builder<PersonalPauseInput, PersonalPauseInputBuilder> {
  _$PersonalPauseInput? _$v;

  Date? _startDate;
  Date? get startDate => _$this._startDate;
  set startDate(Date? startDate) => _$this._startDate = startDate;

  Date? _resumeDate;
  Date? get resumeDate => _$this._resumeDate;
  set resumeDate(Date? resumeDate) => _$this._resumeDate = resumeDate;

  PersonalPauseInputBuilder() {
    PersonalPauseInput._defaults(this);
  }

  PersonalPauseInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _startDate = $v.startDate;
      _resumeDate = $v.resumeDate;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PersonalPauseInput other) {
    _$v = other as _$PersonalPauseInput;
  }

  @override
  void update(void Function(PersonalPauseInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PersonalPauseInput build() => _build();

  _$PersonalPauseInput _build() {
    final _$result = _$v ??
        _$PersonalPauseInput._(
          startDate: BuiltValueNullFieldError.checkNotNull(
              startDate, r'PersonalPauseInput', 'startDate'),
          resumeDate: BuiltValueNullFieldError.checkNotNull(
              resumeDate, r'PersonalPauseInput', 'resumeDate'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
