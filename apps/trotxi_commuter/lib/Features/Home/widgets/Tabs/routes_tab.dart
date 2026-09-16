import 'package:flutter/material.dart';
import 'package:trotxi_commuter/core/api/commuter_api.dart';

class RoutesTab extends StatefulWidget {
  const RoutesTab({super.key, required this.client});
  final CommuterApi client;

  @override
  State<RoutesTab> createState() => _RoutesTabState();
}

class _RoutesTabState extends State<RoutesTab> {
  @override
  Widget build(BuildContext context) {
    return Text('Routes Tab Yet to decide what to put here');
  }
}
