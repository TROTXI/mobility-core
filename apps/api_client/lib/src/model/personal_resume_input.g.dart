// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'personal_resume_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PersonalResumeInput extends PersonalResumeInput {
  @override
  final Date resumeDate;

  factory _$PersonalResumeInput(
          [void Function(PersonalResumeInputBuilder)? updates]) =>
      (PersonalResumeInputBuilder()..update(updates))._build();

  _$PersonalResumeInput._({required this.resumeDate}) : super._();
  @override
  PersonalResumeInput rebuild(
          void Function(PersonalResumeInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PersonalResumeInputBuilder toBuilder() =>
      PersonalResumeInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PersonalResumeInput && resumeDate == other.resumeDate;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, resumeDate.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PersonalResumeInput')
          ..add('resumeDate', resumeDate))
        .toString();
  }
}

class PersonalResumeInputBuilder
    implements Builder<PersonalResumeInput, PersonalResumeInputBuilder> {
  _$PersonalResumeInput? _$v;

  Date? _resumeDate;
  Date? get resumeDate => _$this._resumeDate;
  set resumeDate(Date? resumeDate) => _$this._resumeDate = resumeDate;

  PersonalResumeInputBuilder() {
    PersonalResumeInput._defaults(this);
  }

  PersonalResumeInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _resumeDate = $v.resumeDate;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PersonalResumeInput other) {
    _$v = other as _$PersonalResumeInput;
  }

  @override
  void update(void Function(PersonalResumeInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PersonalResumeInput build() => _build();

  _$PersonalResumeInput _build() {
    final _$result = _$v ??
        _$PersonalResumeInput._(
          resumeDate: BuiltValueNullFieldError.checkNotNull(
              resumeDate, r'PersonalResumeInput', 'resumeDate'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
