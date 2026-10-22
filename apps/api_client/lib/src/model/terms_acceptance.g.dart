// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'terms_acceptance.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TermsAcceptance extends TermsAcceptance {
  @override
  final bool acceptedTerms;
  @override
  final Date termsVersion;

  factory _$TermsAcceptance([void Function(TermsAcceptanceBuilder)? updates]) =>
      (TermsAcceptanceBuilder()..update(updates))._build();

  _$TermsAcceptance._({required this.acceptedTerms, required this.termsVersion})
      : super._();
  @override
  TermsAcceptance rebuild(void Function(TermsAcceptanceBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TermsAcceptanceBuilder toBuilder() => TermsAcceptanceBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TermsAcceptance &&
        acceptedTerms == other.acceptedTerms &&
        termsVersion == other.termsVersion;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, acceptedTerms.hashCode);
    _$hash = $jc(_$hash, termsVersion.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TermsAcceptance')
          ..add('acceptedTerms', acceptedTerms)
          ..add('termsVersion', termsVersion))
        .toString();
  }
}

class TermsAcceptanceBuilder
    implements Builder<TermsAcceptance, TermsAcceptanceBuilder> {
  _$TermsAcceptance? _$v;

  bool? _acceptedTerms;
  bool? get acceptedTerms => _$this._acceptedTerms;
  set acceptedTerms(bool? acceptedTerms) =>
      _$this._acceptedTerms = acceptedTerms;

  Date? _termsVersion;
  Date? get termsVersion => _$this._termsVersion;
  set termsVersion(Date? termsVersion) => _$this._termsVersion = termsVersion;

  TermsAcceptanceBuilder() {
    TermsAcceptance._defaults(this);
  }

  TermsAcceptanceBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _acceptedTerms = $v.acceptedTerms;
      _termsVersion = $v.termsVersion;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TermsAcceptance other) {
    _$v = other as _$TermsAcceptance;
  }

  @override
  void update(void Function(TermsAcceptanceBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TermsAcceptance build() => _build();

  _$TermsAcceptance _build() {
    final _$result = _$v ??
        _$TermsAcceptance._(
          acceptedTerms: BuiltValueNullFieldError.checkNotNull(
              acceptedTerms, r'TermsAcceptance', 'acceptedTerms'),
          termsVersion: BuiltValueNullFieldError.checkNotNull(
              termsVersion, r'TermsAcceptance', 'termsVersion'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
