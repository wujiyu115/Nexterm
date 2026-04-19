import 'package:flutter/material.dart';

class KeysScreen extends StatelessWidget {
  const KeysScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('密钥')),
      body: const Center(child: Text('密钥列表')),
    );
  }
}
