import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:trotxi_client/commuter_checkout.dart';
import 'package:trotxi_client/trotxi_client.dart' as wire;
import 'package:trotxi_commuter/core/api/commuter_api.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';
import 'package:trotxi_commuter/core/config/theme/app_typography.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Payments/purchase_details_sheet.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Payments/purchase_labels.dart';
import 'standby_page.dart';

Future<bool> openPaystackCheckout(Uri uri) =>
    launchUrl(uri, mode: LaunchMode.externalApplication);

/// Browser return is only a reason to re-read the API. There is no client-side
/// "paid" transition, URL callback proof, secret key or embedded payment form.
class CheckoutPage extends StatefulWidget {
  const CheckoutPage({
    super.key,
    required this.client,
    this.openCheckout = openPaystackCheckout,
  });
  final CommuterApi client;
  final Future<bool> Function(Uri) openCheckout;
  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage>
    with WidgetsBindingObserver {
  CommuterCheckout? _checkout;
  bool _busy = true, _refreshWhenIdle = false;
  String? _error;
  int _load = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _recover();
  }

  @override
  void dispose() {
    _load++;
    _checkout?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_busy) {
        _refreshWhenIdle = true;
      } else {
        unawaited(_recover());
      }
    }
  }

  Future<void> _work(Future<void> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } catch (e) {
      if (mounted) {
        setState(
          () => _error = e is TrotxiException
              ? e.message
              : 'Could not complete checkout. Your saved request has not been discarded. Retry or contact operations.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
        if (_refreshWhenIdle) {
          _refreshWhenIdle = false;
          unawaited(_recover());
        }
      }
    }
  }

  Future<void> _recover() async {
    final attempt = ++_load;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final checkout = _checkout ?? await CommuterCheckout.open(widget.client);
      if (!mounted || attempt != _load) {
        if (_checkout != checkout) checkout.dispose();
        return;
      }
      _checkout = checkout;
      await checkout.recover();
    } catch (e) {
      if (mounted && attempt == _load) {
        _error = e is TrotxiException
            ? e.message
            : 'Could not recover checkout. Please retry before starting another purchase.';
      }
    } finally {
      if (mounted && attempt == _load) {
        setState(() => _busy = false);
        if (_refreshWhenIdle) {
          _refreshWhenIdle = false;
          unawaited(_recover());
        }
      }
    }
  }

  Future<void> _pay(wire.Purchase shown) => _work(() async {
    final generation = widget.client.sessionGeneration;
    // A URL rendered earlier may now be expired, paid or under review.
    await _checkout!.recover();
    final rows = _checkout!.purchases.where((p) => p.id == shown.id);
    if (rows.length != 1) {
      throw const ApiException(
        409,
        'Purchase is no longer available. Refresh.',
      );
    }
    final current = rows.single;
    final target = paystackCheckoutUri(current, DateTime.now());
    if (target == null) {
      throw const ApiException(
        409,
        'This purchase cannot open checkout now. Check its status or contact operations.',
      );
    }
    // If the quote changes unexpectedly, require another explicit tap on the
    // newly displayed amount instead of launching against the old consent.
    if (current.cashDue != shown.cashDue ||
        current.price != shown.price ||
        current.appliedCredit != shown.appliedCredit) {
      throw const ApiException(
        409,
        'Purchase amounts changed. Review them before continuing.',
      );
    }
    widget.client.ensureSession(generation);
    if (!mounted) return;
    if (!await widget.openCheckout(target)) {
      throw const ApiException(
        0,
        'Could not open Paystack. Your purchase remains saved; retry opening it.',
      );
    }
  });
  String _money(wire.Money m) =>
      '${m.currency.name} ${(m.amountMinor / 100).toStringAsFixed(2)}';
  String _coverage(wire.Date start, wire.Date end) =>
      '${DateFormat('d MMM y').format(start.toDateTime(utc: true))} to '
      '${DateFormat('d MMM y').format(end.toDateTime(utc: true).subtract(const Duration(days: 1)))}';

  Future<void> _showDetails(wire.Purchase purchase) async {
    final latest = await showPurchaseDetailsSheet(
      context,
      client: widget.client,
      purchaseId: purchase.id,
    );
    if (mounted && latest != null && latest.state != purchase.state) {
      await _recover();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final checkout = _checkout;
    final unresolved = checkout?.purchases.any(purchaseUnresolved) ?? false;
    final saved = checkout?.intent;
    return Scaffold(
      appBar: AppBar(title: const Text('Payments')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          Text(
            'Your payments',
            style: AppTypography.heading2.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            'Review your subscription payments and continue a checkout when one is ready.',
            style: AppTypography.body.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: 20),
          if (_busy) ...[
            const LinearProgressIndicator(),
            const SizedBox(height: 16),
          ],
          if (_error != null) ...[
            _messageCard(
              context,
              icon: Icons.error_outline_rounded,
              message: _error!,
              accent: colors.error,
            ),
            const SizedBox(height: 16),
          ],
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: _busy ? null : _recover,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Refresh payment status'),
            ),
          ),
          if (saved != null) ...[
            const SizedBox(height: 18),
            _savedCheckoutCard(context, checkout!),
          ],
          if (checkout != null) ...[
            const SizedBox(height: 28),
            Text(
              'Payment history',
              style: AppTypography.title.copyWith(color: colors.textPrimary),
            ),
            const SizedBox(height: 12),
            if (checkout.purchases.isEmpty)
              _messageCard(
                context,
                icon: Icons.receipt_long_outlined,
                message: 'No payments yet. Offers you accept will appear here.',
                accent: colors.actionPrimaryDefault,
              )
            else
              for (final p in checkout.purchases) ...[
                _purchaseCard(context, p),
                const SizedBox(height: 12),
              ],
            if (saved == null && !unresolved && _error == null) ...[
              const SizedBox(height: 16),
              _newPlanCard(context),
            ],
          ],
        ],
      ),
    );
  }

  Widget _savedCheckoutCard(BuildContext context, CommuterCheckout checkout) {
    final colors = context.appColors;
    return _surfaceCard(
      context,
      children: [
        Icon(Icons.bookmark_added_outlined, color: colors.actionPrimaryDefault),
        const SizedBox(height: 10),
        Text(
          'Checkout saved',
          style: AppTypography.title.copyWith(color: colors.textPrimary),
        ),
        const SizedBox(height: 4),
        Text(
          'Pick up where you left off. We will check the same purchase before you pay.',
          style: AppTypography.bodySmall.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: 14),
        OutlinedButton(
          onPressed: _busy ? null : () => _work(() async => checkout.retry()),
          child: const Text('Resume saved checkout'),
        ),
      ],
    );
  }

  Widget _purchaseCard(BuildContext context, wire.Purchase purchase) {
    final colors = context.appColors;
    final stateColor = purchaseStateColor(
      context,
      purchase.state,
      collectionState: purchase.collectionState,
    );
    final terms = purchase.offerTerms;
    final payable = paystackCheckoutUri(purchase, DateTime.now()) != null;
    final needsReview =
        purchase.state == wire.PurchaseStateEnum.reviewRequired ||
        (purchase.state == wire.PurchaseStateEnum.failed &&
            purchase.collectionState ==
                wire.PurchaseCollectionStateEnum.successful);
    final confirming =
        purchase.state == wire.PurchaseStateEnum.processing ||
        (purchase.state == wire.PurchaseStateEnum.awaitingPayment &&
            purchase.collectionState ==
                wire.PurchaseCollectionStateEnum.successful);
    return _surfaceCard(
      context,
      children: [
        Text(
          terms == null
              ? purchasePlanLabel(purchase.plan)
              : 'Subscription payment',
          style: AppTypography.title.copyWith(color: colors.textPrimary),
        ),
        const SizedBox(height: 6),
        Text(
          DateFormat('d MMM y').format(purchase.createdAt.toLocal()),
          style: AppTypography.caption.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: stateColor.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              purchaseStateLabel(
                purchase.state,
                collectionState: purchase.collectionState,
              ),
              style: AppTypography.caption.copyWith(
                color: stateColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        if (terms != null) ...[
          const SizedBox(height: 16),
          Text(
            'Coverage',
            style: AppTypography.caption.copyWith(color: colors.textSecondary),
          ),
          Text(
            _coverage(terms.coverageStart, terms.coverageEnd),
            style: AppTypography.bodySmall.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: 12),
          for (final leg in terms.legs) ...[
            Text(
              '${leg.pickupName} → ${leg.dropoffName}',
              style: AppTypography.label.copyWith(color: colors.textPrimary),
            ),
            Text(
              '${leg.direction.name == 'return_' ? 'Return' : 'Outbound'} · ${leg.ridesGranted} rides',
              style: AppTypography.caption.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ],
        const SizedBox(height: 10),
        Divider(height: 1, color: colors.borderSubtle),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: Text(
                purchaseCashLabel(purchase.collectionState),
                style: AppTypography.bodySmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
            Text(
              _money(purchase.cashDue),
              style: AppTypography.title.copyWith(color: colors.textPrimary),
            ),
          ],
        ),
        if (purchase.appliedCredit.amountMinor > 0) ...[
          const SizedBox(height: 4),
          Text(
            '${_money(purchase.appliedCredit)} ride credit applied',
            style: AppTypography.caption.copyWith(color: colors.textSecondary),
          ),
        ],
        if (purchase.state == wire.PurchaseStateEnum.fulfilled ||
            needsReview ||
            confirming) ...[
          const SizedBox(height: 12),
          Text(
            purchase.state == wire.PurchaseStateEnum.fulfilled
                ? 'Payment confirmed. Check Wallet for your coverage.'
                : needsReview
                ? 'We received your payment and are reviewing it. Please do not pay again.'
                : 'We are confirming your payment. Please do not pay again.',
            style: AppTypography.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
        if (payable) ...[
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _busy ? null : () => _pay(purchase),
              child: Text('Continue to Paystack · ${_money(purchase.cashDue)}'),
            ),
          ),
        ] else if (purchase.state == wire.PurchaseStateEnum.awaitingPayment &&
            !confirming) ...[
          const SizedBox(height: 12),
          Text(
            'The payment link is unavailable. Resume your saved checkout or contact support.',
            style: AppTypography.bodySmall.copyWith(color: colors.warning),
          ),
        ],
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () => _showDetails(purchase),
            child: const Text('View payment details'),
          ),
        ),
      ],
    );
  }

  Widget _newPlanCard(BuildContext context) {
    final colors = context.appColors;
    return _surfaceCard(
      context,
      children: [
        Text(
          'Need a new plan?',
          style: AppTypography.title.copyWith(color: colors.textPrimary),
        ),
        const SizedBox(height: 6),
        Text(
          'Tell us your route and travel days. We will send an offer with the price and ride allowance for you to review.',
          style: AppTypography.bodySmall.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _busy
                ? null
                : () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => StandbyPage(client: widget.client),
                    ),
                  ),
            child: const Text('View waitlist'),
          ),
        ),
      ],
    );
  }

  Widget _surfaceCard(BuildContext context, {required List<Widget> children}) {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        border: Border.all(color: colors.borderSubtle),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _messageCard(
    BuildContext context, {
    required IconData icon,
    required String message,
    required Color accent,
  }) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySmall.copyWith(
                color: colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
