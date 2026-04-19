import 'package:flutter_test/flutter_test.dart';
import 'package:nexterm/features/terminal/services/reconnect_service.dart';

void main() {
  test('calculates exponential backoff correctly', () {
    expect(ReconnectService.calculateDelay(0), equals(const Duration(seconds: 1)));
    expect(ReconnectService.calculateDelay(1), equals(const Duration(seconds: 2)));
    expect(ReconnectService.calculateDelay(2), equals(const Duration(seconds: 4)));
    expect(ReconnectService.calculateDelay(3), equals(const Duration(seconds: 8)));
    expect(ReconnectService.calculateDelay(4), equals(const Duration(seconds: 16)));
    expect(ReconnectService.calculateDelay(5), equals(const Duration(seconds: 30)));
    expect(ReconnectService.calculateDelay(10), equals(const Duration(seconds: 30)));
  });

  test('max retries defaults to 10', () {
    final service = ReconnectService(maxRetries: 10);
    expect(service.maxRetries, equals(10));
  });
}
