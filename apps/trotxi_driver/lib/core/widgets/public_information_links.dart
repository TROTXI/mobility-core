import 'package:flutter/material.dart';
import 'package:trotxi_client/public_information.dart';
import 'package:url_launcher/url_launcher.dart';

Future<bool> _openExternally(Uri uri) =>
    launchUrl(uri, mode: LaunchMode.externalApplication);

/// Available without an account; opening a request page never erases a user.
class PublicInformationLinks extends StatelessWidget {
  const PublicInformationLinks({
    super.key,
    this.open = _openExternally,
    this.showDeletion = true,
    this.showPrivacyChoices = false,
  });

  final Future<bool> Function(Uri) open;
  final bool showDeletion;
  final bool showPrivacyChoices;

  Future<void> _show(BuildContext context, Uri uri) async {
    try {
      if (await open(uri)) return;
    } on Exception {
      // A device without an external browser still gets a copyable address.
    }
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Open in your browser'),
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
    Widget link(String label, Uri uri) => TextButton(
      style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
      onPressed: () => _show(context, uri),
      child: Text(label, semanticsLabel: '$label, opens in browser'),
    );
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 4,
      children: [
        // The published agreement covers commuters, not driver employment.
        link('Commuter terms', TrotxiPublicInformation.terms),
        link('Privacy notice', TrotxiPublicInformation.privacy),
        if (showPrivacyChoices)
          link('Privacy choices', TrotxiPublicInformation.privacyChoices),
        if (showDeletion)
          link('Request account deletion', TrotxiPublicInformation.deletion),
      ],
    );
  }
}
