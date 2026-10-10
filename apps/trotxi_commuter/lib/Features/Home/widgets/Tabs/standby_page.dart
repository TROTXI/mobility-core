import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trotxi_client/commuter_checkout.dart';
import 'package:trotxi_client/trotxi_client.dart' as wire;
import 'package:trotxi_commuter/core/api/commuter_api.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';
import 'package:trotxi_commuter/core/config/theme/app_typography.dart';
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

  String _coverage(wire.Date start, wire.Date end) =>
      '${DateFormat('d MMM y').format(start.toDateTime(utc: true))} to '
      '${DateFormat('d MMM y').format(end.toDateTime(utc: true).subtract(const Duration(days: 1)))}';

  String _status(wire.StandbyApplicationStateEnum state) => switch (state) {
    wire.StandbyApplicationStateEnum.submitted => 'Request received',
    wire.StandbyApplicationStateEnum.offered => 'Offer ready',
    wire.StandbyApplicationStateEnum.checkoutOpen => 'Awaiting payment',
    _ => 'Request updated',
  };

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
                'Coverage: ${_coverage(terms.coverageStart, terms.coverageEnd)}.',
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
                'Unused rides convert to the stated credit when coverage closes. Outbound and return allowances are separate. Trips still require confirmation and available seats. Upcoming rides cannot be used before their start date. Pauses and commute changes are blocked while a renewal checkout or paid renewal is pending. You will review the final cash due before paying on Paystack.',
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
    final colors = context.appColors;
    final eligible = _verification?.standbyEligible ?? false;
    final active = _applications
        .where(
          (a) =>
              a.state == wire.StandbyApplicationStateEnum.submitted ||
              a.state == wire.StandbyApplicationStateEnum.offered ||
              a.state == wire.StandbyApplicationStateEnum.checkoutOpen,
        )
        .toList();
    final checkoutOpen = active.any(
      (a) => a.state == wire.StandbyApplicationStateEnum.checkoutOpen,
    );
    final offerReady = active.any(
      (a) =>
          a.state == wire.StandbyApplicationStateEnum.offered &&
          a.offer?.terms != null &&
          (a.offer?.expiresAt.isAfter(DateTime.now()) ?? false),
    );
    final offered = active.any(
      (a) => a.state == wire.StandbyApplicationStateEnum.offered,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Waitlist'),
        scrolledUnderElevation: 0,
        actions: [
          TextButton(
            onPressed: _busy ? null : _refresh,
            child: const Text('Refresh'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            Text(
              active.isEmpty ? 'Plan your commute' : 'Your request',
              style: AppTypography.heading2.copyWith(
                color: colors.textPrimary,
                letterSpacing: -0.6,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              active.isEmpty
                  ? 'Choose your travel days and route. We will send an offer when we can serve your commute.'
                  : checkoutOpen
                  ? 'Your checkout is open. Complete payment when you are ready.'
                  : offerReady
                  ? 'Your offer is ready. Review it below before it expires.'
                  : offered
                  ? 'Your offer needs attention. Check the details below.'
                  : 'We have your request. We will let you know when an offer is ready.',
              style: AppTypography.body.copyWith(
                color: colors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 22),
            if (_busy) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: 16),
            ],
            if (_error != null) ...[
              _notice(colors.error, Icons.error_outline, _error!),
              const SizedBox(height: 16),
            ],
            if (!eligible && _verification != null) ...[
              _notice(
                colors.actionPrimaryDefault,
                Icons.verified_user_outlined,
                'Verify your phone before joining the waitlist.',
                action: TextButton(
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
              ),
              const SizedBox(height: 16),
            ],
            if (eligible && active.isEmpty) _requestForm(),
            for (final application in active) ...[
              _applicationCard(application),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 16),
            Card(
              margin: EdgeInsets.zero,
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: colors.borderSubtle),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const ExpansionTile(
                title: Text('How offers and renewals work'),
                childrenPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  Text(
                    'An offer shows your journeys, travel days, ride allowance, dates and price before you pay. You can pay for one renewal ahead of time; its rides start when the new coverage begins. Unused rides become credit after the current coverage ends. Card auto-renewal is optional and can be managed in Wallet.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _notice(
    Color accent,
    IconData icon,
    String message, {
    Widget? action,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message, style: AppTypography.bodySmall),
                ?action,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _requestForm() {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        border: Border.all(color: colors.borderSubtle),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Build your request',
            style: AppTypography.title.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            'Joining is free and does not reserve a seat.',
            style: AppTypography.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          DropdownButtonFormField<wire.PurchaseInputPlanEnum>(
            initialValue: _plan,
            decoration: InputDecoration(
              labelText: 'Requested plan',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
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
          const SizedBox(height: 22),
          Text(
            'Travel days',
            style: AppTypography.label.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 4,
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
          const SizedBox(height: 12),
          Material(
            color: Colors.transparent,
            child: CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _useCredit,
              onChanged: _busy
                  ? null
                  : (v) => setState(() => _useCredit = v ?? false),
              title: const Text('Use available ride credit'),
              subtitle: const Text('Applied only if you accept an offer.'),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 54,
            child: FilledButton(
              onPressed: _busy || _travelDays.isEmpty ? null : _join,
              child: const Text('Choose a route'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _applicationCard(wire.StandbyApplication application) {
    final colors = context.appColors;
    final offer = application.offer;
    final offerCurrent =
        offer != null && offer.expiresAt.isAfter(DateTime.now());
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        border: Border.all(color: colors.borderSubtle),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: colors.actionPrimaryDefault.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _status(application.state),
              style: AppTypography.caption.copyWith(
                color: colors.actionPrimaryDefault,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            application.routeName,
            style: AppTypography.title.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            '${application.selection.plan.name == 'annual' ? 'Annual' : 'Monthly'} plan',
            style: AppTypography.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
          Text(
            application.travelDays.map((day) => _dayNames[day - 1]).join(', '),
            style: AppTypography.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
          if (offer != null) ...[
            const SizedBox(height: 12),
            Text(
              'Offer available until ${DateFormat('d MMM, h:mm a').format(offer.expiresAt.toLocal())}',
              style: AppTypography.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
          if (application.state == wire.StandbyApplicationStateEnum.offered &&
              offer?.terms != null &&
              offerCurrent) ...[
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _busy ? null : () => _accept(application),
                child: const Text('Review your offer'),
              ),
            ),
          ],
          if (offer != null &&
              offer.terms == null &&
              application.state == wire.StandbyApplicationStateEnum.offered)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text(
                'This older offer has no agreed price. Leave the waitlist and submit a new request.',
              ),
            ),
          if (application.state == wire.StandbyApplicationStateEnum.offered &&
              !offerCurrent)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text(
                'This offer has expired. Leave the waitlist to choose a route again.',
              ),
            ),
          if (application.state == wire.StandbyApplicationStateEnum.submitted ||
              application.state == wire.StandbyApplicationStateEnum.offered)
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
    );
  }
}
