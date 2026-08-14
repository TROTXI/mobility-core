import 'package:flutter/material.dart';
import 'package:trotxi_client/trotxi_client.dart';

class WalletTab extends StatefulWidget {
  const WalletTab({super.key, required this.client});
  final TrotxiApiClient client;

  @override
  State<WalletTab> createState() => _WalletTabState();
}

class _WalletTabState extends State<WalletTab> {
  @override
  Widget build(BuildContext context) {
    return Text(' Wallet Tab');
  }
}
