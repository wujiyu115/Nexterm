import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/app.dart';
import 'package:nexterm/core/services/notification_service.dart';

export 'package:nexterm/data/database/database_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();
  runApp(const ProviderScope(child: NextermApp()));
}
