import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: NextermApp()));
}

class NextermApp extends StatelessWidget {
  const NextermApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nexterm',
      theme: ThemeData.dark(),
      home: const Scaffold(
        body: Center(child: Text('Nexterm')),
      ),
    );
  }
}
