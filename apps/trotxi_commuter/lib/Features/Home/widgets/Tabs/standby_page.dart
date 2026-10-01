import 'package:flutter/material.dart';
import 'package:trotxi_client/commuter_checkout.dart';
import 'package:trotxi_client/trotxi_client.dart' as wire;
import 'package:trotxi_commuter/core/api/commuter_api.dart';
import 'checkout_page.dart';
import 'commute_picker.dart';
import 'phone_verification_page.dart';

class StandbyPage extends StatefulWidget {
  const StandbyPage({super.key, required this.client});
  final CommuterApi client;

  @override
  State<StandbyPage> createState() => _StandbyPageState();
}

class _StandbyPageState extends State<StandbyPage> {
  wire.VerificationStatus? _verification;
  List<wire.StandbyApplication> _applications = [];
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final generation = widget.client.sessionGeneration;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final verification = await widget.client.verificationStatus();
      final applications = await widget.client.standbyApplications();
      if (!mounted || generation != widget.client.sessionGeneration) return;
      setState(() {
        _verification = verification;
        _applications = applications;
      });
    } on wire.TrotxiException catch (error) {
      if (!mounted || generation != widget.client.sessionGeneration) return;
      setState(() => _error = error.message);
    } finally {
      if (mounted && generation == widget.client.sessionGeneration) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _join() async {
    final generation = widget.client.sessionGeneration;
    final selection = await Navigator.of(context).push<CommuteRouteSelection>(
      MaterialPageRoute(
        builder: (_) => CommutePickerPage(client: widget.client),
      ),
    );
    if (!mounted ||
        selection == null ||
        generation != widget.client.sessionGeneration) {
      return;
    }
    final commute = selection.request(wire.Date.now(utc: true), false, '');
    final input = wire.PurchaseInput(
      (b) => b
        ..plan = wire.PurchaseInputPlanEnum.monthly
        ..routeId = commute.routeId
        ..legs.replace(commute.legs)
        ..useCredit = false,
    );
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.client.joinStandby(input);
      await _refresh();
    } on wire.TrotxiException catch (error) {
      if (mounted && generation == widget.client.sessionGeneration) {
        setState(() => _error = error.message);
      }
    } finally {
      if (mounted && generation == widget.client.sessionGeneration) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _withdraw(wire.StandbyApplication application) async {
    final generation = widget.client.sessionGeneration;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.client.withdrawStandby(application.id);
      await _refresh();
    } on wire.TrotxiException catch (error) {
      if (mounted && generation == widget.client.sessionGeneration) {
        setState(() => _error = error.message);
      }
    } finally {
      if (mounted && generation == widget.client.sessionGeneration) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _accept(wire.StandbyApplication application) async {
    final offer = application.offer;
    if (offer == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accept this offer?'),
        content: const Text(
          'This creates a new Paystack checkout. You will see the current price before choosing to pay. No existing payment is reused.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    final generation = widget.client.sessionGeneration;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final purchase = await widget.client.acceptStandbyOffer(application.id);
      if (!mounted || generation != widget.client.sessionGeneration) return;
      final uri = paystackCheckoutUri(purchase, DateTime.now());
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Review checkout'),
          content: Text(
            'Amount due: ${purchase.cashDue.currency.name} ${(purchase.cashDue.amountMinor / 100).toStringAsFixed(2)}. Paying is optional until you confirm on Paystack.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Later'),
            ),
            if (uri != null)
              FilledButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await openPaystackCheckout(uri);
                },
                child: const Text('Open Paystack'),
              ),
          ],
        ),
      );
      await _refresh();
    } on wire.TrotxiException catch (error) {
      if (mounted && generation == widget.client.sessionGeneration) {
        setState(() => _error = error.message);
      }
    } finally {
      if (mounted && generation == widget.client.sessionGeneration) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final eligible = _verification?.standbyEligible ?? false;
    final active = _applications
        .where(
          (a) =>
              a.state == wire.StandbyApplicationStateEnum.submitted ||
              a.state == wire.StandbyApplicationStateEnum.offered ||
              a.state == wire.StandbyApplicationStateEnum.checkoutOpen,
        )
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Standby')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Join standby for a route. An offer is not a booking; you choose whether to start and pay for a new checkout.',
          ),
          const SizedBox(height: 16),
          if (_busy) const LinearProgressIndicator(),
          if (_error != null) Text(_error!),
          if (!eligible && _verification != null) ...[
            const Text(
              'Complete your profile and verify your phone before joining.',
            ),
            TextButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        PhoneVerificationPage(client: widget.client),
                  ),
                );
                if (mounted) _refresh();
              },
              child: const Text('Verify phone'),
            ),
          ],
          if (eligible && active.isEmpty)
            FilledButton(
              onPressed: _busy ? null : _join,
              child: const Text('Choose a route'),
            ),
          for (final application in active)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application.routeName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text('Status: ${application.state.name}'),
                    if (application.offer != null)
                      Text(
                        'Offer expires ${application.offer!.expiresAt.toLocal()}',
                      ),
                    if (application.state ==
                            wire.StandbyApplicationStateEnum.offered &&
                        application.offer!.expiresAt.isAfter(DateTime.now()))
                      FilledButton(
                        onPressed: _busy ? null : () => _accept(application),
                        child: const Text('Review offer'),
                      ),
                    if (application.state ==
                            wire.StandbyApplicationStateEnum.offered &&
                        !application.offer!.expiresAt.isAfter(DateTime.now()))
                      const Text('This offer has expired. Leave standby to choose a route again.'),
                    if (application.state ==
                            wire.StandbyApplicationStateEnum.submitted ||
                        application.state ==
                            wire.StandbyApplicationStateEnum.offered)
                      TextButton(
                        onPressed: _busy ? null : () => _withdraw(application),
                        child: const Text('Leave standby'),
                      ),
                    if (application.state ==
                        wire.StandbyApplicationStateEnum.checkoutOpen)
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CheckoutPage(client: widget.client),
                          ),
                        ),
                        child: const Text('View checkout'),
                      ),
                  ],
                ),
              ),
            ),
          TextButton(
            onPressed: _busy ? null : _refresh,
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }
}
