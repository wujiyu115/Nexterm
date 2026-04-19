import 'package:flutter_test/flutter_test.dart';
import 'package:nexterm/features/sftp/services/sftp_service.dart';

void main() {
  group('RemoteFileInfo.permissionsString', () {
    RemoteFileInfo _make({int? permissions}) => RemoteFileInfo(
          name: 'test',
          path: '/test',
          isDirectory: false,
          size: 0,
          permissions: permissions,
        );

    test('returns rwxr-xr-x for 0o755 (0x1ED)', () {
      final info = _make(permissions: 0x1ED); // 0o755
      expect(info.permissionsString, equals('rwxr-xr-x'));
    });

    test('returns rw-r--r-- for 0o644 (0x1A4)', () {
      final info = _make(permissions: 0x1A4); // 0o644
      expect(info.permissionsString, equals('rw-r--r--'));
    });

    test('returns rwxrwxrwx for 0o777 (0x1FF)', () {
      final info = _make(permissions: 0x1FF); // 0o777
      expect(info.permissionsString, equals('rwxrwxrwx'));
    });

    test('returns --------- for 0o000', () {
      final info = _make(permissions: 0x000);
      expect(info.permissionsString, equals('---------'));
    });

    test('returns rwx------ for 0o700 (0x1C0)', () {
      final info = _make(permissions: 0x1C0); // 0o700
      expect(info.permissionsString, equals('rwx------'));
    });

    test('returns rw-rw-r-- for 0o664 (0x1B4)', () {
      final info = _make(permissions: 0x1B4); // 0o664
      expect(info.permissionsString, equals('rw-rw-r--'));
    });

    test('returns --------- when permissions is null', () {
      final info = _make(permissions: null);
      expect(info.permissionsString, equals('---------'));
    });
  });
}
