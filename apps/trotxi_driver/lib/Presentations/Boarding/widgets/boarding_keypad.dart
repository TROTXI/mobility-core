import 'package:flutter/material.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/config/theme/app_radii.dart';
import 'package:trotxi_driver/core/config/theme/app_spacing.dart';
import 'package:trotxi_driver/core/config/theme/app_typography.dart';

/// The keys a boarding code can be built from (Boarding / Code / Entry).
///
/// Digits first, then all letters from the replacement API's base32 alphabet
/// (A–Z and 2–7). I/L/O/U are valid issued characters, not interchangeable with
/// digits. The test checks the actual replacement generator to prevent drift.
const boardingKeys = [
  '2',
  '3',
  '4',
  '5',
  '6',
  '7',
  'A',
  'B',
  'C',
  'D',
  'E',
  'F',
  'G',
  'H',
  'I',
  'J',
  'K',
  'L',
  'M',
  'N',
  'O',
  'P',
  'Q',
  'R',
  'S',
  'T',
  'U',
  'V',
  'W',
  'X',
  'Y',
  'Z',
];

/// The on-screen keypad the file draws for boarding by code.
///
/// Not the system keyboard, and the difference is operational rather than
/// cosmetic. The system keyboard takes half the screen, autocorrects, offers
/// characters outside the code alphabet, and puts the keys
/// where QWERTY puts them rather than where the code's own alphabet does. A
/// driver holding a door with one hand gets a fixed grid of large targets.
class BoardingKeypad extends StatelessWidget {
  const BoardingKeypad({
    super.key,
    required this.onKey,
    required this.onClear,
    required this.onSubmit,
    required this.canSubmit,
    this.enabled = true,
  });

  /// A character was pressed.
  final ValueChanged<String> onKey;

  /// Wipe the entry and start again — the file's CLEAR.
  final VoidCallback onClear;

  /// The file's BOARD.
  final VoidCallback onSubmit;

  /// Whether there are four characters to send.
  final bool canSubmit;

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;

    return Column(
      children: [
        // Six valid digits, then letters in rows of eight. The final short
        // row keeps equal key widths; no character is silently clipped.
        _KeyRow(
          keys: boardingKeys.sublist(0, 6),
          onKey: onKey,
          enabled: enabled,
          colors: colors,
        ),
        const SizedBox(height: AppSpacing.space8),
        _KeyRow(
          keys: boardingKeys.sublist(6, 14),
          slots: 8,
          onKey: onKey,
          enabled: enabled,
          colors: colors,
        ),
        const SizedBox(height: AppSpacing.space8),
        _KeyRow(
          keys: boardingKeys.sublist(14, 22),
          slots: 8,
          onKey: onKey,
          enabled: enabled,
          colors: colors,
        ),
        const SizedBox(height: AppSpacing.space8),
        _KeyRow(
          keys: boardingKeys.sublist(22, 30),
          slots: 8,
          onKey: onKey,
          enabled: enabled,
          colors: colors,
        ),
        const SizedBox(height: AppSpacing.space8),
        _KeyRow(
          keys: boardingKeys.sublist(30),
          slots: 8,
          onKey: onKey,
          enabled: enabled,
          colors: colors,
        ),
        const SizedBox(height: AppSpacing.space16),
        Row(
          children: [
            // BOARD takes the width, CLEAR takes what is left. The file's split
            // is 232 to 80, and the reason is that one of them is the thing the
            // driver came here to do.
            Expanded(
              flex: 232,
              child: FilledButton(
                onPressed: enabled && canSubmit ? onSubmit : null,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: Text('BOARD', style: AppTypography.keyAction),
              ),
            ),
            const SizedBox(width: AppSpacing.space8),
            Expanded(
              flex: 80,
              child: OutlinedButton(
                onPressed: enabled ? onClear : null,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  padding: EdgeInsets.zero,
                ),
                child: Text('CLEAR', style: AppTypography.keyLabel),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// One row of keys, sharing the width evenly.
class _KeyRow extends StatelessWidget {
  const _KeyRow({
    required this.keys,
    required this.onKey,
    required this.enabled,
    required this.colors,
    this.slots,
  });

  final List<String> keys;
  final ValueChanged<String> onKey;
  final bool enabled;
  final AppColors colors;

  /// How many key widths the row is divided into. A short final row keeps its
  /// keys the same size as the rows above by padding the remainder with empty
  /// slots, rather than stretching six keys across the full width — which would
  /// read as a different control.
  final int? slots;

  @override
  Widget build(BuildContext context) {
    final total = slots ?? keys.length;

    return Row(
      children: [
        for (var i = 0; i < total; i += 1) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
            child: i < keys.length
                ? _Key(
                    label: keys[i],
                    onTap: enabled ? () => onKey(keys[i]) : null,
                    colors: colors,
                  )
                : const SizedBox(height: 50),
          ),
        ],
      ],
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({required this.label, required this.onTap, required this.colors});

  final String label;
  final VoidCallback? onTap;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colors.surface,
      borderRadius: AppRadii.circular(AppRadii.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.circular(AppRadii.md),
        child: Container(
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: AppRadii.circular(AppRadii.md),
            border: Border.all(color: colors.border),
          ),
          child: Text(
            label,
            style: AppTypography.keyLabel.copyWith(
              color: onTap == null
                  ? colors.textSecondary.withValues(alpha: 0.4)
                  : colors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

/// The four characters as they are typed (Boarding / Code / Entry).
///
/// Entered characters show in the action colour; the rest are dots. The file
/// draws "B 7 • •", which tells a driver mid-entry how far along they are
/// without counting.
class BoardingCodeDisplay extends StatelessWidget {
  const BoardingCodeDisplay({super.key, required this.code, this.length = 4});

  final String code;
  final int length;

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadii.circular(AppRadii.lg),
        border: Border.all(color: colors.border),
      ),
      child: Text(
        [
          for (var i = 0; i < length; i += 1) i < code.length ? code[i] : '•',
        ].join('   '),
        textAlign: TextAlign.center,
        style: AppTypography.boardingCode.copyWith(color: colors.action),
      ),
    );
  }
}
