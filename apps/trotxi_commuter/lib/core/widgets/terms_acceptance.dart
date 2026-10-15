import 'package:flutter/material.dart';
import 'package:trotxi_client/public_information.dart';
import 'package:url_launcher/url_launcher.dart';

Future<bool> _openExternally(Uri uri) =>
    launchUrl(uri, mode: LaunchMode.externalApplication);

class TermsAcceptance extends StatelessWidget {
  const TermsAcceptance({
    super.key,
    required this.accepted,
    required this.onChanged,
    this.open = _openExternally,
  });

  final bool accepted;
  final ValueChanged<bool> onChanged;
  final Future<bool> Function(Uri) open;

  Future<void> _show(BuildContext context, Uri uri) async {
    try {
      if (await open(uri)) return;
    } on Exception {
      // Keep the public address available when no browser can be launched.
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
    final linkStyle = TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      minimumSize: const Size(44, 44),
      tapTargetSize: MaterialTapTargetSize.padded,
    );
    return Semantics(
      container: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Checkbox(
                value: accepted,
                onChanged: (value) => onChanged(value ?? false),
                semanticLabel: 'Accept Terms and Conditions',
              ),
              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text('I agree to the '),
                    TextButton(
                      style: linkStyle,
                      onPressed: () =>
                          _show(context, TrotxiPublicInformation.terms),
                      child: const Text('Terms and Conditions'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 48),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text('Read how we use your information in the '),
                TextButton(
                  style: linkStyle,
                  onPressed: () =>
                      _show(context, TrotxiPublicInformation.privacy),
                  child: const Text('Privacy Notice'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
