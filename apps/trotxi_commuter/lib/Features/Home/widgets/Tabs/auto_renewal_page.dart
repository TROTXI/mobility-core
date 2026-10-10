import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trotxi_client/trotxi_client.dart' as wire;
import 'package:trotxi_commuter/core/api/commuter_api.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';
import 'package:trotxi_commuter/core/config/theme/app_typography.dart';
import 'package:trotxi_commuter/core/utils/money_format.dart';

class AutoRenewalPage extends StatefulWidget {
  const AutoRenewalPage({super.key, required this.client});

  final CommuterApi client;

  @override
  State<AutoRenewalPage> createState() => _AutoRenewalPageState();
}

class _AutoRenewalPageState extends State<AutoRenewalPage> {
  wire.AutoRenewal? _renewal;
  bool _loading = true;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final generation = widget.client.sessionGeneration;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final renewal = await widget.client.autoRenewal();
      widget.client.ensureSession(generation);
      if (mounted) setState(() => _renewal = renewal);
    } catch (error) {
      if (mounted && generation == widget.client.sessionGeneration) {
        setState(() => _error = _message(error));
      }
    } finally {
      if (mounted && generation == widget.client.sessionGeneration) {
        setState(() => _loading = false);
      }
    }
  }

  String _message(Object error) => error is wire.TrotxiException
      ? error.message
      : 'Could not update auto-renewal. Please retry.';

  Future<bool> _confirm({
    required String title,
    required String explanation,
    required String action,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(explanation),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Keep current setting'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(action),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _toggle() async {
    final current = _renewal;
    if (_busy || current == null) return;
    final generation = widget.client.sessionGeneration;
    final enabling = !current.enabled;
    final agreed = await _confirm(
      title: enabling ? 'Allow card auto-renewal?' : 'Turn off auto-renewal?',
      explanation: enabling
          ? 'This does not save a card or charge you now. If you later pay an '
                'offer with a supported card, Trotxi may save it for renewal. '
                'A renewal can be charged from three days before your '
                'coverage ends, for the same journeys, travel days and '
                'package price. If those terms change, we will ask you to '
                'review a new offer instead. You can turn this off or remove '
                'the card before a renewal charge. Mobile money is never '
                'charged automatically.'
          : 'No further renewal charges will be scheduled. Your paid '
                'coverage remains unchanged, and any saved card stays on this '
                'account until you remove it.',
      action: enabling ? 'Allow auto-renewal' : 'Turn off',
    );
    if (!agreed || !mounted || generation != widget.client.sessionGeneration) {
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final result = await widget.client.setAutoRenewal(enabling);
      widget.client.ensureSession(generation);
      if (mounted) setState(() => _renewal = result);
    } catch (error) {
      if (mounted && generation == widget.client.sessionGeneration) {
        await _load();
        if (mounted && generation == widget.client.sessionGeneration) {
          setState(
            () => _error =
                '${_message(error)} Check the current setting before retrying.',
          );
        }
      }
    } finally {
      if (mounted && generation == widget.client.sessionGeneration) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _removeCard() async {
    if (_busy || _renewal?.card == null) return;
    final generation = widget.client.sessionGeneration;
    final agreed = await _confirm(
      title: 'Remove saved card?',
      explanation:
          'This deletes Trotxi’s reusable card authorization and '
          'turns off future auto-renewal charges. Paid coverage is not '
          'cancelled. Paystack may retain separate payment records.',
      action: 'Remove card',
    );
    if (!agreed || !mounted || generation != widget.client.sessionGeneration) {
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.client.removeAutoRenewalCard();
      widget.client.ensureSession(generation);
      await _load();
    } catch (error) {
      if (mounted && generation == widget.client.sessionGeneration) {
        await _load();
        if (mounted && generation == widget.client.sessionGeneration) {
          setState(
            () => _error =
                '${_message(error)} Check the saved-card status before retrying.',
          );
        }
      }
    } finally {
      if (mounted && generation == widget.client.sessionGeneration) {
        setState(() => _busy = false);
      }
    }
  }

  String _date(DateTime date) => DateFormat('d MMM y').format(date.toUtc());

  String _upcomingState(wire.AutoRenewalUpcomingStateEnum state) {
    return switch (state) {
      wire.AutoRenewalUpcomingStateEnum.scheduled => 'Scheduled',
      wire.AutoRenewalUpcomingStateEnum.reminded => 'Reminder sent',
      wire.AutoRenewalUpcomingStateEnum.charging => 'Payment in progress',
      wire.AutoRenewalUpcomingStateEnum.failed => 'Payment needs attention',
      wire.AutoRenewalUpcomingStateEnum.needsOffer => 'A new offer is required',
      _ => 'Needs review',
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final renewal = _renewal;
    final card = renewal?.card;
    final upcoming = renewal?.upcoming;
    final waitingForCard = renewal?.enabled == true && card == null;
    final status = renewal == null
        ? ''
        : waitingForCard
        ? 'Waiting for a card'
        : renewal.enabled
        ? 'On'
        : 'Off';
    return Scaffold(
      appBar: AppBar(title: const Text('Card auto-renewal')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: RefreshIndicator(
            onRefresh: _load,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              children: [
                Text(
                  'Choose how you renew',
                  style: AppTypography.heading2.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Automatic renewal is optional and only works with a saved card. You stay in control.',
                  style: AppTypography.body.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                if (_loading) ...[
                  const LinearProgressIndicator(),
                  const SizedBox(height: 16),
                ],
                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _error!,
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  TextButton(onPressed: _load, child: const Text('Retry')),
                  const SizedBox(height: 12),
                ],
                if (!_loading && renewal != null) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colors.surfaceElevated,
                      border: Border.all(color: colors.borderSubtle),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.credit_card_rounded,
                              color: colors.actionPrimaryDefault,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Automatic renewal',
                                style: AppTypography.title.copyWith(
                                  color: colors.textPrimary,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: renewal.enabled && card != null
                                    ? colors.actionPrimaryDefault.withValues(
                                        alpha: 0.1,
                                      )
                                    : colors.backgroundSubtle,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                status,
                                style: AppTypography.caption.copyWith(
                                  color: renewal.enabled && card != null
                                      ? colors.actionPrimaryDefault
                                      : colors.textSecondary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          card == null
                              ? renewal.enabled
                                    ? 'You have allowed auto-renewal, but it is not ready yet. Pay your next offer by card to complete setup.'
                                    : 'No card is saved. Turning this on will not charge you or save a card today.'
                              : '${card.brand} ending ${card.last4} · expires ${card.expMonth.toString().padLeft(2, '0')}/${card.expYear}',
                          style: AppTypography.bodySmall.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          height: 50,
                          child: renewal.enabled
                              ? OutlinedButton(
                                  onPressed: _busy ? null : _toggle,
                                  child: const Text('Turn off auto-renewal'),
                                )
                              : FilledButton(
                                  onPressed: _busy ? null : _toggle,
                                  child: Text(
                                    card == null
                                        ? 'Allow future card renewals'
                                        : 'Turn on auto-renewal',
                                  ),
                                ),
                        ),
                        if (card != null) ...[
                          const SizedBox(height: 4),
                          TextButton(
                            onPressed: _busy ? null : _removeCard,
                            child: const Text('Remove saved card'),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'How it works',
                    style: AppTypography.title.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _step(
                    context,
                    Icons.credit_card_outlined,
                    'Pay an offer by card',
                    'We can save a supported card only after you make a card payment.',
                  ),
                  _step(
                    context,
                    Icons.notifications_outlined,
                    'Get a reminder first',
                    'We email you the amount and card five days before coverage ends.',
                  ),
                  _step(
                    context,
                    Icons.event_repeat_outlined,
                    'Renew on matching terms',
                    'Charging can start three days before coverage ends. If the fare or route changes, you review a new offer instead.',
                  ),
                  if (upcoming != null) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Next renewal',
                      style: AppTypography.title.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: colors.surfaceElevated,
                        border: Border.all(color: colors.borderSubtle),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _upcomingState(upcoming.state),
                            style: AppTypography.label.copyWith(
                              color: colors.actionPrimaryDefault,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _detailRow(
                            context,
                            'Package price',
                            upcoming.price.formatted,
                          ),
                          const SizedBox(height: 10),
                          _detailRow(
                            context,
                            'Coverage ends',
                            _date(upcoming.periodEndsAt),
                          ),
                          const SizedBox(height: 10),
                          _detailRow(
                            context,
                            'Earliest charge',
                            _date(upcoming.chargeFrom),
                          ),
                          if (upcoming.nextAttemptAt case final retry?) ...[
                            const SizedBox(height: 10),
                            _detailRow(context, 'Next attempt', _date(retry)),
                          ],
                          if (upcoming.failureCode != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              'This renewal needs a review. Contact support before trying again.',
                              style: AppTypography.bodySmall.copyWith(
                                color: colors.warning,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    'Mobile money is never charged automatically. Turning this off does not affect coverage you have already paid for.',
                    style: AppTypography.caption.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(BuildContext context, String label, String value) {
    final colors = context.appColors;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: AppTypography.label.copyWith(color: colors.textPrimary),
        ),
      ],
    );
  }

  Widget _step(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colors.actionPrimaryDefault.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 19, color: colors.actionPrimaryDefault),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.label.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
