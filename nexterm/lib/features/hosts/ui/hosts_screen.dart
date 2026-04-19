import 'package:flutter/material.dart';

class HostsScreen extends StatelessWidget {
  const HostsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('主机')),
      body: const Center(child: Text('主机列表')),
    );
  }
}
