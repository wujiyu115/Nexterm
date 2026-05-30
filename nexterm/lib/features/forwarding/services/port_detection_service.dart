import 'dart:convert';

import 'package:dartssh2/dartssh2.dart';
import 'package:nexterm/features/forwarding/models/detected_port.dart';

class PortDetectionService {
  static const Duration _timeout = Duration(seconds: 10);

  static const Map<int, String> _knownPorts = {
    21: 'FTP',
    22: 'SSH',
    25: 'SMTP',
    53: 'DNS',
    80: 'HTTP',
    110: 'POP3',
    143: 'IMAP',
    443: 'HTTPS',
    993: 'IMAPS',
    995: 'POP3S',
    1433: 'MSSQL',
    1521: 'Oracle',
    2379: 'etcd',
    3000: 'HTTP',
    3306: 'MySQL',
    4369: 'Erlang',
    5000: 'HTTP',
    5432: 'PostgreSQL',
    5672: 'AMQP',
    6379: 'Redis',
    6443: 'K8s API',
    8000: 'HTTP',
    8080: 'HTTP',
    8443: 'HTTPS',
    8888: 'HTTP',
    9090: 'Prometheus',
    9200: 'Elasticsearch',
    9300: 'Elasticsearch',
    11211: 'Memcached',
    15672: 'RabbitMQ',
    27017: 'MongoDB',
  };

  static const Map<String, String> _processProtocols = {
    'nginx': 'HTTP',
    'apache': 'HTTP',
    'httpd': 'HTTP',
    'caddy': 'HTTP',
    'node': 'HTTP',
    'python': 'HTTP',
    'python3': 'HTTP',
    'java': 'HTTP',
    'mysqld': 'MySQL',
    'mysql': 'MySQL',
    'postgres': 'PostgreSQL',
    'redis-server': 'Redis',
    'redis': 'Redis',
    'mongod': 'MongoDB',
    'mongo': 'MongoDB',
    'sshd': 'SSH',
    'docker-proxy': 'Docker',
    'containerd': 'Container',
  };

  Future<List<DetectedPort>> detectPorts(SSHClient client) async {
    final scanOutput = await _runCommand(
      client,
      'OS=\$(uname -s 2>/dev/null); echo "::OS::\$OS"; '
      'if [ "\$OS" = "Darwin" ]; then '
      'lsof -iTCP -sTCP:LISTEN -n -P 2>/dev/null; '
      'else '
      'ss -tlnp 2>/dev/null || netstat -tlnp 2>/dev/null; '
      'fi',
    );

    if (scanOutput == null || scanOutput.trim().isEmpty) return [];

    final osMarkerIndex = scanOutput.indexOf('::OS::');
    if (osMarkerIndex == -1) return [];

    final afterMarker = scanOutput.substring(osMarkerIndex + 6);
    final newlineIndex = afterMarker.indexOf('\n');
    if (newlineIndex == -1) return [];

    final os = afterMarker.substring(0, newlineIndex).trim();
    final portData = afterMarker.substring(newlineIndex + 1);

    List<DetectedPort> ports;
    if (os == 'Darwin') {
      ports = _parseLsofOutput(portData);
    } else {
      ports = _parseSsOrNetstatOutput(portData);
    }

    if (ports.isEmpty) return [];

    // Enrich with full command lines
    final pids = ports.where((p) => p.pid != null).map((p) => p.pid!).toSet();
    if (pids.isNotEmpty) {
      final enriched = await _enrichWithPs(client, pids, os);
      if (enriched.isNotEmpty) {
        ports = ports.map((p) {
          if (p.pid != null && enriched.containsKey(p.pid)) {
            return p.copyWith(commandLine: enriched[p.pid]);
          }
          return p;
        }).toList();
      }
    }

    // Sort: user ports first, then by port number
    ports.sort((a, b) {
      if (a.category != b.category) {
        return a.category == PortCategory.user ? -1 : 1;
      }
      return a.port.compareTo(b.port);
    });

    return ports;
  }

  List<DetectedPort> _parseSsOrNetstatOutput(String output) {
    final lines = output.split('\n');
    if (lines.isEmpty) return [];

    // Detect format: ss has "State" header, netstat has "Proto" header
    final isNetstat = lines.any((l) => l.trimLeft().startsWith('Proto') || l.trimLeft().startsWith('tcp'));
    if (isNetstat && lines.any((l) => l.contains('PID/Program'))) {
      return _parseNetstatOutput(lines);
    }
    return _parseSsOutput(lines);
  }

  List<DetectedPort> _parseSsOutput(List<String> lines) {
    final ports = <DetectedPort>{};
    final processRegex = RegExp(r'users:\(\("([^"]+)",pid=(\d+)');

    for (final line in lines) {
      if (!line.contains('LISTEN')) continue;

      final parts = line.split(RegExp(r'\s+'));
      if (parts.length < 4) continue;

      final localAddr = parts[3];
      final parsed = _parseAddress(localAddr);
      if (parsed == null) continue;

      String? processName;
      int? pid;
      final processMatch = processRegex.firstMatch(line);
      if (processMatch != null) {
        processName = processMatch.group(1);
        pid = int.tryParse(processMatch.group(2) ?? '');
      }

      ports.add(_buildDetectedPort(
        port: parsed.$1,
        bindAddress: parsed.$2,
        processName: processName,
        pid: pid,
      ));
    }

    return ports.toList();
  }

