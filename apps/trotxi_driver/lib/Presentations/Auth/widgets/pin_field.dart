import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/config/theme/app_radii.dart';
import 'package:trotxi_driver/core/config/theme/app_spacing.dart';
import 'package:trotxi_driver/core/config/theme/app_typography.dart';

/// Six boxes a driver fills in, with one real text field behind them.
///
/// Six separate fields is the obvious build and the wrong one: focus juggling
/// breaks paste, breaks the platform's own PIN autofill, and leaves a driver
/// tapping at a box that will not take a digit. One hidden field owns the value
/// and the boxes are just a drawing of it.
class PinField extends StatefulWidget {
  const PinField({
    super.key,
    required this.controller,
    this.length = 6,
    this.hasError = false,
    this.autofocus = false,
    this.onCompleted,
  });

  final TextEditingController controller;
  final int length;

  /// Paints the boxes in the danger colour, for a rejected PIN.
  final bool hasError;
  final bool autofocus;

  /// Fired once the last digit lands, so the form can submit itself.
  final ValueChanged<String>? onCompleted;

  @override
  State<PinField> createState() => _PinFieldState();
}

class _PinFieldState extends State<PinField> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged() {
    setState(() {});
    if (widget.controller.text.length == widget.length) {
      widget.onCompleted?.call(widget.controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    final digits = widget.controller.text;

    return Semantics(
      label: 'PIN, ${widget.length} digits',
      textField: true,
      child: Stack(
        children: [
          // The real field, invisible but present: it keeps the keyboard, the
          // cursor, autofill and paste all working normally.
          Opacity(
            opacity: 0,
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              autofocus: widget.autofocus,
              keyboardType: TextInputType.number,
              obscureText: true,
              autofillHints: const [AutofillHints.password],
              maxLength: widget.length,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(counterText: ''),
            ),
          ),
          Positioned.fill(
            child: GestureDetector(
              onTap: () => _focusNode.requestFocus(),
              behavior: HitTestBehavior.opaque,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(widget.length, (index) {
                  final filled = index < digits.length;
                  final focused = _focusNode.hasFocus && index == digits.length;
                  return _PinBox(
                    filled: filled,
                    focused: focused,
                    hasError: widget.hasError,
                    colors: colors,
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PinBox extends StatelessWidget {
  const _PinBox({
    required this.filled,
    required this.focused,
    required this.hasError,
    required this.colors,
  });

  final bool filled;
  final bool focused;
  final bool hasError;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final borderColor = hasError
        ? colors.danger
        : focused
        ? colors.action
        : colors.border;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      width: 48,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadii.circular(AppRadii.md),
        border: Border.all(color: borderColor, width: focused || hasError ? 2 : 1),
      ),
      child: filled
          // A dot, not the digit: this is typed in a vehicle with people
          // standing over the driver's shoulder.
          ? Container(
              width: AppSpacing.space12,
              height: AppSpacing.space12,
              decoration: BoxDecoration(
                color: hasError ? colors.danger : colors.textPrimary,
                shape: BoxShape.circle,
              ),
            )
          : Text('', style: AppTypography.title.copyWith(color: colors.textSecondary)),
    );
  }
}
