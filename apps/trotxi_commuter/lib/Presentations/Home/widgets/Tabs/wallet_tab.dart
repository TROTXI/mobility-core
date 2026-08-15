import 'package:flutter/material.dart';
import 'package:trotxi_client/trotxi_client.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';

// ---------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------

enum TransactionStatus { completed, pending, failed }

class WalletTransaction {
  const WalletTransaction({
    required this.title,
    required this.dateTime,
    required this.amount,
    required this.isCredit,
    required this.status,
    required this.icon,
    required this.iconBackground,
  });

  final String title;
  final String dateTime;
  final double amount;
  final bool isCredit;
  final TransactionStatus status;
  final IconData icon;
  final Color iconBackground;

  String get formattedAmount =>
      '${isCredit ? '+' : '-'}GHS ${amount.toStringAsFixed(2)}';

  String get statusLabel {
    switch (status) {
      case TransactionStatus.completed:
        return 'COMPLETED';
      case TransactionStatus.pending:
        return 'PENDING';
      case TransactionStatus.failed:
        return 'FAILED';
    }
  }
}

class WalletSubscription {
  const WalletSubscription({
    required this.name,
    required this.expiryDate,
    required this.isActive,
  });

  final String name;
  final String expiryDate;
  final bool isActive;
}

// ---------------------------------------------------------------------
// Page
// ---------------------------------------------------------------------

class WalletTab extends StatefulWidget {
  const WalletTab({super.key, required this.client});

  final TrotxiApiClient client;

  @override
  State<WalletTab> createState() => _WalletTabState();
}

class _WalletTabState extends State<WalletTab> {
  // Colors from the design that don't have AppColors tokens yet.
  static const _gradientStart = Color(0xFF006B3F);
  static const _gradientEnd = Color(0xFF008751);
  static const _activeBadgeColor = Color(0xFF006B3F);
  static const _cardBorder = Color(0xFFBDCABE);
  static const _debitColor = Color(0xFFBA1A1A);
  static const _creditColor = Color(0xFF006B3F);
  static const _rideIconBackground = Color(0xFFDCE9FF);
  static const _topUpIconBackground = Color(0x4C8DF8B7);

  @override
  void initState() {
    super.initState();
    // TODO: use widget.client to fetch the real wallet balance,
    // subscription, and transaction history, e.g.:
    //   final walletApi = widget.client.getWalletApi();
    //   final response = await walletApi.walletGet();
    // and replace the hardcoded values below with the response.
  }

  // TODO: replace with real balance/subscription/transaction data from
  // your wallet API once it's wired up.
  final double _balance = 450.00;

  final WalletSubscription _subscription = const WalletSubscription(
    name: 'Premium Pass',
    expiryDate: '24 Oct 2026',
    isActive: true,
  );

  final List<WalletTransaction> _transactions = const [
    WalletTransaction(
      title: 'Ride: Accra Mall - Tema',
      dateTime: 'Oct 12 • 08:45 AM',
      amount: 4.50,
      isCredit: false,
      status: TransactionStatus.completed,
      icon: Icons.directions_car_rounded,
      iconBackground: _rideIconBackground,
    ),
    WalletTransaction(
      title: 'Top-up (Premium)',
      dateTime: 'Oct 10 • 14:20 PM',
      amount: 50.00,
      isCredit: true,
      status: TransactionStatus.completed,
      icon: Icons.account_balance_wallet_rounded,
      iconBackground: _topUpIconBackground,
    ),
    WalletTransaction(
      title: 'Ride: Tema - Accra Mall',
      dateTime: 'Oct 09 • 17:30 PM',
      amount: 6.00,
      isCredit: false,
      status: TransactionStatus.completed,
      icon: Icons.directions_car_rounded,
      iconBackground: _rideIconBackground,
    ),
  ];

  void _onTopUp() {
    // TODO: navigate to / open the top-up flow.
    debugPrint('Top Up tapped');
  }

  void _onViewLogs() {
    // TODO: navigate to the full transaction logs page.
    debugPrint('Logs tapped');
  }

