import 'package:flutter/material.dart';
import 'package:trotxi_client/public_information.dart';
import 'package:trotxi_commuter/core/api/commuter_api.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';
import 'package:trotxi_commuter/core/config/theme/app_typography.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key, required this.client});

  final CommuterApi client;

  Future<void> _open(BuildContext context, Uri uri) async {
    try {
      if (await launchUrl(uri, mode: LaunchMode.externalApplication)) return;
    } catch (_) {
      // Keep the address available if the device has no handler.
    }
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Open this address'),
        content: SelectableText(uri.toString()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final operations = client.configuration?.operations;
    final phone = operations?.phone?.trim();
    final whatsapp = operations?.whatsapp?.trim();
    final email = operations?.email?.trim();
    final hours = operations?.hours?.trim();
    final hasContact =
        (phone?.isNotEmpty ?? false) ||
        (whatsapp?.isNotEmpty ?? false) ||
        (email?.isNotEmpty ?? false);
    Uri? whatsappUri;
    if (whatsapp?.isNotEmpty ?? false) {
      final digits = whatsapp!.replaceAll(RegExp(r'[^0-9]'), '');
      if (digits.isNotEmpty) whatsappUri = Uri.https('wa.me', '/$digits');
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Help and support')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              Text(
                'How can we help?',
                style: AppTypography.heading2.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Contact us about a trip, payment or your account. Have your route and travel date ready for trip help.',
                style: AppTypography.body.copyWith(color: colors.textSecondary),
              ),
              if (hours?.isNotEmpty ?? false) ...[
                const SizedBox(height: 10),
                Text(
                  'Support hours: $hours',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: 28),
              Text(
                'Contact Trotxi',
                style: AppTypography.title.copyWith(color: colors.textPrimary),
              ),
              const SizedBox(height: 12),
              if (!hasContact)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: colors.backgroundSubtle,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    'Support contact details are unavailable right now. Please try again later.',
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              if (phone?.isNotEmpty ?? false)
                _linkTile(
                  context,
                  icon: Icons.call_outlined,
                  title: 'Call support',
                  subtitle: phone!,
                  onTap: () => _open(context, Uri(scheme: 'tel', path: phone)),
                ),
              if (whatsappUri != null)
                _linkTile(
                  context,
                  icon: Icons.chat_outlined,
                  title: 'Message on WhatsApp',
                  subtitle: whatsapp!,
                  onTap: () => _open(context, whatsappUri!),
                ),
              if (email?.isNotEmpty ?? false)
                _linkTile(
                  context,
                  icon: Icons.email_outlined,
                  title: 'Email support',
                  subtitle: email!,
                  onTap: () =>
                      _open(context, Uri(scheme: 'mailto', path: email)),
                ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.actionPrimaryDefault.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'For payment help, copy the reference from Payment details. Never share your password or verification code.',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Your information',
                style: AppTypography.title.copyWith(color: colors.textPrimary),
              ),
              const SizedBox(height: 12),
              _linkTile(
                context,
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy notice',
                onTap: () => _open(context, TrotxiPublicInformation.privacy),
              ),
              _linkTile(
                context,
                icon: Icons.person_remove_outlined,
                title: 'Request account deletion',
                onTap: () => _open(context, TrotxiPublicInformation.deletion),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _linkTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: colors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.borderSubtle),
        ),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 5,
          ),
          leading: Icon(icon, color: colors.actionPrimaryDefault),
          title: Text(
            title,
            style: AppTypography.label.copyWith(color: colors.textPrimary),
          ),
          subtitle: subtitle == null
              ? null
              : Text(
                  subtitle,
                  style: AppTypography.caption.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
          trailing: Icon(
            Icons.open_in_new_rounded,
            size: 18,
            color: colors.iconSubtle,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
