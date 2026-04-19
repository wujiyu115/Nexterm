import 'package:flutter_test/flutter_test.dart';
import 'package:nexterm/features/settings/utils/ssh_config_parser.dart';

void main() {
  test('parses basic host entry', () {
    const config = 'Host production\n    HostName 192.168.1.100\n    User admin\n    Port 22\n';
    final hosts = SshConfigParser.parse(config);
    expect(hosts, hasLength(1));
    expect(hosts.first.name, equals('production'));
    expect(hosts.first.hostname, equals('192.168.1.100'));
    expect(hosts.first.username, equals('admin'));
    expect(hosts.first.port, equals(22));
  });

  test('parses multiple hosts', () {
    const config = 'Host prod\n    HostName 10.0.0.1\n    User deploy\n\nHost staging\n    HostName 10.0.0.2\n    User deploy\n    Port 2222\n';
    final hosts = SshConfigParser.parse(config);
    expect(hosts, hasLength(2));
    expect(hosts[1].port, equals(2222));
  });

  test('handles default port', () {
    const config = 'Host myserver\n    HostName example.com\n    User root\n';
    final hosts = SshConfigParser.parse(config);
    expect(hosts.first.port, equals(22));
  });

  test('skips wildcard hosts', () {
    const config = 'Host *\n    ServerAliveInterval 60\n\nHost real\n    HostName 1.2.3.4\n    User user\n';
    final hosts = SshConfigParser.parse(config);
    expect(hosts, hasLength(1));
    expect(hosts.first.name, equals('real'));
  });

  test('parses IdentityFile', () {
    const config = 'Host keyhost\n    HostName 10.0.0.5\n    User admin\n    IdentityFile ~/.ssh/id_ed25519\n';
    final hosts = SshConfigParser.parse(config);
    expect(hosts.first.identityFile, equals('~/.ssh/id_ed25519'));
  });

  test('parses ProxyJump', () {
    const config = 'Host target\n    HostName 10.0.0.50\n    User admin\n    ProxyJump jumpbox\n';
    final hosts = SshConfigParser.parse(config);
    expect(hosts.first.proxyJump, equals('jumpbox'));
  });
}
