import 'package:flutter/material.dart';
import 'package:trotxi_commuter/core/api/commuter_api.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';
import 'package:trotxi_commuter/core/config/theme/app_typography.dart';

/// Figma 2102:86-93. Selection is local; only Submit rating sends feedback.
/// Callers mount this only for a boarded reservation on a completed trip.
class RideRatingCard extends StatefulWidget {
  const RideRatingCard({
    super.key,
    required this.client,
    required this.reservationId,
    this.initialStars,
    this.onSubmitted,
  });

  final CommuterApi client;
  final String reservationId;
  final int? initialStars;
  final VoidCallback? onSubmitted;

  @override
  State<RideRatingCard> createState() => _RideRatingCardState();
}

class _RideRatingCardState extends State<RideRatingCard> {
  int? _selected;
  int? _saved;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _saved = widget.initialStars;
  }

  @override
  void didUpdateWidget(covariant RideRatingCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reservationId != widget.reservationId ||
        oldWidget.client != widget.client) {
      _saved = widget.initialStars;
      _selected = null;
      _error = null;
      _saving = false;
    } else if (widget.initialStars != null) {
      _saved = widget.initialStars;
    }
  }

  Future<void> _submit() async {
    final stars = _selected;
    if (_saving || _saved != null || stars == null) return;
    final client = widget.client;
    final id = widget.reservationId;
    final generation = client.sessionGeneration;
    bool current() =>
        mounted && widget.client == client && widget.reservationId == id;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final rating = await client.rateReservation(id, stars);
      client.ensureSession(generation);
      if (!current()) return;
      setState(() {
        _saved = rating.stars;
        _saving = false;
      });
      widget.onSubmitted?.call();
    } catch (error) {
      if (!current() || client.sessionGeneration != generation) return;
      setState(() {
        _saving = false;
        _error = error is TrotxiException
            ? error.message
            : 'Your rating was not saved. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final score = _saved ?? _selected ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'How was your ride?',
          style: AppTypography.title.copyWith(
            fontSize: 15,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Your feedback helps us improve every commute.',
          style: AppTypography.caption.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          decoration: BoxDecoration(
            color: colors.surfaceElevated,
            border: Border.all(color: colors.borderSubtle),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: List.generate(5, (index) {
              final stars = index + 1;
              return Expanded(
                child: Semantics(
                  label: '$stars ${stars == 1 ? 'star' : 'stars'}',
                  selected: score == stars,
                  button: true,
                  enabled: !_saving && _saved == null,
                  onTap: _saving || _saved != null
                      ? null
                      : () => setState(() {
                          _selected = stars;
                          _error = null;
                        }),
                  child: ExcludeSemantics(
                    child: TextButton(
                      onPressed: _saving || _saved != null
                          ? null
                          : () => setState(() {
                              _selected = stars;
                              _error = null;
                            }),
                      style: TextButton.styleFrom(
                        minimumSize: const Size(44, 44),
                        padding: EdgeInsets.zero,
                        foregroundColor: stars <= score
                            ? colors.actionSecondary
                            : colors.textPrimary,
                        disabledForegroundColor: stars <= score
                            ? colors.actionSecondary
                            : colors.textSecondary,
                      ),
                      child: Text(
                        stars <= score ? '★' : '☆',
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        if (_saved != null) ...[
          const SizedBox(height: 12),
          Semantics(
            liveRegion: true,
            child: Text(
              'Thank you. You rated this ride $_saved out of 5.',
              style: AppTypography.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
        ] else if (_selected != null) ...[
          if (_error != null) ...[
            const SizedBox(height: 12),
            Semantics(
              liveRegion: true,
              child: Text(
                _error!,
                style: AppTypography.bodySmall.copyWith(color: colors.error),
              ),
            ),
          ],
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _saving ? null : _submit,
            child: Text(_saving ? 'Saving rating…' : 'Submit rating'),
          ),
        ],
      ],
    );
  }
}
