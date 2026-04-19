class SshConfigEntry {
  final String name;
  final String hostname;
  final String username;
  final int port;
  final String? identityFile;
  final String? proxyJump;

  const SshConfigEntry({
    required this.name, required this.hostname, required this.username,
    this.port = 22, this.identityFile, this.proxyJump,
  });
}

class SshConfigParser {
  static List<SshConfigEntry> parse(String content) {
    final entries = <SshConfigEntry>[];
    String? currentHost;
    String? hostname;
    String? user;
    int? port;
    String? identityFile;
    String? proxyJump;

    void flush() {
      if (currentHost != null && currentHost != '*' && hostname != null) {
        entries.add(SshConfigEntry(
          name: currentHost, hostname: hostname!, username: user ?? 'root',
          port: port ?? 22, identityFile: identityFile, proxyJump: proxyJump,
        ));
      }
      hostname = null;
      user = null;
      port = null;
      identityFile = null;
      proxyJump = null;
    }

    for (final rawLine in content.split('\n')) {
      final line = rawLine.trim();
      if (line.isEmpty || line.startsWith('#')) continue;
      final parts = line.split(RegExp(r'\s+'));
      if (parts.length < 2) continue;
      final key = parts[0].toLowerCase();
      final value = parts.sublist(1).join(' ');
      if (key == 'host') {
        flush();
        currentHost = value;
      } else if (key == 'hostname') {
        hostname = value;
      } else if (key == 'user') {
        user = value;
      } else if (key == 'port') {
        port = int.tryParse(value);
      } else if (key == 'identityfile') {
        identityFile = value;
      } else if (key == 'proxyjump') {
        proxyJump = value;
      }
    }
    flush();
    return entries;
  }
}
