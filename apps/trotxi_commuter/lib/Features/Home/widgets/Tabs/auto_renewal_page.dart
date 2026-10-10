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
      title: enabling ? 'Turn on card auto-renewal?' : 'Turn off auto-renewal?',
      explanation: enabling
          ? 'If you make an eligible card payment, Trotxi can save that card '
                'and charge it for the same journeys and travel days from '
                'three days before coverage ends. The current package price '
                'applies unless the fare or service changes. You can turn this '
                'off or remove the card before the charge. Mobile money is '
                'never charged automatically.'
          : 'No further renewal charges will be scheduled. Your paid '
                'coverage remains unchanged, and any saved card stays on this '
                'account until you remove it.',
      action: enabling ? 'Turn on' : 'Turn off',
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
    return Scaffold(
      appBar: AppBar(title: const Text('Card auto-renewal')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: RefreshIndicator(
            onRefresh: _load,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              children: [
                Text(
                  'Renew on your terms',
                  style: AppTypography.heading2.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Decide whether an eligible card payment can renew your commute. Mobile money is never charged automatically.',
                  style: AppTypography.body.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
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
                                'Card auto-renewal',
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
                                color: renewal.enabled
                                    ? colors.actionPrimaryDefault.withValues(
                                        alpha: 0.1,
                                      )
                                    : colors.backgroundSubtle,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                renewal.enabled ? 'On' : 'Off',
                                style: AppTypography.caption.copyWith(
                                  color: renewal.enabled
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
                                    ? 'No card is saved yet. Pay an eligible offer by card to make auto-renewal available.'
                                    : 'No reusable card is saved.'
                              : '${card.brand} ending ${card.last4} · expires ${card.expMonth.toString().padLeft(2, '0')}/${card.expYear}',
                          style: AppTypography.bodySmall.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          height: 50,
                          child: FilledButton(
                            onPressed: _busy ? null : _toggle,
                            child: Text(
                              renewal.enabled
                                  ? 'Turn off auto-renewal'
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
                  const SizedBox(height: 20),
                  Text(
                    'If your route or price changes, we will ask you to review a new offer. Turning auto-renewal off does not affect coverage you already paid for.',
                    style: AppTypography.bodySmall.copyWith(
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
}
