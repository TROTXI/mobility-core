import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trotxi_client/trotxi_client.dart' as wire;
import 'package:trotxi_commuter/core/api/commuter_api.dart';
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
    final renewal = _renewal;
    final card = renewal?.card;
    final upcoming = renewal?.upcoming;
    return Scaffold(
      appBar: AppBar(title: const Text('Card auto-renewal')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: RefreshIndicator(
            onRefresh: _load,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'You are in control',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Card auto-renewal is optional. It does not apply to mobile '
                  'money payments. Turning it off does not cancel coverage '
                  'you have already paid for.',
                ),
                const SizedBox(height: 20),
                if (_loading) const LinearProgressIndicator(),
                if (_error != null) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(_error!),
                    ),
                  ),
                  TextButton(onPressed: _load, child: const Text('Retry')),
                ],
                if (!_loading && renewal != null) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            renewal.enabled ? 'On' : 'Off',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            card == null
                                ? renewal.enabled
                                      ? 'No card is saved yet. Pay an eligible '
                                            'offer by card to activate automatic renewal.'
                                      : 'No reusable card is saved.'
                                : '${card.brand} ending ${card.last4} · '
                                      'expires ${card.expMonth.toString().padLeft(2, '0')}/${card.expYear}',
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: _busy ? null : _toggle,
                            child: Text(
                              renewal.enabled
                                  ? 'Turn off auto-renewal'
                                  : 'Turn on auto-renewal',
                            ),
                          ),
                          if (card != null)
                            TextButton(
                              onPressed: _busy ? null : _removeCard,
                              child: const Text('Remove saved card'),
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (upcoming != null) ...[
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Next renewal',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(_upcomingState(upcoming.state)),
                            Text('Package price: ${upcoming.price.formatted}'),
                            Text(
                              'Coverage ends: ${_date(upcoming.periodEndsAt)}',
                            ),
                            Text(
                              'Charge may start: ${_date(upcoming.chargeFrom)}',
                            ),
                            if (upcoming.nextAttemptAt case final retry?)
                              Text('Next attempt: ${_date(retry)}'),
                            if (upcoming.failureCode != null)
                              const Text(
                                'Review this renewal with operations.',
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Text(
                    'If the fare or route changes, automatic charging stops '
                    'and you will need a new Ops offer. Ride Credit can '
                    'reduce the amount charged. You can refresh this page to '
                    'check the latest status.',
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
