import 'package:flutter/material.dart';
import 'package:trotxi_client/trotxi_client.dart';

class RoutesTab extends StatefulWidget {
  const RoutesTab({super.key, required this.client});
  final TrotxiApiClient client;

  @override
  State<RoutesTab> createState() => _RoutesTabState();
}

class _RoutesTabState extends State<RoutesTab> {
  @override
  Widget build(BuildContext context) {
    return Text('Routes Tab Yet to decide what to put here');
  }
}
