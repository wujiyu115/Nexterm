import 'package:flutter_test/flutter_test.dart';
import 'package:nexterm/features/sftp/ui/utils/file_size_format.dart';

void main() {
  test('formats bytes', () {
    expect(formatFileSize(0), equals('0 B'));
    expect(formatFileSize(500), equals('500 B'));
  });
  test('formats KB', () {
    expect(formatFileSize(1024), equals('1.0 KB'));
    expect(formatFileSize(1536), equals('1.5 KB'));
  });
  test('formats MB', () {
    expect(formatFileSize(1048576), equals('1.0 MB'));
  });
  test('formats GB', () {
    expect(formatFileSize(1073741824), equals('1.0 GB'));
  });
}
