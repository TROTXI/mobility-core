// Detail view for one purchase, opened from the wallet activity feed.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:trotxi_client/trotxi_client.dart';
import 'package:trotxi_commuter/core/api/commuter_api.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Payments/purchase_labels.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';
import 'package:trotxi_commuter/core/config/theme/app_typography.dart';
import 'package:trotxi_commuter/core/utils/money_format.dart';

/// Opens the purchase details sheet for [purchaseId], which re-reads the
/// purchase from `GET /v1/me/purchases/{id}` while it is open.
///
/// Answers with the purchase as the server last described it, or `null` if the
/// fetch never succeeded. The caller can compare that against the row it was
/// opened from to notice a purchase that has settled since the list loaded.
Future<Purchase?> showPurchaseDetailsSheet(
  BuildContext context, {
  required CommuterApi client,
  required String purchaseId,
}) {
  return showModalBottomSheet<Purchase>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    backgroundColor: context.appColors.surfaceElevated,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) =>
        _PurchaseDetailsSheet(client: client, purchaseId: purchaseId),
  );
}

class _PurchaseDetailsSheet extends StatefulWidget {
  const _PurchaseDetailsSheet({required this.client, required this.purchaseId});

  final CommuterApi client;
  final String purchaseId;

  @override
  State<_PurchaseDetailsSheet> createState() => _PurchaseDetailsSheetState();
}

class _PurchaseDetailsSheetState extends State<_PurchaseDetailsSheet> {
  Purchase? _purchase;
  bool _loading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await widget.client.getRiderOwnApi().getPurchase(
        id: widget.purchaseId,
        xTrotxiClient: widget.client.metadata.app,
        xTrotxiBuild: widget.client.metadata.build,
        xTrotxiPlatform: widget.client.metadata.platform,
      );
      if (!mounted) return;
      setState(() {
        _purchase = response.data?.data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
      debugPrint('Error loading purchase ${widget.purchaseId}: $e');
    }
  }

