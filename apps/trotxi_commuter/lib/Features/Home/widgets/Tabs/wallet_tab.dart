import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trotxi_client_next/trotxi_client_next.dart' as wire;
import 'package:trotxi_commuter/core/api/commuter_api.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';
import 'package:trotxi_commuter/core/config/theme/app_typography.dart';

class WalletTab extends StatefulWidget {
  const WalletTab({super.key, required this.client});
  final CommuterApi client;
  @override
  State<WalletTab> createState() => _WalletTabState();
}

class _WalletTabState extends State<WalletTab> {
  wire.Membership? _membership;
  List<wire.Purchase> _purchases = [];
  Object? _error;
  bool _loading = true;
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
    final generation = widget.client.sessionGeneration;
    try {
      final membership = await widget.client.membership();
      final now = DateTime.now().toUtc(),
          start = DateTime.now().toUtc().subtract(const Duration(days: 90));
      final purchases = await widget.client.purchases(
        from: wire.Date(start.year, start.month, start.day),
        to: wire.Date(now.year, now.month, now.day),
      );
      widget.client.ensureSession(generation);
      if (mounted) {
        setState(() {
          _membership = membership;
          _purchases = purchases;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _money(wire.Money value) =>
      '${value.currency.name} ${(value.amountMinor / 100).toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final membership = _membership;
    final coverage = membership?.coverage;
    return Scaffold(
      backgroundColor: colors.backgroundDefault,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Wallet',
                    style: AppTypography.title.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_loading)
                    const Center(child: CircularProgressIndicator())
                  else if (_error != null) ...[
                    Text(
                      _error is TrotxiException
                          ? (_error as TrotxiException).message
                          : 'Could not load your wallet.',
                    ),
                    TextButton(
                      onPressed: _load,
                      child: const Text('Try again'),
                    ),
                  ] else if (membership != null) ...[
                    _card('Rides remaining', [
                      Text(
                        '${membership.entitlements.remainingRides}',
                        style: AppTypography.display,
                      ),
                      const Text(
                        'Rides and monetary Ride Credit are separate balances.',
                      ),
                    ]),
                    _card('Ride Credit', [
                      Text(
                        'Available: ${_money(membership.entitlements.availableCredit)}',
                      ),
                      Text(
                        'Held for checkout: ${_money(membership.entitlements.heldCredit)}',
                      ),
                      Text('Total: ${_money(membership.entitlements.credit)}'),
                      const Text(
                        'Eligible credit is applied when you check out.',
                      ),
                    ]),
                    _card('Membership', [
                      Text(
                        membership.commute?.routeName ?? 'No assigned commute',
                      ),
                      Text(
                        coverage == null
                            ? 'No current coverage'
                            : 'Coverage: ${coverage.state.name}',
                      ),
                      if (coverage != null)
                        Text(
                          coverage.paused
                              ? 'Paused — coverage end will change on resume'
                              : coverage.endsAt == null
                              ? 'Coverage end unavailable'
                              : 'Coverage ends ${DateFormat('d MMM y').format(coverage.endsAt!.toUtc())}',
                        ),
                      if (coverage == null &&
                          membership.lastCoverageEndedAt != null)
                        Text(
                          'Last coverage ended ${DateFormat('d MMM y').format(membership.lastCoverageEndedAt!.toUtc())}',
                        ),
                      const Text(
                        'Renewal requires a new checkout. No automatic charge is enabled.',
                      ),
                      for (final block in membership.access.blocks)
                        Text(switch (block.kind) {
                          wire.AccessBlockKindEnum.paused => 'Service paused',
                          wire.AccessBlockKindEnum.dispute =>
                            'Payment dispute — contact operations',
                          _ => 'Account restriction — contact operations',
                        }),
                    ]),
                    _card('Recent purchases · last 90 days', [
                      if (_purchases.isEmpty)
                        const Text('No purchases in this period.'),
                      for (final purchase in _purchases)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            '${purchase.plan.name} · ${_money(purchase.price)}',
                          ),
                          subtitle: Text(
                            'Purchase: ${purchase.state.name}\nCollection: ${purchase.collectionState.name}\nCash due: ${_money(purchase.cashDue)}',
                          ),
                          trailing: IconButton(
                            tooltip: 'Refresh purchase',
                            icon: const Icon(Icons.refresh),
                            onPressed: () async {
                              try {
                                final updated = await widget.client.purchase(
                                  purchase.id,
                                );
                                if (mounted) {
                                  setState(
                                    () => _purchases = [
                                      for (final p in _purchases)
                                        p.id == updated.id ? updated : p,
                                    ],
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        e is TrotxiException
                                            ? e.message
                                            : 'Could not refresh purchase.',
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                    ]),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _card(String title, List<Widget> children) => Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: context.appColors.surfaceElevated,
      border: Border.all(color: context.appColors.borderSubtle),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.label),
        const SizedBox(height: 12),
        ...children,
      ],
    ),
  );
}
