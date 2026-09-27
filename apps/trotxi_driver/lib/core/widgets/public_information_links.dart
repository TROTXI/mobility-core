import 'package:flutter/material.dart';
import 'package:trotxi_client/public_information.dart';
import 'package:url_launcher/url_launcher.dart';

Future<bool> _openExternally(Uri uri) =>
    launchUrl(uri, mode: LaunchMode.externalApplication);

/// Available without an account; opening a request page never erases a user.
class PublicInformationLinks extends StatelessWidget {
  const PublicInformationLinks({super.key, this.open = _openExternally});

  final Future<bool> Function(Uri) open;

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
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    children: [
      TextButton(
        onPressed: () => _show(context, TrotxiPublicInformation.privacy),
        child: const Text('Privacy notice'),
      ),
      TextButton(
        onPressed: () => _show(context, TrotxiPublicInformation.deletion),
        child: const Text('Request account deletion'),
      ),
    ],
  );
}