  List<DetectedPort> _parseNetstatOutput(List<String> lines) {
    final ports = <DetectedPort>{};

    for (final line in lines) {
      if (!line.contains('LISTEN')) continue;

      final parts = line.split(RegExp(r'\s+'));
      if (parts.length < 4) continue;

      final localAddr = parts[3];
      final parsed = _parseAddress(localAddr);
      if (parsed == null) continue;

      String? processName;
      int? pid;
      // Last column is "PID/Program" or "-"
      final lastCol = parts.last;
      if (lastCol != '-' && lastCol.contains('/')) {
        final pidProgram = lastCol.split('/');
        pid = int.tryParse(pidProgram[0]);
        processName = pidProgram.length > 1 ? pidProgram[1] : null;
      }

      ports.add(_buildDetectedPort(
        port: parsed.$1,
        bindAddress: parsed.$2,
        processName: processName,
        pid: pid,
      ));
    }

    return ports.toList();
  }

  List<DetectedPort> _parseLsofOutput(String output) {
    final lines = output.split('\n');
    final ports = <DetectedPort>{};

    for (final line in lines) {
      if (!line.contains('LISTEN') && !line.contains('(LISTEN)')) continue;

      final parts = line.split(RegExp(r'\s+'));
      if (parts.length < 9) continue;

      final processName = parts[0];
      final pid = int.tryParse(parts[1]);

      // NAME field is the last before (LISTEN), format: "addr:port"
      String? nameField;
      for (int i = parts.length - 1; i >= 0; i--) {
        if (parts[i] == '(LISTEN)') {
          if (i > 0) nameField = parts[i - 1];
          break;
        }
      }
      if (nameField == null) continue;

      final parsed = _parseLsofAddress(nameField);
      if (parsed == null) continue;

      ports.add(_buildDetectedPort(
        port: parsed.$1,
        bindAddress: parsed.$2,
        processName: processName,
        pid: pid,
      ));
    }

    return ports.toList();
  }

  DetectedPort _buildDetectedPort({
    required int port,
    required String bindAddress,
    String? processName,
    int? pid,
  }) {
    return DetectedPort(
      port: port,
      bindAddress: bindAddress,
      processName: processName,
      pid: pid,
      protocolGuess: _guessProtocol(port, processName),
      category: port < 1024 ? PortCategory.system : PortCategory.user,
    );
  }

  /// Parse "addr:port" from ss/netstat output.
  /// Handles: "0.0.0.0:80", "127.0.0.1:3306", ":::80", "[::]:80", "*:80"
  (int, String)? _parseAddress(String addr) {
    // IPv6 bracket format: [::1]:port or [::]:port
    if (addr.startsWith('[')) {
      final closeBracket = addr.lastIndexOf(']');
      if (closeBracket == -1) return null;
      final address = addr.substring(1, closeBracket);
      final portStr = addr.substring(closeBracket + 2); // skip ]:
      final port = int.tryParse(portStr);
      if (port == null || port <= 0) return null;
      return (port, address);
    }

    // IPv6 triple-colon format: :::port
    if (addr.startsWith(':::')) {
      final port = int.tryParse(addr.substring(3));
      if (port == null || port <= 0) return null;
      return (port, '::');
    }

    // IPv6 with :: prefix: ::1:port — find last colon
    if (addr.startsWith('::') && !addr.startsWith(':::')) {
      final lastColon = addr.lastIndexOf(':');
      if (lastColon <= 1) return null;
      final port = int.tryParse(addr.substring(lastColon + 1));
      if (port == null || port <= 0) return null;
      return (port, addr.substring(0, lastColon));
    }

    // Standard IPv4: addr:port or *:port
    final lastColon = addr.lastIndexOf(':');
    if (lastColon == -1) return null;
    final port = int.tryParse(addr.substring(lastColon + 1));
    if (port == null || port <= 0) return null;
    final address = addr.substring(0, lastColon);
    return (port, address == '*' ? '0.0.0.0' : address);
  }

  /// Parse lsof NAME field: "*:80", "localhost:3000", "127.0.0.1:8080"
  (int, String)? _parseLsofAddress(String name) {
    final lastColon = name.lastIndexOf(':');
    if (lastColon == -1) return null;
    final port = int.tryParse(name.substring(lastColon + 1));
    if (port == null || port <= 0) return null;
    final addr = name.substring(0, lastColon);
    if (addr == '*' || addr.isEmpty) return (port, '0.0.0.0');
    if (addr == 'localhost') return (port, '127.0.0.1');
    return (port, addr);
  }

  String _guessProtocol(int port, String? processName) {
    if (_knownPorts.containsKey(port)) return _knownPorts[port]!;

    if (processName != null) {
      final lower = processName.toLowerCase();
      for (final entry in _processProtocols.entries) {
        if (lower.contains(entry.key)) return entry.value;
      }
    }

    return 'TCP';
  }

  Future<Map<int, String>> _enrichWithPs(
    SSHClient client,
    Set<int> pids,
    String os,
  ) async {
    final pidList = pids.join(',');
    final command = os == 'Darwin'
        ? 'ps -o pid=,command= -p $pidList 2>/dev/null'
        : 'ps -o pid=,cmd= -p ${pids.join(' -p ')} 2>/dev/null';

    final output = await _runCommand(client, command);
    if (output == null) return {};

    final result = <int, String>{};
    for (final line in output.split('\n')) {
      final trimmed = line.trimLeft();
      if (trimmed.isEmpty) continue;
      final spaceIndex = trimmed.indexOf(RegExp(r'\s'));
      if (spaceIndex == -1) continue;
      final pid = int.tryParse(trimmed.substring(0, spaceIndex));
      if (pid == null) continue;
      result[pid] = trimmed.substring(spaceIndex).trim();
    }
    return result;
  }

  Future<String?> _runCommand(SSHClient client, String command) async {
    try {
      final result = await client.run(command).timeout(_timeout);
      return utf8.decode(result, allowMalformed: true);
    } catch (_) {
      return null;
    }
  }
}
