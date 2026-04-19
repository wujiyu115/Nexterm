import 'package:flutter/material.dart';

class KeyGenerateScreen extends StatelessWidget {
  const KeyGenerateScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('生成密钥')),
      body: const Center(child: Text('密钥生成表单')),
    );
  }
}
