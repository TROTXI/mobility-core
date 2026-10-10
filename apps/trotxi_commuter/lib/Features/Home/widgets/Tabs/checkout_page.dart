import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:trotxi_client/commuter_checkout.dart';
import 'package:trotxi_client/trotxi_client.dart' as wire;
import 'package:trotxi_commuter/core/api/commuter_api.dart';
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
  @override
  Widget build(BuildContext context) {
    final checkout = _checkout;
    final unresolved = checkout?.purchases.any(purchaseUnresolved) ?? false;
    final saved = checkout?.intent;
    return Scaffold(
      appBar: AppBar(title: const Text('Purchase & payment')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Pay securely with Paystack. After paying, return here to check your payment status. Your rides appear once payment is confirmed.',
          ),
          if (_busy) const LinearProgressIndicator(),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(_error!),
            ),
          TextButton(
            onPressed: _busy ? null : _recover,
            child: const Text('Refresh payment status'),
          ),
          if (saved != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Your checkout is saved'),
                    const Text(
                      'Continue where you left off. This resumes the same purchase. If it is no longer available, contact support before trying to pay again.',
                    ),
                    TextButton(
                      onPressed: _busy
                          ? null
                          : () => _work(() async {
                              await checkout!.retry();
                            }),
                      child: const Text('Resume saved checkout'),
                    ),
                  ],
                ),
              ),
            ),
          if (checkout != null) ...[
            const Text('Payment history'),
            for (final p in checkout.purchases)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${p.offerTerms == null ? purchasePlanLabel(p.plan) : 'Subscription offer'} · ${_money(p.price)}',
                      ),
                      if (p.offerTerms != null) ...[
                        Text(
                          'Coverage: ${_coverage(p.offerTerms!.coverageStart, p.offerTerms!.coverageEnd)}',
                        ),
                        for (final leg in p.offerTerms!.legs)
                          Text(
                            '${leg.direction.name}: ${leg.ridesGranted} rides, ${leg.pickupName} → ${leg.dropoffName}. Unused credit: ${_money(leg.creditPerUnusedRide)} per ride.',
                          ),
                      ],
                      Text('Ride Credit applied: ${_money(p.appliedCredit)}'),
                      Text('Cash due: ${_money(p.cashDue)}'),
                      SelectableText('Payment reference: ${p.id}'),
                      Text(
                        purchaseStateLabel(
                          p.state,
                          collectionState: p.collectionState,
                        ),
                      ),
                      if (p.state == wire.PurchaseStateEnum.fulfilled)
                        const Text(
                          'Payment confirmed. Refresh Wallet to see your rides.',
                        ),
                      if (p.state == wire.PurchaseStateEnum.failed &&
                          p.collectionState ==
                              wire.PurchaseCollectionStateEnum.successful)
                        const Text(
                          'We received your payment, but could not activate this subscription. Operations will review it. Please do not pay again.',
                        )
                      else if (p.state == wire.PurchaseStateEnum.processing ||
                          p.collectionState ==
                                  wire.PurchaseCollectionStateEnum.successful &&
                              p.state == wire.PurchaseStateEnum.awaitingPayment)
                        const Text(
                          'We are confirming your payment. Please do not pay again.',
                        ),
                      if (p.state == wire.PurchaseStateEnum.reviewRequired)
                        const Text(
                          'Your payment needs a review. Please do not pay again.',
                        ),
                      if (paystackCheckoutUri(p, DateTime.now()) != null)
                        FilledButton(
                          onPressed: _busy ? null : () => _pay(p),
                          child: Text(
                            'Continue to Paystack · ${_money(p.cashDue)}',
                          ),
                        )
                      else if (p.state ==
                          wire.PurchaseStateEnum.awaitingPayment)
                        const Text(
                          'The payment link is unavailable. Resume your saved checkout or contact support with this payment reference.',
                        ),
                    ],
                  ),
                ),
              ),
            if (saved == null && !unresolved && _error == null) ...[
              const Divider(),
              const Text(
                'To start or renew a plan, tell us which journeys and travel days you need. We will send you an offer to review before you pay.',
              ),
              FilledButton(
                onPressed: _busy
                    ? null
                    : () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => StandbyPage(client: widget.client),
                        ),
                      ),
                child: const Text('View waitlist'),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
