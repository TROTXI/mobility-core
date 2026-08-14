import 'package:flutter/material.dart';
import 'package:trotxi_client/trotxi_client.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key, required this.client});
  final TrotxiApiClient client;

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  Widget build(BuildContext context) {
    return Text('Welcome to Trotxi');
  }
}
