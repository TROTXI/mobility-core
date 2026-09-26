import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:trotxi_commuter/Features/Home/pages/home_page_provider.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';
import 'package:trotxi_commuter/main.dart';

/// Boarding pass for one reservation. Issues a short-lived pass via
/// `POST /v1/me/reservations/{id}/pass`, renders its `qrToken` as a QR, and
/// silently re-issues it shortly before `expiresAt`.
class PassTab extends ConsumerStatefulWidget {
  const PassTab({super.key, required this.reservationId});
  final String reservationId;

  @override
  ConsumerState<PassTab> createState() => _PassTabState();
}

class _PassTabState extends ConsumerState<PassTab> with WidgetsBindingObserver {
  /// How long before expiry we re-issue, so the scanner never sees a dead code.
  static const _refreshLead = Duration(seconds: 3);

  /// Retry delay when a background refresh fails but the QR is still valid.
  static const _retryDelay = Duration(seconds: 2);

  String? _qrToken;

  /// Absolute expiry moment, straight from the API's `expiresAt`.
  DateTime? _expiresAt;

  bool _loading = true;
  bool _fetching = false;
  Object? _error;

  Timer? _refreshTimer;
  Timer? _tickTimer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchPass();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _refreshTimer?.cancel();
    _tickTimer?.cancel();
    super.dispose();
  }

  /// Timers can be delayed while the app is backgrounded, so re-issue on
  /// resume if the current pass is expired or about to be.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    final expiresAt = _expiresAt;
    if (expiresAt == null || _timeLeft(expiresAt) <= _refreshLead) {
      _fetchPass(silent: _qrToken != null);
    }
  }

  /// Time until [expiresAt], clamped at zero.
  Duration _timeLeft(DateTime expiresAt) {
    final d = expiresAt.difference(DateTime.now());
    return d.isNegative ? Duration.zero : d;
  }

  /// Issues a fresh pass. When [silent] is true (background refresh), the
  /// existing QR stays on screen and no spinner is shown.
  Future<void> _fetchPass({bool silent = false}) async {
    if (_fetching) return; // never overlap requests
    _fetching = true;

    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final api = ref.read(trotxiClientProvider).getRiderOwnApi();
      final meta = ref.read(clientMetadataProvider);

      final response = await api.issuePass(
        id: widget.reservationId,
        // Fresh key per issue: reusing one would replay the old pass.
        idempotencyKey:
            '${widget.reservationId}-${DateTime.now().microsecondsSinceEpoch}',
        xTrotxiClient: meta.client,
        xTrotxiBuild: meta.build,
        xTrotxiPlatform: meta.platform,
      );

      final pass = response.data?.data;
      if (pass == null) throw StateError('issuePass returned no data');

      final expiresAt = pass.expiresAt;

      if (!mounted) return;
      setState(() {
        _qrToken = pass.qrToken;
        _expiresAt = expiresAt;
        _loading = false;
        _error = null;
        _remaining = _timeLeft(expiresAt);
      });

      _scheduleRefresh(expiresAt);
      _startCountdown(expiresAt);
    } catch (e) {
      debugPrint('Error issuing boarding pass: $e');
      if (!mounted) return;

      final expiresAt = _expiresAt;
      final stillValid =
          expiresAt != null && _timeLeft(expiresAt) > Duration.zero;

      if (silent && stillValid) {
        // Refresh failed but the current QR still works: keep showing it
        // and retry shortly instead of flashing an error.
        _refreshTimer?.cancel();
        _refreshTimer = Timer(_retryDelay, () => _fetchPass(silent: true));
        return;
      }

      _refreshTimer?.cancel();
      _tickTimer?.cancel();
      setState(() {
        _error = e;
        _loading = false;
        _qrToken = null; // expired or never loaded: show the error state
        _remaining = Duration.zero;
      });
    } finally {
      _fetching = false;
    }
  }

  void _scheduleRefresh(DateTime expiresAt) {
    _refreshTimer?.cancel();
    final delay = _timeLeft(expiresAt) - _refreshLead;
    _refreshTimer = Timer(
      delay.isNegative ? Duration.zero : delay,
      () => _fetchPass(silent: true),
    );
  }

  void _startCountdown(DateTime expiresAt) {
    _tickTimer?.cancel();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _remaining = _timeLeft(expiresAt));
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
              qrToken: _qrToken,
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

/// The white card: QR section (loading / error / live QR) + countdown row.
class _PassCard extends StatelessWidget {
  const _PassCard({
    required this.loading,
    required this.error,
    required this.qrToken,
    required this.remaining,
    required this.onRetry,
  });

  final bool loading;
  final Object? error;
  final String? qrToken;
  final Duration remaining;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    // Only show a blocking loading/error state before we've ever had a
    // token. Once we have one, background refreshes happen silently and
    // the existing QR stays on screen until the new one is ready.
    final token = qrToken;

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
            if (token != null)
              _QrSection(qrToken: token)
            else if (loading && error == null)
              const _QrLoading()
            else
              _QrError(onRetry: onRetry),
            if (token != null) _PassMetaRow(remaining: remaining),
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
  const _QrSection({required this.qrToken});
  final String qrToken;

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
                _QrCode(data: qrToken),
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

/// Live refresh countdown.
class _PassMetaRow extends StatelessWidget {
  const _PassMetaRow({required this.remaining});

  final Duration remaining;

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
/// TODO: source `_pin` from the API instead of the hardcoded value. The
/// regenerated client has no obvious boarding-session/PIN endpoint yet.
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
