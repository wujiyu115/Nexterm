import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/features/sftp/ui/widgets/sftp_content.dart';

class SftpScreen extends ConsumerWidget {
  final String sessionId;

  const SftpScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('SFTP')),
      body: SftpContentWidget(sessionId: sessionId),
    );
  }
}
