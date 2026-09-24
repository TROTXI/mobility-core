import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';
import 'package:trotxi_commuter/core/config/theme/app_typography.dart';

/// Full-screen Paystack checkout for the `checkout.url` of a purchase
/// created with `POST /v1/me/purchases`.
///
/// The backend confirms the charge itself via its own Paystack webhook, so
/// this page has no authoritative way to know the payment succeeded. It
/// watches navigation for the moment the WebView leaves Paystack's own
/// checkout domain (the signal a configured `callback_url` would produce)
/// and pops as a best-effort "done", but always offers a manual close
/// button too in case Paystack never redirects away. Either way, the
/// caller should re-fetch wallet state after this pops rather than trust
/// its result — the webhook may still be catching up.
class PaystackCheckoutPage extends StatefulWidget {
  const PaystackCheckoutPage({super.key, required this.checkoutUrl});

  final String checkoutUrl;

  @override
  State<PaystackCheckoutPage> createState() => _PaystackCheckoutPageState();
}

class _PaystackCheckoutPageState extends State<PaystackCheckoutPage> {
  late final WebViewController _controller;
  bool _loading = true;

  bool _isPaystackHost(String? host) {
    return host != null && (host == 'paystack.com' || host.endsWith('.paystack.com'));
  }

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _loading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onNavigationRequest: (request) {
            final host = Uri.tryParse(request.url)?.host;
            if (!_isPaystackHost(host)) {
              // Left Paystack's own domain — the checkout is done (success
              // or cancel; we can't tell which from the URL alone).
              Navigator.of(context).pop(true);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.backgroundDefault,
      appBar: AppBar(
        backgroundColor: colors.surfaceElevated,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        title: Text(
          'Complete payment',
          style: AppTypography.label.copyWith(color: colors.textPrimary),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          tooltip: 'Close',
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading)
            Center(
              child: CircularProgressIndicator(color: colors.actionPrimaryDefault),
            ),
        ],
      ),
    );
  }
}
