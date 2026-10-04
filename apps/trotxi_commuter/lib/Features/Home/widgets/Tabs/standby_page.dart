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
  final Set<int> _travelDays = {1, 2, 3, 4, 5};
  bool _useCredit = false;
  wire.PurchaseInputPlanEnum _plan = wire.PurchaseInputPlanEnum.monthly;
  static const _dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

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
    final selectionInput = wire.PurchaseInput(
      (b) => b
        ..plan = _plan
        ..routeId = commute.routeId
        ..legs.replace(commute.legs)
        ..useCredit = _useCredit,
    );
    final input = wire.StandbyJoinInput(
      (b) => b
        ..selection.replace(selectionInput)
        ..travelDays.replace(_travelDays.toList()..sort()),
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
    final generation = widget.client.sessionGeneration;
    final offer = application.offer;
    if (offer == null) return;
    final terms = offer.terms;
    if (terms == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accept this offer?'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Package: GHS ${(terms.price.amountMinor / 100).toStringAsFixed(2)}',
              ),
              Text(
                'Coverage: ${terms.coverageStart} until ${terms.coverageEnd} (end date excluded).',
              ),
              for (final leg in terms.legs) ...[
                const SizedBox(height: 12),
                Text(
                  '${leg.direction.name}: ${leg.pickupName} → ${leg.dropoffName}',
                ),
                Text(
                  '${leg.ridesGranted} rides on ${leg.travelDays.map((d) => _dayNames[d - 1]).join(', ')}',
                ),
                Text(
                  'Journey fare: GHS ${(leg.fare.amountMinor / 100).toStringAsFixed(2)}',
                ),
                Text(
                  'Credit per unused ride: GHS ${(leg.creditPerUnusedRide.amountMinor / 100).toStringAsFixed(2)}',
                ),
              ],
              const SizedBox(height: 12),
              const Text(
                'Unused rides convert to the stated credit when coverage closes. Outbound and return allowances are separate. Trips still require confirmation and available seats. You will review the final cash due before paying on Paystack.',
              ),
            ],
          ),
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
    if (!mounted ||
        confirmed != true ||
        generation != widget.client.sessionGeneration) {
      return;
    }
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
      appBar: AppBar(title: const Text('Waitlist')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Join the waitlist for your commute or renewal. Joining is free and does not guarantee a seat. Operations will send an offer with your journeys, dates, ride allowance and price. Review it before paying. Renewals are not automatic.',
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
          if (eligible && active.isEmpty) ...[
            DropdownButtonFormField<wire.PurchaseInputPlanEnum>(
              initialValue: _plan,
              decoration: const InputDecoration(labelText: 'Requested plan'),
              items: const [
                DropdownMenuItem(
                  value: wire.PurchaseInputPlanEnum.monthly,
                  child: Text('Monthly'),
                ),
                DropdownMenuItem(
                  value: wire.PurchaseInputPlanEnum.annual,
                  child: Text('Annual'),
                ),
              ],
              onChanged: _busy
                  ? null
                  : (plan) => setState(() => _plan = plan ?? _plan),
            ),
            const SizedBox(height: 16),
            const Text('Which days do you travel?'),
            Wrap(
              spacing: 8,
              children: [
                for (var day = 1; day <= 7; day++)
                  FilterChip(
                    label: Text(_dayNames[day - 1]),
                    selected: _travelDays.contains(day),
                    onSelected: _busy
                        ? null
                        : (selected) => setState(
                            () => selected
                                ? _travelDays.add(day)
                                : _travelDays.remove(day),
                          ),
                  ),
              ],
            ),
            CheckboxListTile(
              value: _useCredit,
              onChanged: _busy
                  ? null
                  : (v) => setState(() => _useCredit = v ?? false),
              title: const Text('Apply available ride credit when I accept'),
            ),
            FilledButton(
              onPressed: _busy || _travelDays.isEmpty ? null : _join,
              child: const Text('Choose a route'),
            ),
          ],
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
                    Text('Requested plan: ${application.selection.plan.name}'),
                    Text(
                      application.travelDays
                          .map((day) => _dayNames[day - 1])
                          .join(', '),
                    ),
                    if (application.offer != null)
                      Text(
                        'Offer expires ${application.offer!.expiresAt.toLocal()}',
                      ),
                    if (application.state ==
                            wire.StandbyApplicationStateEnum.offered &&
                        application.offer!.terms != null &&
                        application.offer!.expiresAt.isAfter(DateTime.now()))
                      FilledButton(
                        onPressed: _busy ? null : () => _accept(application),
                        child: const Text('Review your offer'),
                      ),
                    if (application.offer != null &&
                        application.offer!.terms == null &&
                        application.state ==
                            wire.StandbyApplicationStateEnum.offered)
                      const Text(
                        'This older offer has no agreed price. Leave the waitlist and submit a new request.',
                      ),
                    if (application.state ==
                            wire.StandbyApplicationStateEnum.offered &&
                        !application.offer!.expiresAt.isAfter(DateTime.now()))
                      const Text(
                        'This offer has expired. Leave the waitlist to choose a route again.',
                      ),
                    if (application.state ==
                            wire.StandbyApplicationStateEnum.submitted ||
                        application.state ==
                            wire.StandbyApplicationStateEnum.offered)
                      TextButton(
                        onPressed: _busy ? null : () => _withdraw(application),
                        child: const Text('Leave waitlist'),
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
