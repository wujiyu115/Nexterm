import 'package:flutter/material.dart';

class HostFormScreen extends StatelessWidget {
  final String? hostId;
  const HostFormScreen({super.key, this.hostId});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(hostId == null ? '添加主机' : '编辑主机')),
      body: const Center(child: Text('主机表单')),
    );
  }
}
