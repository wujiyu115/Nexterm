import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/features/settings/providers/settings_provider.dart';
import 'package:nexterm/features/terminal/services/stt/aliyun_stt_provider.dart';
import 'package:nexterm/features/terminal/services/stt/stt_credential_service.dart';
import 'package:nexterm/features/terminal/services/stt/stt_provider_interface.dart';
import 'package:nexterm/features/terminal/services/stt/system_stt_provider.dart';
import 'package:nexterm/features/terminal/services/stt/volcengine_stt_provider.dart';

final sttProviderTypeProvider = Provider<SttProviderType>((ref) {
  final settings = ref.watch(settingsNotifierProvider);
  final value = settings[SettingsKeys.sttProvider] ?? 'system';
  return SttProviderType.values.firstWhere(
    (e) => e.name == value,
    orElse: () => SttProviderType.system,
  );
});

final sttCredentialServiceProvider = Provider<SttCredentialService>((ref) {
  return const SttCredentialService();
});

final sttProviderInstanceProvider = Provider<SttProvider>((ref) {
  final type = ref.watch(sttProviderTypeProvider);
  final credentials = ref.watch(sttCredentialServiceProvider);
  return switch (type) {
    SttProviderType.system => SystemSttProvider(),
    SttProviderType.volcengine => VolcengineSttProvider(credentials: credentials),
    SttProviderType.alibaba => AliyunSttProvider(credentials: credentials),
  };
});

final sttAvailableProvider = FutureProvider.autoDispose<bool>((ref) {
  final provider = ref.watch(sttProviderInstanceProvider);
  return provider.isAvailable();
});
