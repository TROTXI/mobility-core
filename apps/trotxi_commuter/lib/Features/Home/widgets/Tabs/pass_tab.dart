import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:trotxi_client_next/trotxi_client_next.dart' as wire;
import 'package:trotxi_commuter/core/api/commuter_api.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';

class PassTab extends StatefulWidget {
  const PassTab({super.key, required this.client, this.now = DateTime.now});
  final CommuterApi client;
  final DateTime Function() now;
  @override
  State<PassTab> createState() => _PassTabState();
}

class _PassTabState extends State<PassTab> with WidgetsBindingObserver {
  List<wire.Reservation> _seats = [];
  String? _selectedId, _passUrl, _boardingCode;
  DateTime? _expiresAt;
  bool _loading = true, _foreground = true;
  Object? _error;
  Timer? _refreshTimer, _tickTimer;
  Duration _remaining = Duration.zero;
  int _attempt = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSeats();
  }

  @override
  void dispose() {
    _attempt++;
    _refreshTimer?.cancel();
    _tickTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    _attempt++;
    _refreshTimer?.cancel();
    _tickTimer?.cancel();
    if (_foreground) {
      _loadSeats();
    } else {
      setState(() {
        _passUrl = null;
        _boardingCode = null;
      });
    }
  }

  Future<void> _loadSeats() async {
    final attempt = ++_attempt;
    _refreshTimer?.cancel();
    _tickTimer?.cancel();
    setState(() {
      _loading = true;
      _error = null;
      _passUrl = null;
      _boardingCode = null;
    });
    try {
      final now = widget.now().toUtc(),
          yesterday = widget.now().toUtc().subtract(const Duration(days: 1));
      final rows = await widget.client.reservations(
        from: wire.Date(yesterday.year, yesterday.month, yesterday.day),
        to: wire.Date(now.year, now.month, now.day),
      );
      if (!mounted || attempt != _attempt) return;
      setState(() {
        _seats = rows
            .where(
              (r) =>
                  r.status == wire.ReservationStatusEnum.reserved &&
                  r.tripId != null,
            )
            .toList();
        if (!_seats.any((r) => r.id == _selectedId)) _selectedId = null;
        // Even one seat is explicitly chosen, so the rider sees which day/leg this proof authorizes.
        _loading = false;
      });
      if (_selectedId != null) await _fetchPass();
    } catch (e) {
      if (mounted && attempt == _attempt) {
        setState(() {
          _error = e;
          _loading = false;
        });
      }
    }
  }

  Future<void> _fetchPass() async {
    final id = _selectedId;
    if (id == null || !_foreground) return;
    final attempt = ++_attempt;
    _refreshTimer?.cancel();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final pass = await widget.client.issuePass(id);
      if (!mounted ||
          attempt != _attempt ||
          id != _selectedId ||
          !_foreground) {
        return;
      }
      if (!pass.expiresAt.isAfter(widget.now())) {
        throw const ApiException(
          502,
          'This pass has expired. Request a new one.',
        );
      }
      setState(() {
        _passUrl = pass.qrToken;
        _boardingCode = pass.boardingCode;
        _expiresAt = pass.expiresAt;
        _remaining = pass.expiresAt.difference(widget.now());
        _loading = false;
      });
      final delay =
          pass.expiresAt.difference(widget.now()) - const Duration(seconds: 3);
      _refreshTimer = Timer(
        delay < const Duration(seconds: 1) ? const Duration(seconds: 1) : delay,
        _fetchPass,
      );
      _tickTimer?.cancel();
      _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        final remaining = _expiresAt!.difference(widget.now());
        setState(() {
          _remaining = remaining.isNegative ? Duration.zero : remaining;
          if (_remaining == Duration.zero) {
            _passUrl = null;
            _boardingCode = null;
          }
        });
      });
    } catch (e) {
      if (mounted && attempt == _attempt) {
        setState(() {
          _error = e;
          _loading = false;
          _passUrl = null;
          _boardingCode = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.appColors.backgroundDefault,
    appBar: AppBar(title: const Text('Boarding pass')),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const _PassHeader(),
            const SizedBox(height: 16),
            if (_seats.isNotEmpty)
              DropdownButton<String>(
                isExpanded: true,
                value: _selectedId,
                hint: const Text('Choose your reserved departure'),
                items: [
                  for (final seat in _seats)
                    DropdownMenuItem(
                      value: seat.id,
                      child: Text(
                        '${seat.travelDate} · ${seat.direction == wire.ReservationDirectionEnum.outbound ? 'Outbound' : 'Return'}',
                      ),
                    ),
                ],
                onChanged: (id) {
                  _attempt++;
                  _refreshTimer?.cancel();
                  _tickTimer?.cancel();
                  setState(() {
                    _selectedId = id;
                    _passUrl = null;
                    _boardingCode = null;
                  });
                  _fetchPass();
                },
              ),
            if (_error != null)
              Text(
                _error is TrotxiException
                    ? (_error as TrotxiException).message
                    : 'Could not load your pass.',
              ),
            if (_selectedId != null)
              _PassCard(
                loading: _loading,
                error: _error,
                passUrl: _passUrl,
                expiresAt: _expiresAt,
                remaining: _remaining,
                onRetry: _fetchPass,
              )
            else if (_loading)
              const CircularProgressIndicator()
            else if (_seats.isEmpty)
              const Text('No reserved departures for today or yesterday.'),
            TextButton(
              onPressed: _loadSeats,
              child: const Text('Refresh reservations'),
            ),
            if (_boardingCode != null && _passUrl != null)
              _PassFooter(code: _boardingCode!),
          ],
        ),
      ),
    ),
  );
}

/// Neutral heading: a reservation and a valid proof have not been loaded yet.
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
                'RESERVATION PASS',
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
    final valid =
        passUrl != null && expiresAt != null && remaining > Duration.zero;
    final showLoading = loading && !valid;
    final showError = !valid && !showLoading;

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
            if (valid) _PassMetaRow(expiresAt: expiresAt, remaining: remaining),
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
                BoardingQr(data: passUrl),
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

class BoardingQr extends StatelessWidget {
  const BoardingQr({super.key, required this.data});
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
            label: 'EXPIRES IN',
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

/// The actual reservation's fallback boarding code.
class _PassFooter extends StatelessWidget {
  const _PassFooter({required this.code});
  final String code;

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
          _DailyPinCard(key: ValueKey(code), code: code),
        ],
      ),
    );
  }
}

/// Mask the returned boarding code until explicitly revealed.
class _DailyPinCard extends StatefulWidget {
  const _DailyPinCard({super.key, required this.code});
  final String code;

  @override
  State<_DailyPinCard> createState() => _DailyPinCardState();
}

class _DailyPinCardState extends State<_DailyPinCard> {
  String get _pin => widget.code;
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'RESERVATION BOARDING CODE',
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
          ),
          IconButton(
            onPressed: _toggleVisibility,
            icon: Icon(
              _visible
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: Colors.white,
            ),
            tooltip: _visible ? 'Hide code' : 'Show code',
          ),
        ],
      ),
    );
  }
}
