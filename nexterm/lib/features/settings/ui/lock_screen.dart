import 'package:flutter/material.dart';
import 'package:nexterm/core/theme/outdoor_colors.dart';
import 'package:nexterm/l10n/app_localizations.dart';
import 'package:nexterm/features/settings/services/biometric_service.dart';

class LockScreen extends StatefulWidget {
  final VoidCallback onUnlocked;
  const LockScreen({super.key, required this.onUnlocked});
  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final _biometric = BiometricService();
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _tryBiometric();
  }

  Future<void> _tryBiometric() async {
    if (_isAuthenticating) return;
    setState(() => _isAuthenticating = true);
    final available = await _biometric.isAvailable();
    if (available) {
      final success = await _biometric.authenticate();
      if (success) {
        widget.onUnlocked();
        return;
      }
    }
    if (mounted) setState(() => _isAuthenticating = false);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock, size: 64, color: OutdoorColors.accent),
            const SizedBox(height: 24),
            Text('Nexterm', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(l.lock_locked, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _isAuthenticating ? null : _tryBiometric,
              icon: const Icon(Icons.fingerprint),
              label: Text(l.lock_unlock),
            ),
          ],
        ),
      ),
    );
  }
}
