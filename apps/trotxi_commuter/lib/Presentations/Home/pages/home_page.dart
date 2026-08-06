import 'package:flutter/material.dart';
import 'package:trotxi_client/trotxi_client.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.client});
  final TrotxiApiClient client;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Welcome to Trotxi')
      ),
    );
  }
}
