import 'package:flutter/material.dart';
import 'package:trotxi_client/public_information.dart';
import 'package:url_launcher/url_launcher.dart';

Future<bool> _openExternally(Uri uri) =>
    launchUrl(uri, mode: LaunchMode.externalApplication);

/// Information links also work before authentication and after uninstalling.
class PublicInformationLinks extends StatelessWidget {
  const PublicInformationLinks({super.key, this.open = _openExternally});

  final Future<bool> Function(Uri) open;

  Future<void> _show(BuildContext context, Uri uri) async {
    try {
      if (await open(uri)) return;
    } on Exception {
      // Preserve the address if the OS cannot launch an external browser.
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
    final style = TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      minimumSize: const Size(0, 44),
      textStyle: const TextStyle(fontSize: 14),
    );
    Widget link(String text, Uri uri) => TextButton(
      style: style,
      onPressed: () => _show(context, uri),
      child: Text(text),
    );
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 4,
      children: [
        link('Privacy notice', TrotxiPublicInformation.privacy),
        link('Request account deletion', TrotxiPublicInformation.deletion),
      ],
    );
  }
}
