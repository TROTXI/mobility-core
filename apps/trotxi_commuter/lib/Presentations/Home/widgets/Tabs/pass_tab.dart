import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:trotxi_client/trotxi_client.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';

class PassTab extends StatefulWidget {
  const PassTab({super.key, required this.client});
  final TrotxiApiClient client;

  @override
  State<PassTab> createState() => _PassTabState();
}

class _PassTabState extends State<PassTab> {
  String? _passUrl;

  /// Absolute expiry moment, computed locally from the API's
  /// `expiresInSeconds` (a TTL, not a timestamp) at the moment we fetch it.
  DateTime? _expiresAt;

  bool _loading = true;
  Object? _error;

  Timer? _refreshTimer;
  Timer? _tickTimer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _fetchPass();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _tickTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchPass() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await widget.client.getBoardingApi().mePassGet();
      final data = response.data;
      if (data == null) {
        throw StateError('mePassGet() returned no data');
      }

      // expiresInSeconds is a TTL ("expires in N seconds from now"), so
      // anchor it to the current time to get an absolute expiry moment.
      final expiresAt = DateTime.now().add(
        Duration(seconds: data.expiresInSeconds),
      );

      if (!mounted) return;
      setState(() {
        _passUrl = data.pass;
        _expiresAt = expiresAt;
        _loading = false;
      });

      _scheduleRefresh();
      _startCountdown();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
      debugPrint('Error fetching boarding pass: $e');
    }
  }

  /// Refetches a couple seconds before the current pass URL expires so the
  /// driver's scanner is never looking at a dead code.
  void _scheduleRefresh() {
    _refreshTimer?.cancel();
    final expiresAt = _expiresAt;
    if (expiresAt == null) return;

    const lead = Duration(seconds: 3);
    final delay = expiresAt.difference(DateTime.now()) - lead;

    _refreshTimer = Timer(delay.isNegative ? Duration.zero : delay, _fetchPass);
  }

  void _startCountdown() {
    _tickTimer?.cancel();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final expiresAt = _expiresAt;
      if (expiresAt == null || !mounted) return;
      final remaining = expiresAt.difference(DateTime.now());
      setState(
        () => _remaining = remaining.isNegative ? Duration.zero : remaining,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.lightBackground,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 128),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const _PassHeader(),
            const SizedBox(height: 24),
            _PassCard(
              loading: _loading,
              error: _error,
              passUrl: _passUrl,
              expiresAt: _expiresAt,
              remaining: _remaining,
              onRetry: _fetchPass,
            ),
            const SizedBox(height: 24),
            const _PassFooter(),
          ],
        ),
      ),
    );
  }
}

/// Title + "Active" status chip.
class _PassHeader extends StatelessWidget {
  const _PassHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Boarding Pass',
          style: TextStyle(
            color: AppColors.dark,
            fontSize: 24,
            fontFamily: 'Hanken Grotesk',
            fontWeight: FontWeight.w700,
            height: 1.33,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Dot(),
              SizedBox(width: 4),
              Text(
                'Active - Boarding Pass',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontFamily: 'JetBrains Mono',
                  fontWeight: FontWeight.w600,
                  height: 1.33,
                  letterSpacing: 0.60,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// The white card: QR section (loading / error / live QR) + expiry row.
class _PassCard extends StatelessWidget {
  const _PassCard({
    required this.loading,
    required this.error,
    required this.passUrl,
    required this.expiresAt,
    required this.remaining,
    required this.onRetry,
  });

  final bool loading;
  final Object? error;
  final String? passUrl;
  final DateTime? expiresAt;
  final Duration remaining;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    // Only show a blocking loading/error state before we've ever had a
    // pass URL. Once we have one, background refreshes happen silently
    // and the existing QR stays on screen until the new one is ready.
    final showLoading = loading && passUrl == null;
    final showError = error != null && passUrl == null;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 448),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.lightBackground,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0C000000),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          children: [
            if (showLoading)
              const _QrLoading()
            else if (showError)
              _QrError(onRetry: onRetry)
            else
              _QrSection(passUrl: passUrl!),
            if (passUrl != null)
              _PassMetaRow(expiresAt: expiresAt, remaining: remaining),
          ],
        ),
      ),
    );
  }
}