  void _onViewAllTransactions() {
    // TODO: navigate to the full transactions list.
    debugPrint('View All tapped');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 576),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              children: [
                _buildBalanceCard(),
                const SizedBox(height: 24),
                _buildSubscriptionSection(),
                const SizedBox(height: 24),
                _buildTransactionsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Balance card
  // ---------------------------------------------------------------------

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        gradient: const LinearGradient(
          begin: Alignment(0.11, -0.18),
          end: Alignment(0.89, 1.18),
          colors: [AppColors.primary, AppColors.primary],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        shadows: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Faint decorative watermark icon, matching the low-opacity
          // graphic in the design.
          Positioned(
            right: -16,
            bottom: -16,
            child: Opacity(
              opacity: 0.10,
              child: Icon(
                Icons.account_balance_wallet_rounded,
                size: 160,
                color: Colors.white,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Opacity(
                opacity: 0.90,
                child: const Text(
                  'CURRENT BALANCE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontFamily: 'JetBrains Mono',
                    fontWeight: FontWeight.w600,
                    height: 1.33,
                    letterSpacing: 0.60,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'GHS ${_balance.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontFamily: 'Hanken Grotesk',
                  fontWeight: FontWeight.w800,
                  height: 1.17,
                  letterSpacing: -0.96,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildPillButton(
                    label: 'Top Up',
                    icon: Icons.add_rounded,
                    background: Colors.white.withValues(alpha: 0.20),
                    border: Colors.white.withValues(alpha: 0.30),
                    onTap: _onTopUp,
                  ),
                  const SizedBox(width: 16),
                  _buildPillButton(
                    label: 'Logs',
                    icon: Icons.receipt_long_rounded,
                    background: Colors.white.withValues(alpha: 0.10),
                    border: Colors.white.withValues(alpha: 0.10),
                    onTap: _onViewLogs,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPillButton({
    required String label,
    required IconData icon,
    required Color background,
    required Color border,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: ShapeDecoration(
            color: background,
            shape: RoundedRectangleBorder(
              side: BorderSide(width: 1, color: border),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 1.50,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Active subscription
  // ---------------------------------------------------------------------

  Widget _buildSubscriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Active Subscription',
          style: TextStyle(
            color: AppColors.dark,
            fontSize: 24,
            fontFamily: 'Hanken Grotesk',
            fontWeight: FontWeight.w700,
            height: 1.33,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1, color: _cardBorder),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: ShapeDecoration(
                      color: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Icon(
                      Icons.workspace_premium_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _subscription.name,
                        style: const TextStyle(
                          color: AppColors.dark,
                          fontSize: 18,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          height: 1.33,
                        ),
                      ),
                      Text(
                        'Expires: ${_subscription.expiryDate}',
                        style: const TextStyle(
                          color: AppColors.body,
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          height: 1.43,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (_subscription.isActive) _buildActiveBadge(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActiveBadge() {
    return Container(
      padding: const EdgeInsets.only(top: 10, left: 12, right: 12, bottom: 6),
      decoration: ShapeDecoration(
        color: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text(
        'ACTIVE',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontFamily: 'JetBrains Mono',
          fontWeight: FontWeight.w600,
          height: 1.33,
          letterSpacing: 0.60,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Recent transactions
  // ---------------------------------------------------------------------

  Widget _buildTransactionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Transactions',
              style: TextStyle(
                color: AppColors.dark,
                fontSize: 24,
                fontFamily: 'Hanken Grotesk',
                fontWeight: FontWeight.w700,
                height: 1.33,
              ),
            ),
            GestureDetector(
              onTap: _onViewAllTransactions,
              child: const Text(
                'View All',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 1.43,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Column(
          children: [
            for (int i = 0; i < _transactions.length; i++) ...[
              _buildTransactionTile(_transactions[i]),
              if (i != _transactions.length - 1) const SizedBox(height: 4),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildTransactionTile(WalletTransaction transaction) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: _cardBorder),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: ShapeDecoration(
                    color: transaction.iconBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Icon(
                    transaction.icon,
                    size: 20,
                    color: AppColors.dark,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.title,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.dark,
                          fontSize: 16,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          height: 1.50,
                        ),
                      ),
                      Text(
                        transaction.dateTime,
                        style: const TextStyle(
                          color: AppColors.body,
                          fontSize: 14,
                          fontFamily: 'JetBrains Mono',
                          fontWeight: FontWeight.w400,
                          height: 1.43,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                transaction.formattedAmount,
                style: TextStyle(
                  color: transaction.isCredit ? _creditColor : _debitColor,
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 1.50,
                ),
              ),
              Text(
                transaction.statusLabel,
                style: const TextStyle(
                  color: AppColors.body,
                  fontSize: 10,
                  fontFamily: 'JetBrains Mono',
                  fontWeight: FontWeight.w400,
                  height: 1.50,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
