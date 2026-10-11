import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:trotxi_client/trotxi_client.dart' as wire;
import 'package:trotxi_commuter/core/api/commuter_api.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';
import 'package:trotxi_commuter/core/config/theme/app_typography.dart';

class PassTab extends StatefulWidget {
  const PassTab({
    super.key,
    required this.client,
    this.initialReservationId,
    this.now = DateTime.now,
  });
  final CommuterApi client;
  final String? initialReservationId;
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
        if (_selectedId == null &&
            widget.initialReservationId != null &&
            _seats.any((r) => r.id == widget.initialReservationId)) {
          _selectedId = widget.initialReservationId;
        }
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
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text('Ready to board.', style: AppTypography.heading2),
            const SizedBox(height: 8),
            Text(
              'Choose your departure, then show your pass when you board.',
              style: AppTypography.bodySmall.copyWith(
                color: context.appColors.textSecondary,
              ),
            ),
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
                        '${DateFormat('EEE, d MMM').format(seat.travelDate.toDateTime())} · ${seat.direction == wire.ReservationDirectionEnum.outbound ? 'Outbound' : 'Return'}',
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

/// Only the QR itself stays white in dark mode so scanners retain contrast.
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
    final colors = context.appColors;
    final valid =
        passUrl != null && expiresAt != null && remaining > Duration.zero;
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 448),
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Column(
        children: [
          if (loading && !valid)
            const Padding(
              padding: EdgeInsets.all(64),
              child: CircularProgressIndicator(),
            )
          else if (!valid) ...[
            Icon(
              Icons.confirmation_number_outlined,
              size: 40,
              color: colors.iconSubtle,
            ),
            const SizedBox(height: 16),
            Text(
              'Refresh your boarding pass.',
              textAlign: TextAlign.center,
              style: AppTypography.title,
            ),
            const SizedBox(height: 8),
            Text(
              'A current pass is needed to board.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ] else ...[
            Text(
              'SHOW WHEN YOU BOARD',
              style: AppTypography.caption.copyWith(
                color: colors.textSecondary,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 20),
            BoardingQr(data: passUrl!),
            const SizedBox(height: 20),
            Text(
              'Refreshes automatically',
              style: AppTypography.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${remaining.inMinutes.toString().padLeft(2, '0')}:${(remaining.inSeconds % 60).toString().padLeft(2, '0')} remaining',
              style: AppTypography.caption.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class BoardingQr extends StatelessWidget {
  const BoardingQr({super.key, required this.data});
  final String data;
  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 224),
    child: AspectRatio(
      aspectRatio: 1,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: QrImageView(
          data: data,
          version: QrVersions.auto,
          backgroundColor: Colors.white,
          eyeStyle: const QrEyeStyle(
            eyeShape: QrEyeShape.square,
            color: Color(0xFF132D24),
          ),
          dataModuleStyle: const QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.square,
            color: Color(0xFF132D24),
          ),
        ),
      ),
    ),
  );
}

class _PassFooter extends StatelessWidget {
  const _PassFooter({required this.code});
  final String code;
  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 448),
    child: Column(
      children: [
        const SizedBox(height: 8),
        _DailyPinCard(key: ValueKey(code), code: code),
        const SizedBox(height: 16),
        Text(
          'Keep your boarding pass private.',
          style: AppTypography.caption.copyWith(
            color: context.appColors.textSecondary,
          ),
        ),
      ],
    ),
  );
}

/// Mask the returned boarding code until explicitly revealed.
class _DailyPinCard extends StatefulWidget {
  const _DailyPinCard({super.key, required this.code});
  final String code;
  @override
  State<_DailyPinCard> createState() => _DailyPinCardState();
}

class _DailyPinCardState extends State<_DailyPinCard> {
  bool _visible = false;
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final value = _visible
        ? widget.code.split('').join(' ')
        : List.filled(widget.code.length, '•').join(' ');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        border: Border.all(color: colors.borderSubtle),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BOARDING CODE',
                  style: AppTypography.caption.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: AppTypography.title.copyWith(letterSpacing: 3),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _visible = !_visible),
            icon: Icon(
              _visible
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
            tooltip: _visible ? 'Hide code' : 'Show code',
          ),
        ],
      ),
    );
  }
}
