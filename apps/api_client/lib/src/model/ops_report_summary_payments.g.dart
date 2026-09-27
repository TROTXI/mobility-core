// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ops_report_summary_payments.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OpsReportSummaryPayments extends OpsReportSummaryPayments {
  @override
  final Money collected;
  @override
  final Money refunded;
  @override
  final int openReviews;

  factory _$OpsReportSummaryPayments(
          [void Function(OpsReportSummaryPaymentsBuilder)? updates]) =>
      (OpsReportSummaryPaymentsBuilder()..update(updates))._build();

  _$OpsReportSummaryPayments._(
      {required this.collected,
      required this.refunded,
      required this.openReviews})
      : super._();
  @override
  OpsReportSummaryPayments rebuild(
          void Function(OpsReportSummaryPaymentsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OpsReportSummaryPaymentsBuilder toBuilder() =>
      OpsReportSummaryPaymentsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OpsReportSummaryPayments &&
        collected == other.collected &&
        refunded == other.refunded &&
        openReviews == other.openReviews;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, collected.hashCode);
    _$hash = $jc(_$hash, refunded.hashCode);
    _$hash = $jc(_$hash, openReviews.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OpsReportSummaryPayments')
          ..add('collected', collected)
          ..add('refunded', refunded)
          ..add('openReviews', openReviews))
        .toString();
  }
}

class OpsReportSummaryPaymentsBuilder
    implements
        Builder<OpsReportSummaryPayments, OpsReportSummaryPaymentsBuilder> {
  _$OpsReportSummaryPayments? _$v;

  MoneyBuilder? _collected;
  MoneyBuilder get collected => _$this._collected ??= MoneyBuilder();
  set collected(MoneyBuilder? collected) => _$this._collected = collected;

  MoneyBuilder? _refunded;
  MoneyBuilder get refunded => _$this._refunded ??= MoneyBuilder();
  set refunded(MoneyBuilder? refunded) => _$this._refunded = refunded;

  int? _openReviews;
  int? get openReviews => _$this._openReviews;
  set openReviews(int? openReviews) => _$this._openReviews = openReviews;

  OpsReportSummaryPaymentsBuilder() {
    OpsReportSummaryPayments._defaults(this);
  }

  OpsReportSummaryPaymentsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _collected = $v.collected.toBuilder();
      _refunded = $v.refunded.toBuilder();
      _openReviews = $v.openReviews;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OpsReportSummaryPayments other) {
    _$v = other as _$OpsReportSummaryPayments;
  }

  @override
  void update(void Function(OpsReportSummaryPaymentsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OpsReportSummaryPayments build() => _build();

  _$OpsReportSummaryPayments _build() {
    _$OpsReportSummaryPayments _$result;
    try {
      _$result = _$v ??
          _$OpsReportSummaryPayments._(
            collected: collected.build(),
            refunded: refunded.build(),
            openReviews: BuiltValueNullFieldError.checkNotNull(
                openReviews, r'OpsReportSummaryPayments', 'openReviews'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'collected';
        collected.build();
        _$failedField = 'refunded';
        refunded.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'OpsReportSummaryPayments', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
