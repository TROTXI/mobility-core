import 'package:flutter/material.dart';
import 'package:trotxi_client/trotxi_client.dart';
import 'package:trotxi_driver/Presentations/Auth/widgets/pin_field.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/config/theme/app_radii.dart';
import 'package:trotxi_driver/core/config/theme/app_spacing.dart';
import 'package:trotxi_driver/core/config/theme/app_typography.dart';
import 'package:trotxi_driver/data/driver_auth_repository.dart';

/// Replace the PIN operations issued.
///
/// Forced on first sign-in: until the driver picks their own, the PIN is known
/// to whoever read it out at the depot. The server also revokes every other
/// session on the account when this succeeds, which is the point of doing it.
class ChangePinPage extends StatefulWidget {
  const ChangePinPage({
    super.key,
    required this.auth,
    required this.onChanged,
    this.isForced = false,
  });

  final DriverAuthRepository auth;
  final VoidCallback onChanged;

  /// True on first sign-in, where there is nothing to go back to.
  final bool isForced;

  @override
  State<ChangePinPage> createState() => _ChangePinPageState();
}

class _ChangePinPageState extends State<ChangePinPage> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool get _complete =>
      _currentController.text.length == 6 &&
      _newController.text.length == 6 &&
      _confirmController.text.length == 6;

  Future<void> _submit() async {
    if (!_complete || _submitting) return;

    // Checked here rather than server-side: the confirm box exists to catch a
    // typo, and a round trip to say "those do not match" is a round trip wasted.
    if (_newController.text != _confirmController.text) {
      setState(() => _error = 'The two new PINs do not match.');
      return;
    }
    if (_newController.text == _currentController.text) {
      setState(() => _error = 'Choose a PIN you have not just used.');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await widget.auth.changePin(
        currentPin: _currentController.text,
        newPin: _newController.text,
      );
      if (!mounted) return;
      widget.onChanged();
    } on InvalidCredentialsException {
      _fail('That current PIN is not right.');
    } on ApiException catch (err) {
      // 400 is the server refusing a weak PIN, and its message names the rule.
      _fail(err.statusCode == 400 ? err.message : 'Could not change your PIN.');
    } on OfflineException {
      _fail('You are offline. Try again once you have signal.');
    } on TrotxiException catch (err) {
      _fail(err.message);
    }
  }

  void _fail(String message) {
    if (!mounted) return;
    setState(() {
      _submitting = false;
      _error = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose your PIN'),
        automaticallyImplyLeading: !widget.isForced,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space24,
            vertical: AppSpacing.space16,
          ),
          children: [
            Text(
              widget.isForced
                  ? 'Your operator issued the PIN you just used, so other people have '
                        'seen it. Pick one only you know.'
                  : 'Changing your PIN signs you out everywhere else.',
              style: AppTypography.body.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.space32),
            _PinRow(
              label: 'Current PIN',
              controller: _currentController,
              onChanged: () => setState(() {}),
            ),
            _PinRow(
              label: 'New PIN',
              controller: _newController,
              onChanged: () => setState(() {}),
            ),
            _PinRow(
              label: 'Confirm new PIN',
              controller: _confirmController,
              onChanged: () => setState(() {}),
            ),
            Text(
              'Six digits. Not all the same, and not a run like 123456.',
              style: AppTypography.caption.copyWith(color: colors.textSecondary),
            ),
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.space16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.space16),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: AppRadii.circular(AppRadii.md),
                  border: Border.all(color: colors.danger),
                ),
                child: Text(
                  _error!,
                  style: AppTypography.bodySmall.copyWith(color: colors.danger),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.space32),
            ElevatedButton(
              onPressed: _complete && !_submitting ? _submit : null,
              child: _submitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save PIN'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PinRow extends StatelessWidget {
  const _PinRow({required this.label, required this.controller, required this.onChanged});

  final String label;
  final TextEditingController controller;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.label.copyWith(color: colors.textSecondary)),
          const SizedBox(height: AppSpacing.space8),
          SizedBox(
            height: 56,
            child: PinField(controller: controller, onCompleted: (_) => onChanged()),
          ),
        ],
      ),
    );
  }
}
