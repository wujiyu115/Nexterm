import 'package:flutter/material.dart';
import 'package:nexterm/features/sftp/ui/widgets/sftp_content.dart';
import 'package:nexterm/features/sftp/services/remote_file_service.dart';

class SmbBrowserScreen extends StatelessWidget {
  final RemoteFileService service;
  final String title;
  const SmbBrowserScreen({super.key, required this.service, this.title = 'SMB'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SftpContentWidget(service: service),
    );
  }
}