class _QrLoading extends StatelessWidget {
  const _QrLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: SizedBox(
        width: 256,
        height: 256 + 16 + 16,
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _QrError extends StatelessWidget {
  const _QrError({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: 256,
        height: 256 + 16 + 16,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.muted,
            ),
            const SizedBox(height: 12),
            const Text(
              'Couldn\'t load your pass',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.body,
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// QR code framed with corner brackets, plus the "scan at entry" label.
class _QrSection extends StatelessWidget {
  const _QrSection({required this.passUrl});
  final String passUrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          SizedBox(
            width: 256,
            height: 256,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const _CornerBracket(alignment: Alignment.topLeft),
                const _CornerBracket(alignment: Alignment.topRight),
                const _CornerBracket(alignment: Alignment.bottomLeft),
                const _CornerBracket(alignment: Alignment.bottomRight),
                _QrCode(data: passUrl),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'SCAN AT ENTRY POINT',
            style: TextStyle(
              color: AppColors.body,
              fontSize: 12,
              fontFamily: 'JetBrains Mono',
              fontWeight: FontWeight.w600,
              height: 1.33,
              letterSpacing: 0.60,
            ),
          ),
        ],
      ),
    );
  }
}

class _CornerBracket extends StatelessWidget {
  const _CornerBracket({required this.alignment});
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(width: 4, color: AppColors.primary),
            bottom: BorderSide(width: 4, color: AppColors.primary),
            left: BorderSide(width: 4, color: AppColors.primary),
            right: BorderSide(width: 4, color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}

class _QrCode extends StatelessWidget {
  const _QrCode({required this.data});
  final String data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 224,
      height: 224,
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(width: 2, color: AppColors.dark)),
      ),
      child: QrImageView(
        data: data,
        version: QrVersions.auto,
        backgroundColor: Colors.white,
        eyeStyle: const QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: AppColors.dark,
        ),
        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: AppColors.dark,
        ),
      ),
    );
  }
}

/// Expiry timestamp (left) and live refresh countdown (right).
class _PassMetaRow extends StatelessWidget {
  const _PassMetaRow({required this.expiresAt, required this.remaining});

  final DateTime? expiresAt;
  final Duration remaining;

  String _formatTime(DateTime dt) {
    final local = dt.toLocal();
    final h = local.hour.toString().padLeft(2, '0');
    final m = local.minute.toString().padLeft(2, '0');
    final s = local.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String _formatCountdown(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 5),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _MetaItem(
            label: 'REFRESHES IN',
            value: _formatCountdown(remaining),
            alignment: CrossAxisAlignment.end,
          ),
        ],
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({
    required this.label,
    required this.value,
    this.alignment = CrossAxisAlignment.start,
  });

  final String label;
  final String value;
  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 12,
            fontFamily: 'JetBrains Mono',
            fontWeight: FontWeight.w600,
            height: 1.33,
            letterSpacing: 0.60,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.alert,
            fontSize: 14,
            fontFamily: 'JetBrains Mono',
            fontWeight: FontWeight.w700,
            height: 1.43,
          ),
        ),
      ],
    );
  }
}

/// Tip banner + Daily PIN session card below the boarding-pass card.
class _PassFooter extends StatelessWidget {
  const _PassFooter();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 448),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.tipBg,
              border: Border.all(color: AppColors.tipBorder),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Tip: Turn up your screen brightness to maximum\n'
              'for faster scanning at the gate.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.body,
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                height: 1.43,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const _DailyPinCard(),
        ],
      ),
    );
  }
}

/// Displays the session's 4-digit daily boarding PIN, masked by default,
/// with an eye icon to toggle visibility.
///
/// TODO: source `_pin` from the boarding-session response instead of the
/// hardcoded value.
class _DailyPinCard extends StatefulWidget {
  const _DailyPinCard();

  @override
  State<_DailyPinCard> createState() => _DailyPinCardState();
}

class _DailyPinCardState extends State<_DailyPinCard> {
  static const String _pin = '4821';
  bool _visible = false;

  void _toggleVisibility() {
    setState(() => _visible = !_visible);
  }

  @override
  Widget build(BuildContext context) {
    final displayValue = _visible
        ? _pin.split('').join(' ')
        : List.filled(_pin.length, '•').join(' ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        border: Border.all(color: AppColors.buttonBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'DAILY BOARDING PIN',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontFamily: 'JetBrains Mono',
                  fontWeight: FontWeight.w600,
                  height: 1.33,
                  letterSpacing: 0.60,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                displayValue,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontFamily: 'JetBrains Mono',
                  fontWeight: FontWeight.w700,
                  height: 1.33,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: _toggleVisibility,
            icon: Icon(
              _visible
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: Colors.white,
            ),
            tooltip: _visible ? 'Hide PIN' : 'Show PIN',
          ),
        ],
      ),
    );
  }
}
