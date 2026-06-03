enum SttProviderType { system, volcengine, alibaba }

class SttResult {
  final String text;
  final bool isFinal;
  SttResult({required this.text, required this.isFinal});
}

abstract class SttProvider {
  Future<bool> isAvailable();
  Stream<SttResult> start({String? localeId});
  Future<void> stop();
  Future<int> testSpeed();
  void dispose();
}
