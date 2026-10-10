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
    wire.StandbyApplicationStateEnum.submitted => 'On the waitlist',
    wire.StandbyApplicationStateEnum.offered => 'Offer ready',
    wire.StandbyApplicationStateEnum.checkoutOpen => 'Payment pending',
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
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: context.appColors.surfaceElevated,
      builder: (sheetContext) => _offerReviewSheet(sheetContext, terms),
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
      await showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        backgroundColor: context.appColors.surfaceElevated,
        builder: (sheetContext) => _checkoutPrompt(sheetContext, purchase, uri),
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

  Widget _offerReviewSheet(
    BuildContext sheetContext,
    wire.OpsPurchaseOfferTerms terms,
  ) {
    final colors = sheetContext.appColors;
    final price = 'GHS ${(terms.price.amountMinor / 100).toStringAsFixed(2)}';
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(sheetContext).height * 0.82,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Review your offer',
                style: AppTypography.heading3.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Check the journeys, allowance and credit before accepting.',
                style: AppTypography.bodySmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: colors.surfaceStrong,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Package price',
                              style: AppTypography.bodySmall.copyWith(
                                color: colors.onSurfaceStrong.withValues(
                                  alpha: 0.72,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              price,
                              style: AppTypography.heading2.copyWith(
                                color: colors.onSurfaceStrong,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Coverage: ${_coverage(terms.coverageStart, terms.coverageEnd)}',
                              style: AppTypography.bodySmall.copyWith(
                                color: colors.onSurfaceStrong,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      for (final leg in terms.legs) ...[
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: colors.backgroundSubtle,
                            border: Border.all(color: colors.borderSubtle),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                leg.direction.name == 'return_'
                                    ? 'Return journey'
                                    : 'Outbound journey',
                                style: AppTypography.caption.copyWith(
                                  color: colors.actionPrimaryDefault,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${leg.pickupName} → ${leg.dropoffName}',
                                style: AppTypography.title.copyWith(
                                  color: colors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${leg.ridesGranted} rides · ${leg.travelDays.map((d) => _dayNames[d - 1]).join(', ')}',
                                style: AppTypography.bodySmall.copyWith(
                                  color: colors.textSecondary,
                                ),
                              ),
                              Text(
                                'Journey fare: GHS ${(leg.fare.amountMinor / 100).toStringAsFixed(2)}',
                                style: AppTypography.bodySmall.copyWith(
                                  color: colors.textSecondary,
                                ),
                              ),
                              Text(
                                'Credit per unused ride: GHS ${(leg.creditPerUnusedRide.amountMinor / 100).toStringAsFixed(2)}',
                                style: AppTypography.bodySmall.copyWith(
                                  color: colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        'Before you continue',
                        style: AppTypography.label.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Outbound and return rides have separate allowances. Unused rides become the credit shown above after coverage ends. A paid plan does not reserve a seat; each trip still needs confirmation and an available seat.',
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rides start on the coverage date. During a pending renewal, pauses and commute changes are unavailable. You will review the final amount due before confirming payment on Paystack.',
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed: () => Navigator.pop(sheetContext, true),
                  child: const Text('Accept and review payment'),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(sheetContext, false),
                child: const Text('Not now'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _checkoutPrompt(
    BuildContext sheetContext,
    wire.Purchase purchase,
    Uri? uri,
  ) {
    final colors = sheetContext.appColors;
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.82,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Ready for payment',
                style: AppTypography.heading3.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Amount due',
                style: AppTypography.bodySmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              Text(
                '${purchase.cashDue.currency.name} ${(purchase.cashDue.amountMinor / 100).toStringAsFixed(2)}',
                style: AppTypography.heading2.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'You are not charged until you confirm on Paystack. You can come back to this payment later.',
                style: AppTypography.bodySmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              if (uri != null)
                SizedBox(
                  height: 52,
                  child: FilledButton(
                    onPressed: () async {
                      Navigator.pop(sheetContext);
                      await openPaystackCheckout(uri);
                    },
                    child: const Text('Continue to Paystack'),
                  ),
                ),
              TextButton(
                onPressed: () => Navigator.pop(sheetContext),
                child: const Text('Later'),
              ),
            ],
          ),
        ),
      ),
    );
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Waitlist'),
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            tooltip: 'Refresh waitlist',
            onPressed: _busy ? null : _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      bottomNavigationBar: eligible && active.isEmpty
          ? SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: SizedBox(
                  height: 54,
                  child: FilledButton(
                    onPressed: _busy || _travelDays.isEmpty ? null : _join,
                    child: const Text('Choose a route'),
                  ),
                ),
              ),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            _hero(active),
            const SizedBox(height: 20),
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
            const SizedBox(height: 20),
            _howItWorks(),
          ],
        ),
      ),
    );
  }

  Widget _hero(List<wire.StandbyApplication> active) {
    final colors = context.appColors;
    final hasOffer = active.any(
      (a) =>
          a.state == wire.StandbyApplicationStateEnum.offered &&
          a.offer?.terms != null &&
          (a.offer?.expiresAt.isAfter(DateTime.now()) ?? false),
    );
    final checkoutOpen = active.any(
      (a) => a.state == wire.StandbyApplicationStateEnum.checkoutOpen,
    );
    final expiredOffer = active.any(
      (a) =>
          a.state == wire.StandbyApplicationStateEnum.offered &&
          (a.offer?.expiresAt.isBefore(DateTime.now()) ?? false),
    );
    final title = active.isEmpty
        ? 'A commute that fits your week'
        : checkoutOpen
        ? 'Your payment is ready'
        : hasOffer
        ? 'Your offer is here'
        : expiredOffer
        ? 'Your offer has expired'
        : 'We have your request';
    final description = active.isEmpty
        ? 'Tell us when and where you travel. We will send a price for you to review.'
        : checkoutOpen
        ? 'You can finish paying from your payment history.'
        : hasOffer
        ? 'Review the journeys, dates and price before deciding.'
        : expiredOffer
        ? 'You can leave the waitlist and start a new request.'
        : 'We will let you know when we can offer your commute.';
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surfaceStrong,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            active.isEmpty
                ? Icons.route_outlined
                : Icons.directions_bus_outlined,
            color: colors.onSurfaceStrong,
            size: 26,
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: AppTypography.heading3.copyWith(
              color: colors.onSurfaceStrong,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: AppTypography.bodySmall.copyWith(
              color: colors.onSurfaceStrong.withValues(alpha: 0.82),
            ),
          ),
        ],
      ),
    );
  }

  Widget _howItWorks() {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What happens next',
          style: AppTypography.title.copyWith(color: colors.textPrimary),
        ),
        const SizedBox(height: 14),
        _nextStep(
          Icons.schedule_outlined,
          'Tell us your travel days and route',
        ),
        _nextStep(
          Icons.local_offer_outlined,
          'Review an offer when it arrives',
        ),
        _nextStep(Icons.lock_outline, 'Pay only when you accept'),
        const SizedBox(height: 6),
        Text(
          'Joining is free. An offer does not reserve a seat; confirm each trip after your plan starts.',
          style: AppTypography.caption.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }

  Widget _nextStep(IconData icon, String text) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colors.actionPrimaryDefault),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodySmall.copyWith(
                color: colors.textPrimary,
              ),
            ),
          ),
        ],
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
        color: colors.backgroundSubtle,
        border: Border.all(color: colors.borderSubtle),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Your travel plans',
            style: AppTypography.title.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            'Start with the days you need a ride.',
            style: AppTypography.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Which days do you travel?',
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
          if (_travelDays.isEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Select at least one day to continue.',
              style: AppTypography.caption.copyWith(color: colors.error),
            ),
          ],
          const SizedBox(height: 24),
          Text(
            'How long do you plan to travel?',
            style: AppTypography.label.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<wire.PurchaseInputPlanEnum>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                  value: wire.PurchaseInputPlanEnum.monthly,
                  label: Text('Monthly'),
                ),
                ButtonSegment(
                  value: wire.PurchaseInputPlanEnum.annual,
                  label: Text('Annual'),
                ),
              ],
              selected: {_plan},
              onSelectionChanged: _busy
                  ? null
                  : (selection) => setState(() => _plan = selection.first),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We will show the exact dates, rides and price in your offer.',
            style: AppTypography.caption.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: 20),
          Material(
            color: Colors.transparent,
            child: SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: _useCredit,
              onChanged: _busy
                  ? null
                  : (value) => setState(() => _useCredit = value),
              title: Text(
                'Use my ride credit',
                style: AppTypography.bodySmall.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Any available credit reduces the final amount you pay.',
                style: AppTypography.caption.copyWith(
                  color: colors.textSecondary,
                ),
              ),
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
          Row(
            children: [
              Icon(
                application.state == wire.StandbyApplicationStateEnum.submitted
                    ? Icons.hourglass_top_outlined
                    : Icons.local_offer_outlined,
                color: colors.actionPrimaryDefault,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  application.state ==
                              wire.StandbyApplicationStateEnum.offered &&
                          !offerCurrent
                      ? 'Offer expired'
                      : _status(application.state),
                  style: AppTypography.label.copyWith(
                    color: colors.actionPrimaryDefault,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            application.routeName,
            style: AppTypography.title.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _metadataPill(
                Icons.event_outlined,
                '${application.selection.plan.name == 'annual' ? 'Annual' : 'Monthly'} plan',
              ),
              _metadataPill(
                Icons.calendar_today_outlined,
                application.travelDays
                    .map((day) => _dayNames[day - 1])
                    .join(', '),
              ),
            ],
          ),
          if (offer?.terms != null && offerCurrent) ...[
            const SizedBox(height: 16),
            Text(
              'Offer price · GHS ${(offer.terms!.price.amountMinor / 100).toStringAsFixed(2)}',
              style: AppTypography.bodySmall.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          if (offer != null && offerCurrent) ...[
            const SizedBox(height: 6),
            Text(
              'Review by ${DateFormat('d MMM, h:mm a').format(offer.expiresAt.toLocal())}',
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
              application.state == wire.StandbyApplicationStateEnum.offered &&
              offerCurrent)
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
                'This offer can no longer be accepted. Start a new request to receive an updated price.',
              ),
            ),
          if (application.state == wire.StandbyApplicationStateEnum.submitted ||
              application.state == wire.StandbyApplicationStateEnum.offered)
            TextButton(
              onPressed: _busy ? null : () => _withdraw(application),
              child: Text(
                offer != null && !offerCurrent
                    ? 'Start a new request'
                    : 'Cancel request',
              ),
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
              child: const Text('Continue to payment'),
            ),
        ],
      ),
    );
  }

  Widget _metadataPill(IconData icon, String text) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colors.backgroundSubtle,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colors.textSecondary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: AppTypography.caption.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
