import 'package:flutter/material.dart';

class TerminalScreen extends StatelessWidget {
  final String? hostId;
  const TerminalScreen({super.key, this.hostId});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('终端')),
      body: const Center(child: Text('终端视图')),
    );
  }
}
