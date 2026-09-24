// Detail view for one purchase, opened from the wallet activity feed.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:trotxi_client/trotxi_client.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Payments/purchase_labels.dart';
import 'package:trotxi_commuter/core/config/client_metadata.dart';
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
  required TrotxiApiClient client,
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

  final TrotxiApiClient client;
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
        xTrotxiClient: commuterMetadata.client,
        xTrotxiBuild: commuterMetadata.build,
        xTrotxiPlatform: commuterMetadata.platform,
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
          const SizedBox(height: 20),
          _buildAmounts(context, purchase),
          const SizedBox(height: 20),
          _buildMeta(context, purchase),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton(onPressed: _close, child: const Text('Close')),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------
  // Header — plan, state badge, when it was started
  // -------------------------------------------------------------------

  Widget _buildHeader(BuildContext context, Purchase purchase) {
    final colors = context.appColors;
    final stateColor = purchaseStateColor(context, purchase.state);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                purchasePlanLabel(purchase.plan),
                style: AppTypography.heading2.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Started ${_formatMoment(purchase.createdAt)}',
                style: AppTypography.caption.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: stateColor.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            purchaseStateLabel(purchase.state),
            style: AppTypography.label.copyWith(color: stateColor),
          ),
        ),
      ],
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
          _buildAmountRow(context, 'Price', purchase.price),
          const SizedBox(height: 8),
          _buildAmountRow(
            context,
            'Credit applied',
            purchase.appliedCredit,
            // Credit comes off the price, so it reads as a deduction.
            prefix: purchase.appliedCredit.amountMinor > 0 ? '−' : '',
          ),
          const SizedBox(height: 10),
          Divider(
            height: 1,
            color: colors.onSurfaceStrong.withValues(alpha: 0.18),
          ),
          const SizedBox(height: 10),
          _buildAmountRow(context, 'Cash due', purchase.cashDue, strong: true),
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: style.copyWith(
            color: colors.onSurfaceStrong.withValues(
              alpha: strong ? 1.0 : 0.72,
            ),
          ),
        ),
        Text(
          '$prefix${money.formatted}',
          style: style.copyWith(color: colors.onSurfaceStrong),
        ),
      ],
    );
  }

  // -------------------------------------------------------------------
  // Everything else worth showing, including the fields that are only set
  // in particular states (checkout, failureCode, billingPeriodId).
  // -------------------------------------------------------------------

  Widget _buildMeta(BuildContext context, Purchase purchase) {
    final colors = context.appColors;
    final checkout = purchase.checkout;
    final failureCode = purchase.failureCode;
    final billingPeriodId = purchase.billingPeriodId;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.backgroundDefault,
        border: Border.all(color: colors.borderSubtle),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMetaRow(
            context,
            'Collection',
            purchaseCollectionStateLabel(purchase.collectionState),
          ),
          if (checkout != null) ...[
            const SizedBox(height: 10),
            _buildMetaRow(
              context,
              'Checkout link',
              checkout.expiresAt == null
                  ? 'Open'
                  : 'Expires ${_formatMoment(checkout.expiresAt!)}',
            ),
          ],
          // Only set once a payment has actually gone wrong, and the raw code
          // is what support will ask for, so it's shown verbatim.
          if (failureCode != null) ...[
            const SizedBox(height: 10),
            _buildMetaRow(
              context,
              'Failure code',
              failureCode,
              valueColor: colors.error,
            ),
          ],
          // Absent until the purchase is fulfilled and a billing period exists.
          if (billingPeriodId != null) ...[
            const SizedBox(height: 10),
            _buildMetaRow(context, 'Billing period', billingPeriodId),
          ],
          const SizedBox(height: 10),
          _buildMetaRow(
            context,
            'Reference',
            purchase.id,
            // The one field a rider is ever asked to read back to support.
            onCopy: () => _copy(purchase.id),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaRow(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
    VoidCallback? onCopy,
  }) {
    final colors = context.appColors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: AppTypography.caption.copyWith(color: colors.textSecondary),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppTypography.caption.copyWith(
              color: valueColor ?? colors.textPrimary,
            ),
          ),
        ),
        if (onCopy != null) ...[
          const SizedBox(width: 6),
          InkWell(
            onTap: onCopy,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Icon(
                Icons.copy_rounded,
                size: 14,
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
      ],
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
