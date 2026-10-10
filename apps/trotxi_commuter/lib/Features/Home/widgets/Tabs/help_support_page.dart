import 'package:flutter/material.dart';
import 'package:trotxi_client/public_information.dart';
import 'package:trotxi_commuter/core/api/commuter_api.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key, required this.client});

  final CommuterApi client;

  Future<void> _open(BuildContext context, Uri uri) async {
    try {
      if (await launchUrl(uri, mode: LaunchMode.externalApplication)) return;
    } catch (_) {
      // The address remains available below if the platform has no handler.
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
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'We are here to help',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text(
                'For trip help, tell us the route and travel date. For payment help, share the payment reference if available. Never share your password or verification code.',
              ),
              if (hours?.isNotEmpty ?? false) ...[
                const SizedBox(height: 12),
                Text('Support hours: $hours'),
              ],
              const SizedBox(height: 20),
              if (!hasContact)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Support contact details are not available right now. Please try again later.',
                    ),
                  ),
                ),
              if (phone?.isNotEmpty ?? false)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.call_outlined),
                    title: const Text('Call operations'),
                    subtitle: Text(phone!),
                    onTap: () =>
                        _open(context, Uri(scheme: 'tel', path: phone)),
                  ),
                ),
              if (whatsappUri != null)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.chat_outlined),
                    title: const Text('WhatsApp operations'),
                    subtitle: Text(whatsapp!),
                    onTap: () => _open(context, whatsappUri!),
                  ),
                ),
              if (email?.isNotEmpty ?? false)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.email_outlined),
                    title: const Text('Email operations'),
                    subtitle: Text(email!),
                    onTap: () =>
                        _open(context, Uri(scheme: 'mailto', path: email)),
                  ),
                ),
              const SizedBox(height: 28),
              Text(
                'Your information',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Privacy notice'),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => _open(context, TrotxiPublicInformation.privacy),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.person_remove_outlined),
                  title: const Text('Request account deletion'),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => _open(context, TrotxiPublicInformation.deletion),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