  /// The sheet is the only thing that has re-read this purchase, so it hands
  /// the fresh copy back on the way out.
  void _close() => Navigator.of(context).pop(_purchase);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        // The sheet grows from the spinner to the loaded detail; animating it
        // stops the jump when the response lands.
        child: AnimatedSize(
          duration: const Duration(milliseconds: 150),
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: _buildContent(context),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final colors = context.appColors;

    if (_loading) {
      return SizedBox(
        height: 160,
        child: Center(
          child: CircularProgressIndicator(color: colors.actionPrimaryDefault),
        ),
      );
    }

    final purchase = _purchase;
    if (purchase == null) {
      final error = _error;
      final message = error is TrotxiException
          ? error.message
          : "Couldn't load this purchase";
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: AppTypography.label.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton(onPressed: _load, child: const Text('Try again')),
              const Spacer(),
              TextButton(onPressed: _close, child: const Text('Close')),
            ],
          ),
        ],
      );
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, purchase),
          if (purchase.offerTerms != null) ...[
            const SizedBox(height: 20),
            _buildCoverage(context, purchase),
          ],
          const SizedBox(height: 20),
          _buildAmounts(context, purchase),
          const SizedBox(height: 20),
          _buildPaymentStatus(context, purchase),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _copy(purchase.id),
              icon: const Icon(Icons.copy_rounded, size: 18),
              label: const Text('Copy reference for support'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(onPressed: _close, child: const Text('Close')),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------
  // Header: the purchase state is prominent; internal identifiers are not.
  // -------------------------------------------------------------------

  Widget _buildHeader(BuildContext context, Purchase purchase) {
    final colors = context.appColors;
    final stateColor = purchaseStateColor(
      context,
      purchase.state,
      collectionState: purchase.collectionState,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          purchase.offerTerms != null
              ? 'Subscription payment'
              : purchasePlanLabel(purchase.plan),
          style: AppTypography.heading3.copyWith(color: colors.textPrimary),
        ),
        const SizedBox(height: 4),
        Text(
          'Created ${_formatMoment(purchase.createdAt)}',
          style: AppTypography.caption.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: stateColor.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            purchaseStateLabel(
              purchase.state,
              collectionState: purchase.collectionState,
            ),
            style: AppTypography.label.copyWith(color: stateColor),
          ),
        ),
      ],
    );
  }

  Widget _buildCoverage(BuildContext context, Purchase purchase) {
    final terms = purchase.offerTerms!;
    final colors = context.appColors;
    final start = DateFormat(
      'd MMM y',
    ).format(terms.coverageStart.toDateTime(utc: true));
    final end = DateFormat('d MMM y').format(
      terms.coverageEnd.toDateTime(utc: true).subtract(const Duration(days: 1)),
    );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.backgroundSubtle,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your coverage',
            style: AppTypography.label.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            '$start to $end',
            style: AppTypography.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
          for (final leg in terms.legs) ...[
            const SizedBox(height: 16),
            Divider(height: 1, color: colors.borderSubtle),
            const SizedBox(height: 14),
            Text(
              '${leg.pickupName} → ${leg.dropoffName}',
              style: AppTypography.label.copyWith(color: colors.textPrimary),
            ),
            const SizedBox(height: 3),
            Text(
              '${leg.direction.name == 'return_' ? 'Return' : 'Outbound'} · ${leg.ridesGranted} rides',
              style: AppTypography.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
            ),
            Text(
              '${leg.creditPerUnusedRide.formatted} credit per unused ride',
              style: AppTypography.caption.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // -------------------------------------------------------------------
  // Amounts — what it cost, what credit covered, what was left to pay
  // -------------------------------------------------------------------

  Widget _buildAmounts(BuildContext context, Purchase purchase) {
    final colors = context.appColors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceStrong,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (purchase.appliedCredit.amountMinor > 0) ...[
            _buildAmountRow(context, 'Package price', purchase.price),
            const SizedBox(height: 8),
            _buildAmountRow(
              context,
              'Ride credit applied',
              purchase.appliedCredit,
              prefix: '−',
            ),
            const SizedBox(height: 12),
            Divider(
              height: 1,
              color: colors.onSurfaceStrong.withValues(alpha: 0.18),
            ),
            const SizedBox(height: 12),
          ],
          _buildAmountRow(
            context,
            purchaseCashLabel(purchase.collectionState),
            purchase.cashDue,
            strong: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAmountRow(
    BuildContext context,
    String label,
    Money money, {
    String prefix = '',
    bool strong = false,
  }) {
    final colors = context.appColors;
    final style = strong ? AppTypography.buttonAction : AppTypography.label;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: style.copyWith(
              color: colors.onSurfaceStrong.withValues(
                alpha: strong ? 1.0 : 0.72,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            '$prefix${money.formatted}',
            textAlign: TextAlign.right,
            style: style.copyWith(color: colors.onSurfaceStrong),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------------
  // Explain what happens next without exposing database or Paystack internals.
  // -------------------------------------------------------------------

  Widget _buildPaymentStatus(BuildContext context, Purchase purchase) {
    final colors = context.appColors;
    final stateColor = purchaseStateColor(
      context,
      purchase.state,
      collectionState: purchase.collectionState,
    );
    final message = switch (purchase.state) {
      PurchaseStateEnum.fulfilled =>
        'Payment confirmed. Check Wallet for your coverage. Rides become available on the coverage start date.',
      PurchaseStateEnum.reviewRequired =>
        'Our team is reviewing this payment. Please do not pay again.',
      PurchaseStateEnum.processing =>
        'We are confirming your payment. Please do not pay again.',
      PurchaseStateEnum.awaitingPayment
          when purchase.collectionState ==
              PurchaseCollectionStateEnum.successful =>
        'We received your payment and are confirming it. Please do not pay again.',
      PurchaseStateEnum.failed
          when purchase.collectionState ==
              PurchaseCollectionStateEnum.successful =>
        'We received your payment, but could not activate coverage. Our team will review it. Please do not pay again.',
      PurchaseStateEnum.failed =>
        'This payment was not completed. Check your payment options or contact support.',
      PurchaseStateEnum.cancelled => 'This payment was cancelled.',
      _ =>
        'Payment is still due. Review the amount before continuing to Paystack.',
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: stateColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: stateColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  purchaseStateLabel(
                    purchase.state,
                    collectionState: purchase.collectionState,
                  ),
                  style: AppTypography.label.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                if (purchase.state == PurchaseStateEnum.awaitingPayment &&
                    purchase.checkout?.expiresAt != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Payment link expires ${_formatMoment(purchase.checkout!.expiresAt!)}',
                    style: AppTypography.caption.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _copy(String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Reference copied')));
  }
}

String _formatMoment(DateTime at) =>
    DateFormat('d MMM y, HH:mm').format(at.toLocal());
